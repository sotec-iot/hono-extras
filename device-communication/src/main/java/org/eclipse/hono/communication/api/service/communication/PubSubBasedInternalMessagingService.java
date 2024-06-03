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

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import org.eclipse.hono.communication.api.config.PubSubConstants;
import org.eclipse.hono.communication.core.app.InternalMessagingConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.api.core.ApiFuture;
import com.google.api.core.ApiFutureCallback;
import com.google.api.core.ApiFutures;
import com.google.cloud.pubsub.v1.MessageReceiver;
import com.google.cloud.pubsub.v1.Publisher;
import com.google.cloud.pubsub.v1.Subscriber;
import com.google.common.util.concurrent.MoreExecutors;
import com.google.protobuf.ByteString;
import com.google.pubsub.v1.ProjectSubscriptionName;
import com.google.pubsub.v1.PubsubMessage;
import com.google.pubsub.v1.TopicName;

import jakarta.annotation.PreDestroy;
import jakarta.enterprise.context.ApplicationScoped;

/**
 * Pub/Sub based internal messaging service.
 */
@ApplicationScoped
public class PubSubBasedInternalMessagingService implements InternalMessaging {

    private final Logger log = LoggerFactory.getLogger(PubSubBasedInternalMessagingService.class);
    private final Map<String, Subscriber> activeSubscriptions = new HashMap<>();

    private final String projectId;

    /**
     * Creates a new PubSubBasedInternalMessagingService.
     *
     * @param config The internal messaging config
     */
    public PubSubBasedInternalMessagingService(final InternalMessagingConfig config) {
        this.projectId = config.getProjectId();
    }

    /**
     * Stops every subscription at destroy time.
     */
    @PreDestroy
    void destroy() {
        activeSubscriptions.forEach((topic, subscriber) -> closeSubscriber(subscriber));
        activeSubscriptions.clear();
    }

    private void closeSubscriber(final Subscriber subscriber) {
        if (subscriber != null) {
            subscriber.stopAsync();
            try {
                subscriber.awaitTerminated(30, TimeUnit.SECONDS);
            } catch (TimeoutException e) {
                throw new RuntimeException(e);
            }
        }
    }

    @Override
    public void publish(final String topic, final byte[] message, final Map<String, String> attributes)
            throws IOException, InterruptedException {
        final Publisher publisher = Publisher.newBuilder(TopicName.of(projectId, topic))
                .build();
        try {
            final var data = ByteString.copyFrom(message);
            final var pubsubMessage = PubsubMessage
                    .newBuilder()
                    .setData(data)
                    .putAllAttributes(attributes)
                    .build();
            final ApiFuture<String> messageIdFuture = publisher.publish(pubsubMessage);
            ApiFutures.addCallback(messageIdFuture, new ApiFutureCallback<>() {

                public void onSuccess(final String messageId) {
                    log.debug("Message was published with id {}", messageId);
                }

                public void onFailure(final Throwable t) {
                    log.error("failed to publish: {}", t.getMessage());
                }
            }, MoreExecutors.directExecutor());
        } finally {
            publisher.shutdown();
            publisher.awaitTermination(1, TimeUnit.MINUTES);
        }
    }

    @Override
    public Subscriber subscribe(final String subscription, final MessageReceiver callbackHandler) {
        if (activeSubscriptions.containsKey(subscription)) {
            return activeSubscriptions.get(subscription);
        }
        final ProjectSubscriptionName subscriptionName;
        try {
            subscriptionName = ProjectSubscriptionName.of(
                    projectId,
                    subscription);
            final Subscriber subscriber = Subscriber.newBuilder(subscriptionName, callbackHandler).build();
            subscriber.startAsync().awaitRunning();
            activeSubscriptions.put(subscription, subscriber);
            log.info("Successfully subscribed on subscription: {}.", subscription);
            return subscriber;
        } catch (Exception ex) {
            log.error("Error subscribing on subscription: {}: {}", subscription, ex.getMessage());
            return null;
        }
    }

    @Override
    public void closeSubscribersForTenant(final String tenant) {
        for (String endpoint : PubSubConstants.getEndpointsWithAdditionalSubscription()) {
            final String subscription = String.format(PubSubConstants.COMMUNICATION_API_SUBSCRIPTION_NAME,
                    String.format("%s.%s", tenant, endpoint));
            final Subscriber subscriber = activeSubscriptions.get(subscription);
            closeSubscriber(subscriber);
        }
    }
}
