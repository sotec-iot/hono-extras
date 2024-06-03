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

import static org.junit.jupiter.api.Assertions.assertInstanceOf;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import org.eclipse.hono.communication.api.config.PubSubConstants;
import org.eclipse.hono.communication.core.app.InternalMessagingConfig;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentMatchers;
import org.mockito.MockedStatic;

import com.google.api.core.ApiFuture;
import com.google.cloud.pubsub.v1.MessageReceiver;
import com.google.cloud.pubsub.v1.Publisher;
import com.google.cloud.pubsub.v1.Subscriber;
import com.google.pubsub.v1.ProjectSubscriptionName;
import com.google.pubsub.v1.PubsubMessage;
import com.google.pubsub.v1.TopicName;

class PubSubBasedInternalMessagingServiceTest {

    private static final String PROJECT_ID = "your-project-id";
    private final String topic = "my-topic";
    private final byte[] message = "Hello world!".getBytes();
    private final Map<String, String> attributes = new HashMap<>();
    private InternalMessagingConfig configMock;
    private Publisher.Builder publisherBuilderMock;
    private Publisher publisherMock;
    private Subscriber.Builder subscriberBuilderMock;
    private Subscriber subscriberMock;
    private MessageReceiver messageReceiverMock;

    @BeforeEach
    void setUp() {
        configMock = mock(InternalMessagingConfig.class);
        publisherBuilderMock = mock(Publisher.Builder.class);
        publisherMock = mock(Publisher.class);
        subscriberBuilderMock = mock(Subscriber.Builder.class);
        subscriberMock = mock(Subscriber.class);
        messageReceiverMock = mock(MessageReceiver.class);
        when(configMock.getProjectId()).thenReturn(PROJECT_ID);
    }

    @AfterEach
    void tearDown() {
        verifyNoMoreInteractions(configMock, publisherBuilderMock, publisherMock, subscriberBuilderMock, subscriberMock,
                messageReceiverMock);
    }

    @Test
    void testPublishSuccessful() throws Exception {

        attributes.put("key1", "value1");

        try (MockedStatic<Publisher> publisherMockedStatic = mockStatic(Publisher.class)) {

            final Publisher.Builder builderMock = mock(Publisher.Builder.class);

            final ApiFuture<String> mockedApiFuture = mock(ApiFuture.class);
            publisherMockedStatic.when(() -> Publisher.newBuilder(ArgumentMatchers.any(TopicName.class)))
                    .thenReturn(builderMock);

            when(builderMock.build()).thenReturn(publisherMock);
            when(publisherMock.publish(ArgumentMatchers.any(PubsubMessage.class))).thenReturn(mockedApiFuture);
            when(mockedApiFuture.get()).thenReturn("message-id");

            final PubSubBasedInternalMessagingService pubSubService = new PubSubBasedInternalMessagingService(
                    configMock);
            Exception exception = null;
            try {
                pubSubService.publish(topic, message, attributes);
            } catch (Exception e) {
                exception = e;
            }

            assertNull(exception);
            verify(configMock).getProjectId();
            verify(publisherMock).shutdown();
            verify(publisherMock).publish(ArgumentMatchers.any(PubsubMessage.class));
            verify(publisherMock).awaitTermination(1, TimeUnit.MINUTES);
            publisherMockedStatic.verify(() -> Publisher.newBuilder(ArgumentMatchers.any(TopicName.class)));
            publisherMockedStatic.verifyNoMoreInteractions();
        }

    }

    @Test
    void testPublish_failed_null_pubSub_message() throws Exception {
        attributes.put("key1", "value1");

        try (MockedStatic<Publisher> publisherMockedStatic = mockStatic(Publisher.class)) {
            try (MockedStatic<PubsubMessage> pubsubMessageMockedStatic = mockStatic(PubsubMessage.class)) {

                final Publisher.Builder builderMock = mock(Publisher.Builder.class);

                final ApiFuture<String> mockedApiFuture = mock(ApiFuture.class);
                publisherMockedStatic.when(() -> Publisher.newBuilder(ArgumentMatchers.any(TopicName.class)))
                        .thenReturn(builderMock);

                when(builderMock.build()).thenReturn(publisherMock);
                when(publisherMock.publish(ArgumentMatchers.any(PubsubMessage.class))).thenReturn(mockedApiFuture);
                when(mockedApiFuture.get()).thenReturn("message-id");

                final PubSubBasedInternalMessagingService pubSubService = new PubSubBasedInternalMessagingService(
                        configMock);
                Exception exception = null;
                try {
                    pubSubService.publish(topic, message, attributes);
                } catch (Exception e) {
                    exception = e;
                }

                assertInstanceOf(NullPointerException.class, exception);
                verify(configMock).getProjectId();
                verify(publisherMock).shutdown();
                verify(publisherMock).awaitTermination(1, TimeUnit.MINUTES);
                publisherMockedStatic.verify(() -> Publisher.newBuilder(ArgumentMatchers.any(TopicName.class)));
                pubsubMessageMockedStatic.verify(PubsubMessage::newBuilder);
                publisherMockedStatic.verifyNoMoreInteractions();
                pubsubMessageMockedStatic.verifyNoMoreInteractions();
            }
        }

    }

    @Test
    void testSubscribe_success() {
        try (MockedStatic<Subscriber> subscriberMockedStatic = mockStatic(Subscriber.class)) {
            final String subscription = String.format(PubSubConstants.COMMUNICATION_API_SUBSCRIPTION_NAME, topic);
            subscriberMockedStatic
                    .when(() -> Subscriber.newBuilder(ArgumentMatchers.any(ProjectSubscriptionName.class),
                            ArgumentMatchers.any(MessageReceiver.class)))
                    .thenReturn(subscriberBuilderMock);
            when(subscriberBuilderMock.build()).thenReturn(subscriberMock);
            when(subscriberMock.startAsync()).thenReturn(subscriberMock);
            final PubSubBasedInternalMessagingService pubSubService = new PubSubBasedInternalMessagingService(
                    configMock);

            final Subscriber subscriber = pubSubService.subscribe(subscription, messageReceiverMock);

            assertInstanceOf(Subscriber.class, subscriber);
            verify(configMock).getProjectId();
            subscriberMockedStatic.verify(
                    () -> Subscriber.newBuilder((ProjectSubscriptionName) any(), (MessageReceiver) any()));
            verify(subscriberMock, times(1)).startAsync();
            verify(subscriberMock, times(1)).awaitRunning();
            verify(subscriberBuilderMock).build();
            subscriberMockedStatic.verifyNoMoreInteractions();
        }
    }

    @Test
    void testSubscribe_failed() {
        try (MockedStatic<Subscriber> subscriberMockedStatic = mockStatic(Subscriber.class)) {
            final String subscription = String.format(PubSubConstants.COMMUNICATION_API_SUBSCRIPTION_NAME, topic);
            subscriberMockedStatic
                    .when(() -> Subscriber.newBuilder(ArgumentMatchers.any(ProjectSubscriptionName.class),
                            ArgumentMatchers.any(MessageReceiver.class)))
                    .thenReturn(subscriberBuilderMock);
            when(subscriberBuilderMock.build()).thenReturn(subscriberMock);
            doThrow(new IllegalStateException()).when(subscriberMock).startAsync();
            final PubSubBasedInternalMessagingService pubSubService = new PubSubBasedInternalMessagingService(
                    configMock);

            final var subscriber = pubSubService.subscribe(subscription, messageReceiverMock);

            assertNull(subscriber);
            verify(configMock, times(1)).getProjectId();
            verify(subscriberBuilderMock, times(1)).build();
            verify(subscriberMock, times(1)).startAsync();
            subscriberMockedStatic.verify(
                    () -> Subscriber.newBuilder((ProjectSubscriptionName) any(), (MessageReceiver) any()));
            subscriberMockedStatic.verifyNoMoreInteractions();
        }
    }
}
