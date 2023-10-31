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

package org.eclipse.hono.communication.api.service.command;

import java.util.Map;
import java.util.Objects;
import java.util.Random;

import org.apache.commons.codec.binary.Base64;
import org.eclipse.hono.communication.api.config.DeviceConfigsConstants;
import org.eclipse.hono.communication.api.data.DeviceCommandRequest;
import org.eclipse.hono.communication.api.exception.DeviceNotAvailableException;
import org.eclipse.hono.communication.api.exception.DeviceNotFoundException;
import org.eclipse.hono.communication.api.handler.CommandTopicEventHandler;
import org.eclipse.hono.communication.api.handler.ConfigTopicEventHandler;
import org.eclipse.hono.communication.api.repository.DeviceRepository;
import org.eclipse.hono.communication.api.service.DeviceServiceAbstract;
import org.eclipse.hono.communication.api.service.communication.InternalMessaging;
import org.eclipse.hono.communication.core.app.InternalMessagingConfig;
import org.eclipse.hono.communication.core.app.InternalMessagingConstants;
import org.eclipse.hono.communication.core.utils.StringValidateUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.cloud.pubsub.v1.AckReplyConsumer;
import com.google.common.base.Strings;
import com.google.pubsub.v1.PubsubMessage;

import io.vertx.core.Future;
import io.vertx.core.Promise;
import io.vertx.core.Vertx;
import jakarta.inject.Singleton;

/**
 * Service for device commands.
 */
@Singleton
public class DeviceCommandServiceImpl extends DeviceServiceAbstract
        implements DeviceCommandService, CommandTopicEventHandler {

    private final Logger log = LoggerFactory.getLogger(DeviceCommandServiceImpl.class);
    private final DeviceRepository deviceRepository;
    private final ConfigTopicEventHandler configTopicEventHandler;
    private final Vertx vertx;
    private final Random random;

    /**
     * Creates a new DeviceCommandServiceImpl.
     *
     * @param deviceRepository The device repository interface
     * @param internalMessaging The internal messaging interface
     * @param messagingConfig The internal messaging configs
     * @param configTopicEventHandler The config topic event handler
     * @param vertx The vertx instance
     * @param random A Random object to create random numbers
     */
    public DeviceCommandServiceImpl(final DeviceRepository deviceRepository,
            final InternalMessaging internalMessaging,
            final InternalMessagingConfig messagingConfig,
            final ConfigTopicEventHandler configTopicEventHandler,
            final Vertx vertx, final Random random) {

        super(messagingConfig, internalMessaging);
        this.deviceRepository = deviceRepository;
        this.configTopicEventHandler = configTopicEventHandler;
        this.vertx = vertx;
        this.random = random;
    }

    @Override
    public Future<Void> postCommand(final DeviceCommandRequest commandRequest, final String tenantId,
            final String deviceId) {

        if (!StringValidateUtils.isBase64(commandRequest.getBinaryData())) {
            return Future
                    .failedFuture(new IllegalStateException("Field binaryData type should be String base64 encoded."));
        }

        return deviceRepository.searchForDevice(deviceId, tenantId, null)
                .compose(
                        counter -> {

                            if (counter < 1) {
                                throw new DeviceNotFoundException(
                                        String.format("Device with id %s and tenant id %s doesn't exist",
                                                deviceId,
                                                tenantId));
                            }
                            final String subject = Strings.isNullOrEmpty(commandRequest.getSubfolder()) ? "command"
                                    : commandRequest.getSubfolder();
                            final var topic = String.format(messagingConfig.getCommandTopicFormat(), tenantId);
                            final Map<String, String> attributes;

                            try {
                                final var command = Base64.decodeBase64(commandRequest.getBinaryData().getBytes());
                                if (commandRequest.isResponseRequired()) {
                                    if (commandRequest.getCorrelationId() == null) {
                                        commandRequest.setCorrelationId(random.nextLong(1000, 999999));
                                    }
                                    final Promise<Void> promise = Promise.promise();
                                    final long failId = vertx.setTimer(messagingConfig.getCommandConfigAckDelay() + 500,
                                            i -> promise.fail(new DeviceNotAvailableException(
                                                    String.format("Device %s not available.", deviceId))));
                                    final long successId = vertx.setTimer(messagingConfig.getCommandConfigAckDelay(),
                                            i -> {
                                                vertx.cancelTimer(failId);
                                                promise.complete();
                                            });

                                    attributes = Map.of(InternalMessagingConstants.DEVICE_ID, deviceId,
                                            InternalMessagingConstants.TENANT_ID, tenantId,
                                            InternalMessagingConstants.SUBJECT, subject,
                                            InternalMessagingConstants.RESPONSE_REQUIRED,
                                            String.valueOf(commandRequest.isResponseRequired()),
                                            InternalMessagingConstants.CORRELATION_ID,
                                            String.valueOf(commandRequest.getCorrelationId()),
                                            InternalMessagingConstants.DELIVERY_FAILURE_NOTIFICATION_METADATA_TASK_ID,
                                            String.valueOf(successId));
                                    internalMessaging.publish(topic, command, attributes);
                                    return promise.future();
                                } else {
                                    attributes = Map.of(InternalMessagingConstants.DEVICE_ID, deviceId,
                                            InternalMessagingConstants.TENANT_ID, tenantId,
                                            InternalMessagingConstants.SUBJECT, subject);
                                    internalMessaging.publish(topic, command, attributes);
                                    log.info("Command {} was published successfully to topic {}", command, topic);
                                    return Future.succeededFuture();
                                }
                            } catch (Exception ex) {
                                log.error("Command can't be published: {}", ex.getMessage());
                                return Future.failedFuture(ex);
                            }
                        });
    }

    @Override
    public void onDeviceCommandResponse(final PubsubMessage pubsubMessage, final AckReplyConsumer consumer) {
        consumer.ack(); // message was received and processed only once

        final var messageAttributes = pubsubMessage.getAttributesMap();

        if (!isErrorResponse(messageAttributes)) {
            return;
        }
        if (isConfigErrorResponse(messageAttributes)) {
            configTopicEventHandler.onDeviceConfigErrorResponse(pubsubMessage);
        } else {
            onDeviceCommandErrorResponse(messageAttributes);
        }
    }

    private boolean isErrorResponse(final Map<String, String> messageAttributes) {
        return Objects.equals(messageAttributes.get(messagingConfig.getContentTypeKey()),
                messagingConfig.getDeliveryFailureNotificationContentType());
    }

    private boolean isConfigErrorResponse(final Map<String, String> messageAttributes) {
        return messageAttributes.containsKey(InternalMessagingConstants.DELIVERY_FAILURE_NOTIFICATION_METADATA_SUBJECT)
                && Objects.equals(
                        messageAttributes
                                .get(InternalMessagingConstants.DELIVERY_FAILURE_NOTIFICATION_METADATA_SUBJECT),
                        DeviceConfigsConstants.CONFIG_SUBJECT);
    }

    private void onDeviceCommandErrorResponse(final Map<String, String> messageAttributes) {
        if (messageAttributes.containsKey(InternalMessagingConstants.DELIVERY_FAILURE_NOTIFICATION_METADATA_TASK_ID)) {
            vertx.cancelTimer(Long.parseLong(
                    messageAttributes.get(InternalMessagingConstants.DELIVERY_FAILURE_NOTIFICATION_METADATA_TASK_ID)));
        }
    }
}
