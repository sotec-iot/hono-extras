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

import java.util.List;

import javax.enterprise.context.ApplicationScoped;

import org.eclipse.hono.client.pubsub.PubSubBasedAdminClientManager;
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
import com.google.pubsub.v1.SubscriptionName;
import com.google.pubsub.v1.TopicName;

import io.vertx.core.Vertx;

/**
 * Internal topic manager interface.
 */
@ApplicationScoped
public class InternalTopicManagerImpl implements InternalTopicManager {

    static ObjectMapper objectMapper = new ObjectMapper();
    private final Logger log = LoggerFactory.getLogger(InternalTopicManagerImpl.class);
    private final DeviceRepository deviceRepository;
    private final CommandTopicEventHandler commandTopicEventHandler;
    private final ConfigTopicEventHandler configTopicEventHandler;
    private final StateTopicEventHandler stateTopicEventHandler;
    private final InternalMessaging internalMessaging;
    private final InternalMessagingConfig internalMessagingConfig;
    private final Vertx vertx;

    /**
     * Creates a new InternalTopicManagerImpl.
     *
     * @param deviceRepository The device repository.
     * @param commandTopicEventHandler The command topic event handler.
     * @param configTopicEventHandler The config topic event handler.
     * @param stateTopicEventHandler The state topic event handler.
     * @param internalMessaging The internal messaging interface.
     * @param internalMessagingConfig The internal messaging config.
     * @param vertx The quarkus Vertx instance.
     */
    public InternalTopicManagerImpl(final DeviceRepository deviceRepository,
            final CommandTopicEventHandler commandTopicEventHandler,
            final ConfigTopicEventHandler configTopicEventHandler,
            final StateTopicEventHandler stateTopicEventHandler, final InternalMessaging internalMessaging,
            final InternalMessagingConfig internalMessagingConfig, final Vertx vertx) {
        this.deviceRepository = deviceRepository;
        this.commandTopicEventHandler = commandTopicEventHandler;
        this.configTopicEventHandler = configTopicEventHandler;
        this.stateTopicEventHandler = stateTopicEventHandler;
        this.internalMessaging = internalMessaging;
        this.internalMessagingConfig = internalMessagingConfig;
        this.vertx = vertx;
    }

    @Override
    public void initPubSub() {
        log.info("Initialize tenant topics and subscriptions.");
        internalMessaging.subscribe(PubSubConstants.TENANT_NOTIFICATIONS, this::onTenantChanges);
        deviceRepository.listDistinctTenants()
                .onSuccess(tenants -> {
                    vertx.executeBlocking(promise -> {
                        tenants.forEach(tenant -> {
                            createPubSubResourceForTenant(tenant, PubSubResourceType.TOPIC);
                            createPubSubResourceForTenant(tenant, PubSubResourceType.SUBSCRIPTION);
                            subscribeToTenantTopics(tenant);
                        });
                        promise.complete();
                    });
                    log.info("Initialization of tenant topics and subscriptions completed.");
                })
                .onFailure(err -> log.error("Error getting tenants for topic creation: {}", err.getMessage()));
    }

    /**
     * Creates Pub/Sub resources (topics or subscriptions) for the provided tenant.
     *
     * @param tenantId The tenant.
     * @param pubSubResourceType Which Pub Sub resource type should be created (topic or subscription).
     */
    private void createPubSubResourceForTenant(final String tenantId, final PubSubResourceType pubSubResourceType) {
        final String projectId = internalMessagingConfig.getProjectId();
        if (projectId == null) {
            log.error("project ID is null");
            return;
        }
        PubSubMessageHelper.getCredentialsProvider()
                .ifPresentOrElse(provider -> {
                    final List<String> topics = PubSubConstants.getTenantTopics();
                    topics.forEach(topic -> {
                        final var pubSubBasedAdminClientManager = new PubSubBasedAdminClientManager(projectId,
                                provider);
                        if (pubSubResourceType == PubSubResourceType.TOPIC) {
                            pubSubBasedAdminClientManager.getOrCreateTopic(topic, tenantId);
                        } else {
                            pubSubBasedAdminClientManager.getOrCreateSubscription(topic, tenantId);
                        }
                        pubSubBasedAdminClientManager.closeAdminClients();
                    });
                    log.info("All {}s created for {}", pubSubResourceType.toString().toLowerCase(), tenantId);
                }, () -> log.error("credentials provider is empty"));
    }

    private void subscribeToTenantTopics(final String tenant) {
        internalMessaging.subscribe(
                internalMessagingConfig.getEventTopicFormat().formatted(tenant),
                configTopicEventHandler::onDeviceConfigRequest);
        internalMessaging.subscribe(
                internalMessagingConfig.getCommandAckTopicFormat().formatted(tenant),
                commandTopicEventHandler::onDeviceCommandResponse);
        internalMessaging.subscribe(
                internalMessagingConfig.getStateTopicFormat().formatted(tenant),
                stateTopicEventHandler::onStateMessage);
    }

    /**
     * Handle incoming tenant CREATE notifications.
     *
     * @param pubsubMessage The message to handle
     * @param consumer The message consumer
     */
    public void onTenantChanges(final PubsubMessage pubsubMessage, final AckReplyConsumer consumer) {
        consumer.ack();
        final String jsonString = pubsubMessage.getData().toStringUtf8();
        final TenantChangeNotification notification;
        log.info("Handle tenant change notification {}", jsonString);
        try {
            notification = objectMapper.readValue(jsonString, TenantChangeNotification.class);
        } catch (JsonProcessingException e) {
            log.error("Can't deserialize tenant change notification: {}", e.getMessage());
            return;
        }
        final String tenant = notification.getTenantId();
        if (notification.getChange() == LifecycleChange.CREATE && !Strings.isNullOrEmpty(tenant)) {
            log.info("Tenant {} was created. All its topics and subscriptions will be created.", tenant);
            createPubSubResourceForTenant(tenant, PubSubResourceType.TOPIC);
            createPubSubResourceForTenant(tenant, PubSubResourceType.SUBSCRIPTION);
            subscribeToTenantTopics(tenant);
        } else if (notification.getChange() == LifecycleChange.DELETE && !Strings.isNullOrEmpty(tenant)) {
            log.info("Tenant {} was deleted. All its topics and subscriptions will be deleted.", tenant);
            cleanupPubSubResources(tenant);
        }
    }

    private void cleanupPubSubResources(final String tenant) {
        final String projectId = internalMessagingConfig.getProjectId();
        final List<String> pubSubTopicsToDelete = PubSubConstants.getTenantTopics().stream()
                .map(id -> TopicName.of(projectId, "%s.%s".formatted(tenant, id)).toString()).toList();
        final List<String> pubSubSubscriptionsToDelete = PubSubConstants.getTenantTopics().stream()
                .map(id -> SubscriptionName.of(projectId, "%s.%s".formatted(tenant, id)).toString()).toList();
        PubSubMessageHelper.getCredentialsProvider()
                .ifPresentOrElse(provider -> {
                    final PubSubBasedAdminClientManager pubSubBasedAdminClientManager = new PubSubBasedAdminClientManager(
                            projectId, provider);
                    pubSubBasedAdminClientManager.deleteTopics(pubSubTopicsToDelete);
                    pubSubBasedAdminClientManager.deleteSubscriptions(pubSubSubscriptionsToDelete);
                    log.info("All topics and subscriptions for tenant {} were deleted successfully.", tenant);
                    pubSubBasedAdminClientManager.closeAdminClients();
                }, () -> log.error("credentials provider is empty"));
    }

    private enum PubSubResourceType {
        TOPIC, SUBSCRIPTION
    }
}
