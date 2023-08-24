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

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
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
import org.eclipse.hono.communication.core.utils.StringUtils;
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
    private final CommandAckService commandAckService;
    private final Vertx vertx;
    private final Random random;

    /**
     * Creates a new DeviceCommandServiceImpl.
     *
     * @param deviceRepository The device repository interface
     * @param internalMessaging The internal messaging interface
     * @param messagingConfig The internal messaging configs
     * @param configTopicEventHandler The config topic event handler
     * @param commandAckService The command acknowledgement service
     * @param vertx The Vert.x instance
     * @param random A Random object to create random numbers
     */
    public DeviceCommandServiceImpl(final DeviceRepository deviceRepository,
            final InternalMessaging internalMessaging,
            final InternalMessagingConfig messagingConfig,
            final ConfigTopicEventHandler configTopicEventHandler,
            final CommandAckService commandAckService,
            final Vertx vertx, final Random random) {

        super(messagingConfig, internalMessaging);
        this.deviceRepository = deviceRepository;
        this.configTopicEventHandler = configTopicEventHandler;
        this.commandAckService = commandAckService;
        this.vertx = vertx;
        this.random = random;
    }

    @Override
    public Future<Void> postCommand(final DeviceCommandRequest commandRequest, final String tenantId,
            final String deviceId) {

        if (!StringUtils.isBase64(commandRequest.getBinaryData())) {
            return Future
                    .failedFuture(
                            new IllegalStateException("Field binaryData type should be a base64 encoded String."));
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

                            try {
                                final var command = Base64.decodeBase64(commandRequest.getBinaryData().getBytes());
                                if (!commandRequest.isResponseRequired() && commandRequest.isAckRequired()) {
                                    return publishAckRequiredCommand(commandRequest, command, topic, tenantId, deviceId,
                                            subject);
                                } else {
                                    return publishCommand(commandRequest, command, topic, tenantId, deviceId, subject);
                                }
                            } catch (Exception ex) {
                                log.warn("Command can't be published: {}", ex.getMessage());
                                if (ex instanceof InterruptedException) {
                                    Thread.currentThread().interrupt();
                                }
                                return Future.failedFuture(ex);
                            }
                        });
    }

    private Future<Void> publishAckRequiredCommand(final DeviceCommandRequest commandRequest, final byte[] command,
            final String topic, final String tenantId, final String deviceId, final String subject)
            throws InterruptedException, IOException, NullPointerException {
        final Promise<Void> promise = Promise.promise();
        if (commandRequest.getCorrelationId() == null) {
            commandRequest.setCorrelationId(random.nextLong(1000, 999999));
        }
        final String correlationId = String.valueOf(commandRequest.getCorrelationId());
        final Map<String, String> attributes = Map.of(InternalMessagingConstants.DEVICE_ID, deviceId,
                InternalMessagingConstants.TENANT_ID, tenantId,
                InternalMessagingConstants.SUBJECT, subject,
                InternalMessagingConstants.CORRELATION_ID, correlationId,
                InternalMessagingConstants.ACK_REQUIRED,
                String.valueOf(commandRequest.isAckRequired()));
        commandAckService.put(tenantId, deviceId, correlationId, promise);
        internalMessaging.publish(topic, command, attributes);
        vertx.setTimer(Optional.ofNullable(commandRequest.getTimeout())
                .orElse(messagingConfig.getCommandDefaultAckTimeout()), id -> {
                    if (!promise.future().succeeded()) {
                        log.info(
                                "Timeout exceeded. Fail promise for command with tenant {}, device {}, correlationID {}",
                                tenantId, deviceId, correlationId);
                        promise.fail(new DeviceNotAvailableException(
                                "The device did not acknowledge the command in time. " +
                                        "This might indicate that the device is not connected."));
                        commandAckService.remove(tenantId, deviceId, correlationId);
                    }
                });
        log.info("Command {} was published successfully to topic {}", command, topic);
        return promise.future();
    }

    private Future<Void> publishCommand(final DeviceCommandRequest commandRequest, final byte[] command,
            final String topic, final String tenantId, final String deviceId, final String subject)
            throws InterruptedException, IOException {
        final Map<String, String> attributes = new HashMap<>();
        attributes.put(InternalMessagingConstants.DEVICE_ID, deviceId);
        attributes.put(InternalMessagingConstants.TENANT_ID, tenantId);
        attributes.put(InternalMessagingConstants.SUBJECT, subject);
        if (commandRequest.isResponseRequired()) {
            if (commandRequest.getCorrelationId() == null) {
                commandRequest.setCorrelationId(random.nextLong(1000, 999999));
            }
            attributes.put(InternalMessagingConstants.CORRELATION_ID,
                    String.valueOf(commandRequest.getCorrelationId()));
            attributes.put(InternalMessagingConstants.RESPONSE_REQUIRED,
                    String.valueOf(commandRequest.isResponseRequired()));
        }
        internalMessaging.publish(topic, command, attributes);
        log.info("Command {} was published successfully to topic {}", command, topic);
        return Future.succeededFuture();
    }

    private boolean isAckResponse(final Map<String, String> messageAttributes) {
        return Objects.equals(messageAttributes.get(messagingConfig.getContentTypeKey()),
                InternalMessagingConstants.DELIVERY_SUCCESS_NOTIFICATION_CONTENT_TYPE);
    }

    @Override
    public void onDeviceCommandResponse(final PubsubMessage pubsubMessage, final AckReplyConsumer consumer) {
        consumer.ack();
        final var messageAttributes = pubsubMessage.getAttributesMap();

        if (!isAckResponse(messageAttributes)) {
            return;
        }
        if (isConfigResponse(messageAttributes)) {
            onDeviceConfigAckResponse(messageAttributes);
            return;
        }
        onDeviceCommandAckResponse(messageAttributes);
    }

    private boolean isConfigResponse(final Map<String, String> messageAttributes) {
        return Objects.equals(messageAttributes.get(InternalMessagingConstants.SUBJECT),
                DeviceConfigsConstants.CONFIG_SUBJECT);
    }

    private void onDeviceConfigAckResponse(final Map<String, String> messageAttributes) {
        completePromise(messageAttributes);
        configTopicEventHandler.onDeviceConfigAckResponse(messageAttributes);
    }

    private void onDeviceCommandAckResponse(final Map<String, String> messageAttributes) {
        completePromise(messageAttributes);
    }

    private void completePromise(final Map<String, String> messageAttributes) {
        final String tenantId = messageAttributes.get(InternalMessagingConstants.TENANT_ID);
        final String deviceId = messageAttributes.get(InternalMessagingConstants.DEVICE_ID);
        final String correlationId = messageAttributes.get(InternalMessagingConstants.CORRELATION_ID);
        final Promise<Void> promise = commandAckService.remove(tenantId, deviceId, correlationId);
        if (promise != null && !promise.future().isComplete()) {
            promise.complete();
        }
    }
}
