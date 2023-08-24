/*
 * ***********************************************************
 *  Copyright (c) 2023 Contributors to the Eclipse Foundation
 *  <p>
 *  See the NOTICE file(s) distributed with this work for additional
 *  information regarding copyright ownership.
 *  <p>
 *  This program and the accompanying materials are made available under the
 *  terms of the Eclipse Public License 2.0 which is available at
 *  http://www.eclipse.org/legal/epl-2.0
 *  <p>
 *  SPDX-License-Identifier: EPL-2.0
 * **********************************************************
 *
 */

package org.eclipse.hono.communication.api.service.communication;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Stream;

import org.apache.commons.lang3.StringUtils;
import org.eclipse.hono.client.pubsub.PubSubMessageHelper;
import org.eclipse.hono.communication.api.config.PubSubConstants;
import org.eclipse.hono.communication.api.handler.CommandTopicEventHandler;
import org.eclipse.hono.communication.api.handler.ConfigTopicEventHandler;
import org.eclipse.hono.communication.api.handler.StateTopicEventHandler;
import org.eclipse.hono.communication.api.repository.DeviceRepository;
import org.eclipse.hono.communication.core.app.InternalMessagingConfig;
import org.eclipse.hono.notification.deviceregistry.LifecycleChange;
import org.eclipse.hono.notification.deviceregistry.TenantChangeNotification;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.cloud.pubsub.v1.AckReplyConsumer;
import com.google.common.base.Strings;
import com.google.pubsub.v1.PubsubMessage;
import com.google.pubsub.v1.Subscription;
import com.google.pubsub.v1.SubscriptionName;
import com.google.pubsub.v1.TopicName;

import io.vertx.core.CompositeFuture;
import io.vertx.core.Future;
import io.vertx.core.Vertx;
import jakarta.enterprise.context.ApplicationScoped;

/**
 * Pub/Sub based internal topic manager.
 */
@ApplicationScoped
public class PubSubBasedInternalTopicManager implements InternalTopicManager {

    static ObjectMapper objectMapper = new ObjectMapper();
    private final Logger log = LoggerFactory.getLogger(PubSubBasedInternalTopicManager.class);
    private final DeviceRepository deviceRepository;
    private final CommandTopicEventHandler commandTopicEventHandler;
    private final ConfigTopicEventHandler configTopicEventHandler;
    private final StateTopicEventHandler stateTopicEventHandler;
    private final InternalMessaging internalMessaging;
    private final InternalMessagingConfig internalMessagingConfig;
    private final PubSubBasedAdminClientManagerFactory adminClientManagerFactory;
    private final Vertx vertx;
    private final String projectId;

    /**
     * Creates a new PubSubBasedInternalTopicManager.
     *
     * @param deviceRepository The device repository
     * @param commandTopicEventHandler The command topic event handler
     * @param configTopicEventHandler The config topic event handler
     * @param stateTopicEventHandler The state topic event handler
     * @param internalMessaging The internal messaging service
     * @param internalMessagingConfig The internal messaging config
     * @param adminClientManagerFactory The factory to create Pub/Sub based admin client manager to manage topics and
     *            subscriptions
     * @param vertx The Quarkus Vert.x instance
     */
    public PubSubBasedInternalTopicManager(final DeviceRepository deviceRepository,
            final CommandTopicEventHandler commandTopicEventHandler,
            final ConfigTopicEventHandler configTopicEventHandler,
            final StateTopicEventHandler stateTopicEventHandler, final InternalMessaging internalMessaging,
            final InternalMessagingConfig internalMessagingConfig,
            final PubSubBasedAdminClientManagerFactory adminClientManagerFactory, final Vertx vertx) {
        this.deviceRepository = deviceRepository;
        this.commandTopicEventHandler = commandTopicEventHandler;
        this.configTopicEventHandler = configTopicEventHandler;
        this.stateTopicEventHandler = stateTopicEventHandler;
        this.internalMessaging = internalMessaging;
        this.internalMessagingConfig = internalMessagingConfig;
        this.vertx = vertx;
        this.projectId = internalMessagingConfig.getProjectId();
        this.adminClientManagerFactory = adminClientManagerFactory;
    }

    @Override
    public void init() {
        log.info("Initialize tenant topics and subscriptions.");
        vertx.executeBlocking(promise -> {
            internalMessaging.subscribe(
                    PubSubConstants.COMMUNICATION_API_SUBSCRIPTION_NAME.formatted(PubSubConstants.TENANT_NOTIFICATIONS),
                    this::onTenantChanges);
            promise.complete();
        });
        deviceRepository.listDistinctTenants()
                .onFailure(err -> log.error("Error getting tenants for topic creation: {}", err.getMessage()))
                .onSuccess(tenants -> {
                    if (tenants.size() < internalMessagingConfig.getBatchInitTenantThreshold()) {
                        for (String tenant : tenants) {
                            initPubSubForTenant(tenant);
                        }
                    } else {
                        batchInitPubSubResources(tenants);
                    }
                });
    }

    private void batchInitPubSubResources(final List<String> tenants) {
        log.info("Start batchInitPubSubResources");
        findMissingPubSubResources(tenants).compose(map -> {
            final PubSubBasedAdminClientManager adminClientManager = adminClientManagerFactory
                    .createAdminClientManager();
            final List<Future> pubsubRequests = new ArrayList<>();
            for (Map.Entry<String, String> missingTopic : map.get("missingTopics").entrySet()) {
                final TopicName topic = TopicName.parse(missingTopic.getKey());
                pubsubRequests.add(adminClientManager.createTopic(topic));
            }
            for (Map.Entry<String, String> missingSubscription : map.get("missingSubscriptions").entrySet()) {
                final SubscriptionName subscription = SubscriptionName.parse(missingSubscription.getKey());
                final TopicName topic = TopicName.parse(missingSubscription.getValue());
                pubsubRequests.add(adminClientManager.createSubscription(subscription, topic));
            }
            for (Map.Entry<String, String> faultySubscription : map.get("faultySubscriptions").entrySet()) {
                final SubscriptionName subscription = SubscriptionName.parse(faultySubscription.getKey());
                final TopicName topic = TopicName.parse(faultySubscription.getValue());
                pubsubRequests.add(adminClientManager.updateSubscriptionTopic(subscription, topic));
            }
            return CompositeFuture.join(pubsubRequests).onComplete(i -> {
                adminClientManager.closeAdminClients();
                log.info("Finished batchInitPubSubResources");
            });
        }).onFailure(e -> log.error("batchInitPubSubResources failed", e))
                .onSuccess(i -> {
                    for (String tenant : tenants) {
                        vertx.executeBlocking(promise -> subscribeToTenantTopics(tenant));
                    }
                });
    }

    private Future<Map<String, Map<String, String>>> findMissingPubSubResources(final List<String> tenants) {
        final PubSubBasedAdminClientManager pubSubBasedAdminClientManager = adminClientManagerFactory
                .createAdminClientManager();
        final Future<Set<String>> topicsFuture = pubSubBasedAdminClientManager.listTopics();
        final Future<Set<Subscription>> subscriptionsFuture = pubSubBasedAdminClientManager.listSubscriptions();
        final Map<String, String> missingTopics = new HashMap<>();
        final Map<String, String> missingSubscriptions = new HashMap<>();
        final Map<String, String> faultySubscriptions = new HashMap<>();
        return CompositeFuture.join(topicsFuture, subscriptionsFuture).map(i -> {
            final Set<String> topicSet = topicsFuture.result();
            final Set<Subscription> subscriptionSet = subscriptionsFuture.result();
            final Map<String, Subscription> subscriptionMap = new HashMap<>();
            subscriptionSet.forEach(s -> subscriptionMap.put(s.getName(), s));
            for (String tenantEndpoint : PubSubConstants.getTenantEndpoints()) {
                for (String tenant : tenants) {
                    final String topic = String
                            .valueOf(TopicName.of(projectId, PubSubMessageHelper.getTopicName(tenantEndpoint, tenant)));
                    addMissingTopicToMap(topicSet, topic, missingTopics);
                    final String subscription = String.valueOf(
                            SubscriptionName.of(projectId, PubSubMessageHelper.getTopicName(tenantEndpoint, tenant)));
                    addMissingOrFaultySubscription(subscriptionMap, missingSubscriptions, faultySubscriptions,
                            subscription, topic);
                    if (PubSubConstants.getEndpointsWithAdditionalSubscription().contains(tenantEndpoint)) {
                        final String apiSubscription = String.valueOf(SubscriptionName.of(projectId,
                                PubSubMessageHelper.getTopicName(
                                        String.format(PubSubConstants.COMMUNICATION_API_SUBSCRIPTION_NAME,
                                                tenantEndpoint),
                                        tenant)));
                        addMissingOrFaultySubscription(subscriptionMap, missingSubscriptions, faultySubscriptions,
                                apiSubscription, topic);
                    }
                }
            }
            return Map.of("missingTopics", missingTopics, "missingSubscriptions", missingSubscriptions,
                    "faultySubscriptions", faultySubscriptions);
        }).onFailure(thr -> log.error("Cannot find missing Pub/Sub resources", thr))
                .onComplete(i -> pubSubBasedAdminClientManager.closeAdminClients());
    }

    private void addMissingTopicToMap(final Set<String> topicSet, final String topic,
            final Map<String, String> missingTopics) {
        if (!topicSet.contains(topic)) {
            missingTopics.put(topic, "");
        }
    }

    private void addMissingOrFaultySubscription(final Map<String, Subscription> subscriptionMap,
            final Map<String, String> missingSubscriptions, final Map<String, String> faultySubscriptions,
            final String subscription, final String topic) {
        if (!subscriptionMap.containsKey(subscription)) {
            missingSubscriptions.put(subscription, topic);
            return;
        }
        final String deletedTopic = "_deleted-topic_";
        if (subscriptionMap.get(subscription) != null
                && StringUtils.equals(subscriptionMap.get(subscription).getTopic(), deletedTopic)) {
            faultySubscriptions.put(subscription, topic);
        }
    }

    @Override
    public void onTenantChanges(final PubsubMessage pubsubMessage, final AckReplyConsumer consumer) {
        consumer.ack();
        final String jsonString = pubsubMessage.getData().toStringUtf8();
        final TenantChangeNotification notification;
        log.debug("Handle tenant change notification {}", jsonString);
        try {
            notification = objectMapper.readValue(jsonString, TenantChangeNotification.class);
        } catch (JsonProcessingException e) {
            log.error("Can't deserialize tenant change notification: {}", e.getMessage());
            return;
        }
        final String tenant = notification.getTenantId();
        if (notification.getChange() == LifecycleChange.CREATE && !Strings.isNullOrEmpty(tenant)) {
            log.info("Tenant {} was created. All its topics and subscriptions will be created.", tenant);
            initPubSubForTenant(tenant);
        } else if (notification.getChange() == LifecycleChange.DELETE && !Strings.isNullOrEmpty(tenant)) {
            log.info("Tenant {} was deleted. All its topics and subscriptions will be deleted.", tenant);
            cleanupPubSubResources(tenant);
        }
    }

    private void initPubSubForTenant(final String tenant) {
        PubSubMessageHelper.getCredentialsProvider()
                .ifPresentOrElse(provider -> {
                    final var pubSubBasedAdminClientManager = adminClientManagerFactory.createAdminClientManager();
                    createPubSubResourceForTenant(tenant, PubSubResourceType.TOPIC,
                            pubSubBasedAdminClientManager)
                            .onFailure(thr -> log.error("Creation of tenant topics failed.", thr))
                            .compose(v -> createPubSubResourceForTenant(tenant,
                                    PubSubResourceType.SUBSCRIPTION, pubSubBasedAdminClientManager)
                                    .onComplete(v1 -> vertx.executeBlocking(
                                            p -> pubSubBasedAdminClientManager.closeAdminClients()))
                                    .onFailure(thr -> log
                                            .error("Creation of tenant subscriptions failed.", thr))
                                    .onSuccess(v2 -> vertx.executeBlocking(p -> {
                                        subscribeToTenantTopics(tenant);
                                        p.complete();
                                    })));
                }, () -> log.error("Credentials provider is empty"));
    }

    /**
     * Creates Pub/Sub resources (topics or subscriptions) for the provided tenant.
     *
     * @param tenantId The tenant
     * @param pubSubResourceType Which Pub/Sub resource type should be created (topic or subscription)
     * @return A succeeded Future if the Pub/Sub resources were successfully created or already existed, or a failed
     *         Future if they could not be created
     */
    private Future<Void> createPubSubResourceForTenant(final String tenantId,
            final PubSubResourceType pubSubResourceType,
            final PubSubBasedAdminClientManager pubSubBasedAdminClientManager) {
        final List<Future> futureList = new ArrayList<>();
        for (String tenantEndpoint : PubSubConstants.getTenantEndpoints()) {
            if (pubSubResourceType == PubSubResourceType.TOPIC) {
                futureList.add(pubSubBasedAdminClientManager.getOrCreateTopic(tenantEndpoint, tenantId));
            } else {
                futureList.add(pubSubBasedAdminClientManager.getOrCreateSubscription(tenantEndpoint, tenantEndpoint,
                        tenantId));
                if (PubSubConstants.getEndpointsWithAdditionalSubscription().contains(tenantEndpoint)) {
                    futureList.add(pubSubBasedAdminClientManager.getOrCreateSubscription(tenantEndpoint,
                            String.format(PubSubConstants.COMMUNICATION_API_SUBSCRIPTION_NAME, tenantEndpoint),
                            tenantId));
                }
            }
        }
        return CompositeFuture.join(futureList)
                .recover(thr -> {
                    log.error("One or more {}s could not be created for tenant {}.",
                            pubSubResourceType.toString().toLowerCase(), tenantId);
                    return Future.failedFuture(thr);
                })
                .compose(compositeFuture -> {
                    log.info("All {}s created for tenant {}", pubSubResourceType.toString().toLowerCase(), tenantId);
                    return Future.succeededFuture();
                });
    }

    private void subscribeToTenantTopics(final String tenant) {
        internalMessaging.subscribe(
                PubSubConstants.COMMUNICATION_API_SUBSCRIPTION_NAME
                        .formatted(internalMessagingConfig.getEventTopicFormat().formatted(tenant)),
                configTopicEventHandler::onDeviceConfigRequest);
        internalMessaging.subscribe(
                PubSubConstants.COMMUNICATION_API_SUBSCRIPTION_NAME
                        .formatted(internalMessagingConfig.getCommandAckTopicFormat().formatted(tenant)),
                commandTopicEventHandler::onDeviceCommandResponse);
        internalMessaging.subscribe(
                PubSubConstants.COMMUNICATION_API_SUBSCRIPTION_NAME
                        .formatted(internalMessagingConfig.getStateTopicFormat().formatted(tenant)),
                stateTopicEventHandler::onStateMessage);
    }

    private void cleanupPubSubResources(final String tenant) {
        final List<String> pubSubTopicsToDelete = PubSubConstants.getTenantEndpoints().stream().map(
                endpoint -> String.valueOf(TopicName.of(projectId, PubSubMessageHelper.getTopicName(endpoint, tenant))))
                .toList();
        final List<String> pubSubSubscriptionsToDelete = Stream.concat(PubSubConstants.getTenantEndpoints().stream()
                .map(endpoint -> String
                        .valueOf(SubscriptionName.of(projectId, PubSubMessageHelper.getTopicName(endpoint, tenant)))),
                PubSubConstants.getEndpointsWithAdditionalSubscription().stream()
                        .map(endpoint -> String.valueOf(SubscriptionName.of(projectId,
                                PubSubMessageHelper.getTopicName(
                                        String.format(PubSubConstants.COMMUNICATION_API_SUBSCRIPTION_NAME, endpoint),
                                        tenant)))))
                .toList();
        internalMessaging.closeSubscribersForTenant(tenant);
        PubSubMessageHelper.getCredentialsProvider()
                .ifPresentOrElse(provider -> {
                    final PubSubBasedAdminClientManager pubSubBasedAdminClientManager = adminClientManagerFactory
                            .createAdminClientManager();
                    CompositeFuture.join(pubSubBasedAdminClientManager.deleteTopics(pubSubTopicsToDelete),
                            pubSubBasedAdminClientManager.deleteSubscriptions(pubSubSubscriptionsToDelete))
                            .onSuccess(compFuture -> log.info(
                                    "All topics and subscriptions of tenant {} were deleted successfully.", tenant))
                            .onFailure(throwable -> log.warn(
                                    "Some topics or subscriptions of tenant {} could not be deleted.", tenant,
                                    throwable))
                            .onComplete(compFuture -> pubSubBasedAdminClientManager.closeAdminClients());
                }, () -> log.error("credentials provider is empty"));
    }

    private enum PubSubResourceType {
        TOPIC, SUBSCRIPTION
    }
}
