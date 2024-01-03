/*******************************************************************************
 * Copyright (c) 2023 Contributors to the Eclipse Foundation
 *
 * See the NOTICE file(s) distributed with this work for additional
 * information regarding copyright ownership.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0
 *
 * SPDX-License-Identifier: EPL-2.0
 *******************************************************************************/

package org.eclipse.hono.communication.api.service.communication;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.TimeUnit;

import org.eclipse.hono.client.pubsub.PubSubConfigProperties;
import org.eclipse.hono.client.pubsub.PubSubMessageHelper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.api.gax.core.CredentialsProvider;
import com.google.api.gax.rpc.ApiException;
import com.google.api.gax.rpc.NotFoundException;
import com.google.cloud.pubsub.v1.SubscriptionAdminClient;
import com.google.cloud.pubsub.v1.SubscriptionAdminClient.ListSubscriptionsPagedResponse;
import com.google.cloud.pubsub.v1.SubscriptionAdminSettings;
import com.google.cloud.pubsub.v1.TopicAdminClient;
import com.google.cloud.pubsub.v1.TopicAdminClient.ListTopicsPagedResponse;
import com.google.cloud.pubsub.v1.TopicAdminSettings;
import com.google.protobuf.util.Durations;
import com.google.pubsub.v1.ExpirationPolicy;
import com.google.pubsub.v1.ProjectName;
import com.google.pubsub.v1.PushConfig;
import com.google.pubsub.v1.Subscription;
import com.google.pubsub.v1.SubscriptionName;
import com.google.pubsub.v1.Topic;
import com.google.pubsub.v1.TopicName;

import io.vertx.core.CompositeFuture;
import io.vertx.core.Future;
import io.vertx.core.Vertx;

/**
 * A Pub/Sub based admin client manager to manage topics and subscriptions. Wraps a TopicAdminClient and a
 * SubscriptionAdminClient.
 */
public class PubSubBasedAdminClientManager {

    private static final Logger LOG = LoggerFactory.getLogger(PubSubBasedAdminClientManager.class);

    /**
     * The message retention in milliseconds for a Pub/Sub subscription.
     */
    private static final long MESSAGE_RETENTION = 600000;
    private final String projectId;
    private final CredentialsProvider credentialsProvider;
    private final Vertx vertx;
    private SubscriptionAdminClient subscriptionAdminClient;
    private TopicAdminClient topicAdminClient;

    /**
     * Creates a new PubSubBasedAdminClientManager.
     *
     * @param pubSubConfigProperties The Pub/Sub config properties containing the Google project ID.
     * @param credentialsProvider The provider for credentials to use for authenticating to the Pub/Sub service.
     * @param vertx The Vert.x instance to use.
     * @throws NullPointerException if vertx, credentialsProvider or projectId is {@code null}.
     */
    public PubSubBasedAdminClientManager(final PubSubConfigProperties pubSubConfigProperties,
            final CredentialsProvider credentialsProvider, final Vertx vertx) {
        Objects.requireNonNull(pubSubConfigProperties);
        this.projectId = Objects.requireNonNull(pubSubConfigProperties.getProjectId());
        this.credentialsProvider = Objects.requireNonNull(credentialsProvider);
        this.vertx = Objects.requireNonNull(vertx);
    }

    private Future<TopicAdminClient> getOrCreateTopicAdminClient() {
        if (topicAdminClient != null) {
            return Future.succeededFuture(topicAdminClient);
        }
        try {
            final TopicAdminSettings adminSettings = TopicAdminSettings
                    .newBuilder()
                    .setCredentialsProvider(credentialsProvider)
                    .build();
            topicAdminClient = TopicAdminClient.create(adminSettings);
            return Future.succeededFuture(topicAdminClient);
        } catch (IOException e) {
            LOG.error("Error initializing topic admin client: {}", e.getMessage());
            return Future.failedFuture("Error creating topic admin client");
        }
    }

    private Future<SubscriptionAdminClient> getOrCreateSubscriptionAdminClient() {
        if (subscriptionAdminClient != null) {
            return Future.succeededFuture(subscriptionAdminClient);
        }
        try {
            final SubscriptionAdminSettings adminSettings = SubscriptionAdminSettings
                    .newBuilder()
                    .setCredentialsProvider(credentialsProvider)
                    .build();
            subscriptionAdminClient = SubscriptionAdminClient.create(adminSettings);
            return Future.succeededFuture(subscriptionAdminClient);
        } catch (IOException e) {
            LOG.error("Error initializing subscription admin client: {}", e.getMessage());
            return Future.failedFuture("Error creating subscription admin client");
        }
    }

    /**
     * Gets an existing topic or creates a new one on Pub/Sub based on the given topic endpoint and prefix.
     *
     * @param endpoint The endpoint name of the topic, e.g. command_internal.
     * @param prefix The prefix of the topic, e.g. the adapter instance ID.
     * @return A succeeded Future if the topic is successfully created or already exists, or a failed Future if it could
     *         not be created.
     */
    public Future<String> getOrCreateTopic(final String endpoint, final String prefix) {
        final TopicName topicName = TopicName.of(projectId, PubSubMessageHelper.getTopicName(endpoint, prefix));

        return getOrCreateTopicAdminClient()
                .compose(client -> getTopic(topicName, client)
                        .recover(thr -> {
                            if (thr instanceof NotFoundException) {
                                return createTopic(topicName, client);
                            } else {
                                return Future.failedFuture(thr);
                            }
                        }));
    }

    private Future<String> getTopic(final TopicName topicName, final TopicAdminClient client) {
        return vertx.executeBlocking(promise -> {
            try {
                final Topic topic = client.getTopic(topicName);
                promise.complete(topic.getName());
            } catch (ApiException e) {
                promise.fail(e);
            }
        });
    }

    /**
     * Creates a new topic on Pub/Sub based on the given topicName.
     *
     * @param topicName The name of the topic, e.g. tenant.command.
     * @return A succeeded Future if the topic is successfully created or a failed Future if it could not be created.
     */
    public Future<String> createTopic(final TopicName topicName) {
        return getOrCreateTopicAdminClient()
                .compose(client -> createTopic(topicName, client));
    }

    private Future<String> createTopic(final TopicName topicName, final TopicAdminClient client) {
        final Future<String> createdTopic = vertx
                .executeBlocking(promise -> {
                    try {
                        final Topic topic = client.createTopic(topicName);
                        promise.complete(topic.getName());
                    } catch (ApiException e) {
                        promise.fail(e);
                    }
                });
        createdTopic.onSuccess(top -> LOG.info("Topic {} created successfully.", topicName))
                .onFailure(thr -> LOG.warn("Creating topic failed [topic: {}, projectId: {}]", topicName, projectId));
        return createdTopic;
    }

    /**
     * Gets an existing subscription or creates a new one on Pub/Sub based on the given prefix, topic and subscription
     * endpoint.
     *
     * @param topicEndpoint The endpoint name of the topic, e.g. command_internal.
     * @param subscriptionEndpoint The endpoint name of the subscription, e.g. command_internal.
     * @param prefix The prefix of the topic and subscription, e.g. the adapter instance ID.
     * @return A succeeded Future if the subscription is successfully created or already exists, or a failed Future if
     *         it could not be created.
     */
    public Future<String> getOrCreateSubscription(final String topicEndpoint, final String subscriptionEndpoint,
            final String prefix) {
        final String topic = PubSubMessageHelper.getTopicName(topicEndpoint, prefix);
        final String subscription = PubSubMessageHelper.getTopicName(subscriptionEndpoint, prefix);
        final TopicName topicName = TopicName.of(projectId, topic);
        final SubscriptionName subscriptionName = SubscriptionName.of(projectId, subscription);

        return getOrCreateSubscriptionAdminClient()
                .compose(client -> getSubscription(subscriptionName, client)
                        .recover(thr -> {
                            if (thr instanceof NotFoundException) {
                                return createSubscription(subscriptionName, topicName, client);
                            } else {
                                return Future.failedFuture(thr);
                            }
                        }));
    }

    private Future<String> getSubscription(final SubscriptionName subscriptionName,
            final SubscriptionAdminClient client) {
        return vertx.executeBlocking(promise -> {
            try {
                final Subscription subscription = client.getSubscription(subscriptionName);
                promise.complete(subscription.getName());
            } catch (ApiException e) {
                promise.fail(e);
            }
        });
    }

    /**
     * Creates a new subscription on Pub/Sub based on the given subscriptionName and topicName.
     *
     * @param subscriptionName The name of the subscription, e.g. tenant.event.
     * @param topicName The name of the topic, e.g. tenant.event.
     * @return A succeeded Future if the subscription is successfully created or a failed Future if it could not be
     *         created.
     */
    public Future<String> createSubscription(final SubscriptionName subscriptionName, final TopicName topicName) {
        return getOrCreateSubscriptionAdminClient()
                .compose(client -> createSubscription(subscriptionName, topicName, client));
    }

    private Future<String> createSubscription(final SubscriptionName subscriptionName, final TopicName topicName,
            final SubscriptionAdminClient client) {
        final Subscription request = Subscription.newBuilder()
                .setName(subscriptionName.toString())
                .setTopic(topicName.toString())
                .setPushConfig(PushConfig.getDefaultInstance())
                .setMessageRetentionDuration(Durations.fromMillis(MESSAGE_RETENTION))
                .setExpirationPolicy(ExpirationPolicy.getDefaultInstance())
                .build();
        final Future<String> createdSubscription = vertx
                .executeBlocking(promise -> {
                    try {
                        final Subscription subscription = client.createSubscription(request);
                        promise.complete(subscription.getName());
                    } catch (ApiException e) {
                        promise.fail(e);
                    }
                });
        createdSubscription.onSuccess(sub -> LOG.info("Subscription {} created successfully.", subscriptionName))
                .onFailure(
                        thr -> LOG.warn("Creating subscription failed [subscription: {}, topic: {}, project: {}]",
                                subscriptionName, topicName, projectId));
        return createdSubscription;
    }

    /**
     * Updates the topic of a subscription on Pub/Sub based on the given subscriptionName and topicName.
     *
     * @param subscriptionName The name of the subscription, e.g. tenant.command.
     * @param topicName The name of the new topic, e.g. tenant.command.
     * @return A succeeded Future if the topic of the subscription is successfully updated or a failed Future if it
     *         could not be updated.
     */
    public Future<String> updateSubscriptionTopic(final SubscriptionName subscriptionName, final TopicName topicName) {
        return getOrCreateSubscriptionAdminClient()
                .compose(client -> deleteSubscription(subscriptionName, client)
                        .compose(promise -> createSubscription(subscriptionName, topicName, client)))
                .onSuccess(sub -> LOG.info("Subscription {} updated successfully.", sub))
                .onFailure(
                        thr -> LOG.warn("Updating subscription failed [subscription: {}, topic: {}, project: {}]",
                                subscriptionName, topicName, projectId));
    }

    /**
     * Lists subscriptions and adds its names in a set.
     *
     * @return A future containing a set of subscription names.
     */
    public Future<Set<Subscription>> listSubscriptions() {
        return getOrCreateSubscriptionAdminClient()
                .compose(client -> {
                    final Set<Subscription> allSubscriptions = new HashSet<>();
                    final ProjectName projectName = ProjectName.of(projectId);

                    return vertx.executeBlocking(promise -> {
                        try {
                            final ListSubscriptionsPagedResponse pagedResponse = client.listSubscriptions(
                                    projectName);
                            Optional.ofNullable(pagedResponse)
                                    .ifPresent(p -> p.iterateAll().forEach(allSubscriptions::add));
                            promise.complete(allSubscriptions);
                        } catch (Exception e) {
                            LOG.error("Error listing subscriptions on project {}", projectId, e);
                            promise.fail("Error listing subscriptions");
                        }
                    });
                });
    }

    /**
     * Lists topics and adds its names in a set.
     *
     * @return A future containing a set of topic names.
     */
    public Future<Set<String>> listTopics() {
        return getOrCreateTopicAdminClient()
                .compose(client -> {
                    final Set<String> allTopics = new HashSet<>();
                    final ProjectName projectName = ProjectName.of(projectId);

                    return vertx.executeBlocking(promise -> {
                        try {
                            final ListTopicsPagedResponse pagedResponse = client.listTopics(projectName);
                            Optional.ofNullable(pagedResponse)
                                    .ifPresent(
                                            p -> pagedResponse.iterateAll().forEach(t -> allTopics.add(t.getName())));
                            promise.complete(allTopics);
                        } catch (Exception e) {
                            LOG.error("Error listing topics on project {}", projectId, e);
                            promise.fail("Error listing topics");
                        }
                    });
                });
    }

    private Future<Void> deleteTopic(final TopicName topicName, final TopicAdminClient client) {
        return vertx.executeBlocking(promise -> {
            try {
                client.deleteTopic(topicName);
                promise.complete();
            } catch (ApiException e) {
                LOG.warn("Could not delete topic {}", topicName, e);
                promise.fail(e);
            }
        });
    }

    private Future<Void> deleteSubscription(final SubscriptionName subscriptionName,
            final SubscriptionAdminClient client) {
        return vertx.executeBlocking(promise -> {
            try {
                client.deleteSubscription(subscriptionName);
                promise.complete();
            } catch (ApiException e) {
                LOG.warn("Could not delete subscription {}", subscriptionName, e);
                promise.fail(e);
            }
        });
    }

    /**
     * Deletes the topics with the provided names in the list.
     *
     * @param topicsToDelete A list containing the topic names that should be deleted. The list must contain topics with
     *            the format `"projects/{project}/topics/{topic}"`
     * @return A succeeded future if the topics could be deleted successfully, a failed future if an error occurs.
     */
    public Future<CompositeFuture> deleteTopics(final List<String> topicsToDelete) {
        return getOrCreateTopicAdminClient()
                .compose(client -> {
                    final List<Future> futureList = new ArrayList<>();
                    for (final String topic : topicsToDelete) {
                        futureList.add(deleteTopic(TopicName.parse(topic), client));
                    }
                    return CompositeFuture.join(futureList);
                });
    }

    /**
     * Deletes the subscriptions with the provided names in the list.
     *
     * @param subscriptionsToDelete A list containing the subscription names that should be deleted. The list must
     *            contain subscriptions with the format `"projects/{project}/subscriptions/{subscription}"`
     * @return A succeeded future if the subscriptions could be deleted successfully, a failed future if an error
     *         occurs.
     */
    public Future<CompositeFuture> deleteSubscriptions(final List<String> subscriptionsToDelete) {
        return getOrCreateSubscriptionAdminClient()
                .compose(client -> {
                    final List<Future> futureList = new ArrayList<>();
                    for (final String subscription : subscriptionsToDelete) {
                        futureList.add(deleteSubscription(SubscriptionName.parse(subscription), client));
                    }
                    return CompositeFuture.join(futureList);
                });
    }

    /**
     * Closes the TopicAdminClient and the SubscriptionAdminClient if they exist. This method is expected to be invoked
     * as soon as the TopicAdminClient and the SubscriptionAdminClient is no longer needed. This method will block the
     * current thread for up to 10 seconds!
     */
    public void closeAdminClients() {
        closeSubscriptionAdminClient();
        closeTopicAdminClient();
    }

    private void closeSubscriptionAdminClient() {
        if (subscriptionAdminClient != null) {
            subscriptionAdminClient.shutdown();
            try {
                subscriptionAdminClient.awaitTermination(5, TimeUnit.SECONDS);
            } catch (InterruptedException e) {
                LOG.debug("Resources are not freed properly, error", e);
                Thread.currentThread().interrupt();
            }
        }
    }

    private void closeTopicAdminClient() {
        if (topicAdminClient != null) {
            topicAdminClient.shutdown();
            try {
                topicAdminClient.awaitTermination(5, TimeUnit.SECONDS);
            } catch (InterruptedException e) {
                LOG.debug("Resources are not freed properly, error", e);
                Thread.currentThread().interrupt();
            }
        }
    }
}
