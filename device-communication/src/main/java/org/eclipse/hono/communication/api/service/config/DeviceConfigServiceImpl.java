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

package org.eclipse.hono.communication.api.service.config;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Objects;

import org.apache.commons.codec.binary.Base64;
import org.eclipse.hono.communication.api.config.ApiCommonConstants;
import org.eclipse.hono.communication.api.config.DeviceConfigsConstants;
import org.eclipse.hono.communication.api.data.DeviceConfig;
import org.eclipse.hono.communication.api.data.DeviceConfigRequest;
import org.eclipse.hono.communication.api.data.ListDeviceConfigVersionsResponse;
import org.eclipse.hono.communication.api.handler.ConfigTopicEventHandler;
import org.eclipse.hono.communication.api.mapper.DeviceConfigMapper;
import org.eclipse.hono.communication.api.repository.DeviceConfigRepository;
import org.eclipse.hono.communication.api.service.DeviceServiceAbstract;
import org.eclipse.hono.communication.api.service.command.CommandAckService;
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
 * Service for device configurations.
 */

@Singleton
public class DeviceConfigServiceImpl extends DeviceServiceAbstract
        implements DeviceConfigService, ConfigTopicEventHandler {

    private static final String DEVICE_CONNECTION_TTD = "-1";
    private static final long MAX_ACK_WAIT_TIME_WITHOUT_RETRY = 30000L;
    private static final int MAX_NUMBER_RETRIES = 10;
    private static final long MAX_RETRY_DELAY = 300000L;

    private final Logger log = LoggerFactory.getLogger(DeviceConfigServiceImpl.class);
    private final DeviceConfigRepository repository;
    private final DeviceConfigMapper mapper;
    private final CommandAckService commandAckService;
    private final Vertx vertx;

    /**
     * Creates a new DeviceConfigServiceImpl.
     *
     * @param repository The device config repository
     * @param mapper The device config mapper
     * @param internalMessagingConfig The internal messaging config
     * @param internalMessaging The internal messaging interface
     * @param commandAckService The command acknowledgement service
     * @param vertx The Vert.x instance
     */
    public DeviceConfigServiceImpl(final DeviceConfigRepository repository,
            final DeviceConfigMapper mapper,
            final InternalMessagingConfig internalMessagingConfig,
            final InternalMessaging internalMessaging, final CommandAckService commandAckService, final Vertx vertx) {

        super(internalMessagingConfig, internalMessaging);

        this.repository = repository;
        this.mapper = mapper;
        this.commandAckService = commandAckService;
        this.vertx = vertx;
    }

    @Override
    public Future<DeviceConfig> modifyCloudToDeviceConfig(final DeviceConfigRequest deviceConfig, final String deviceId,
            final String tenantId) {

        if (!StringUtils.isBase64(deviceConfig.getBinaryData())) {
            return Future
                    .failedFuture(
                            new IllegalStateException("Field binaryData type should be a base64 encoded String."));
        }

        final var entity = mapper.configRequestToDeviceConfigEntity(deviceConfig);
        entity.setDeviceId(deviceId);
        entity.setTenantId(tenantId);

        return repository.createNew(entity)
                .map(mapper::deviceConfigEntityToConfig)
                .onSuccess(result -> {
                    final var topicToPublish = String.format(messagingConfig.getCommandTopicFormat(),
                            entity.getTenantId());
                    final var retries = 0;
                    final var messageAttributes = Map.of(
                            InternalMessagingConstants.DEVICE_ID, entity.getDeviceId(),
                            InternalMessagingConstants.TENANT_ID, entity.getTenantId(),
                            InternalMessagingConstants.CORRELATION_ID, result.getVersion(),
                            InternalMessagingConstants.SUBJECT, DeviceConfigsConstants.CONFIG_SUBJECT,
                            InternalMessagingConstants.RESPONSE_REQUIRED, "false",
                            InternalMessagingConstants.ACK_REQUIRED, "true");
                    publish(topicToPublish, result, messageAttributes, retries, MAX_ACK_WAIT_TIME_WITHOUT_RETRY);
                });
    }

    @Override
    public Future<ListDeviceConfigVersionsResponse> listAll(final String deviceId, final String tenantId,
            final int limit) {
        return repository.listAll(deviceId, tenantId, limit)
                .map(
                        result -> {
                            final var listConfig = new ListDeviceConfigVersionsResponse();
                            listConfig.setDeviceConfigs(result);
                            return listConfig;
                        });
    }

    @Override
    public void onDeviceConfigAckResponse(final Map<String, String> pubsubMessageAttributes) {
        final String deviceId = pubsubMessageAttributes.get(InternalMessagingConstants.DEVICE_ID);
        final String tenantId = pubsubMessageAttributes.get(InternalMessagingConstants.TENANT_ID);
        final String version = pubsubMessageAttributes.get(InternalMessagingConstants.CORRELATION_ID);
        if (Strings.isNullOrEmpty(deviceId) || Strings.isNullOrEmpty(tenantId) || Strings.isNullOrEmpty(version)) {
            log.warn("Cannot acknowledge config. tenantId ({}), deviceId ({}) or version ({}) is null or empty.",
                    tenantId, deviceId, version);
            return;
        }
        try {
            updateDeviceAckTime(tenantId, deviceId, Integer.parseInt(version), Instant.now().toString());
        } catch (NumberFormatException e) {
            log.warn(
                    "Acknowledgement of config for tenant {} and device {} failed due to an illegal config version: {}",
                    tenantId, deviceId, version, e);
        }
    }

    private void updateDeviceAckTime(final String tenantId, final String deviceId, final int configVersion,
            final String deviceAckTime) {
        repository.updateDeviceAckTime(tenantId, deviceId, configVersion, deviceAckTime)
                .onSuccess(ok -> log.info(
                        "Successfully updated device acknowledged time for config version {} for device {} in tenant {}",
                        configVersion, deviceId, tenantId));
    }

    @Override
    public void onDeviceConfigRequest(final PubsubMessage pubsubMessage, final AckReplyConsumer consumer) {

        consumer.ack(); // message was received and processed only once

        final Map<String, String> messageAttributes = pubsubMessage.getAttributesMap();
        final String deviceId = messageAttributes.get(ApiCommonConstants.DEVICE_ID_CAPTION);
        final String tenantId = messageAttributes.get(ApiCommonConstants.TENANT_ID_CAPTION);

        if (!isConfigRequest(messageAttributes, tenantId, deviceId)) {
            return;
        }

        repository.getDeviceLatestConfig(tenantId, deviceId)
                .onSuccess(res -> {
                    final DeviceConfig config = mapper.deviceConfigEntityToConfig(res);
                    final String topicToPublish = String.format(messagingConfig.getCommandTopicFormat(), tenantId);
                    final Map<String, String> attributes = createAttributesMap(config, deviceId, tenantId);
                    log.debug("Handle config request event");
                    publish(topicToPublish, config, attributes, messagingConfig.getConfigOnDeviceRequestRetries(),
                            messagingConfig.getConfigInternalRetryDelay());
                })
                .onFailure(err -> {
                    final String logMessage = "Cannot publish config: " + err.getMessage();
                    if (err instanceof NoSuchElementException) {
                        log.debug(logMessage);
                    } else {
                        log.error(logMessage);
                    }
                });
    }

    private Map<String, String> createAttributesMap(final DeviceConfig config, final String deviceId,
            final String tenantId) {
        final Map<String, String> attributes = new HashMap<>();
        attributes.put(InternalMessagingConstants.CORRELATION_ID, config.getVersion());
        attributes.put(InternalMessagingConstants.DEVICE_ID, deviceId);
        attributes.put(InternalMessagingConstants.TENANT_ID, tenantId);
        attributes.put(InternalMessagingConstants.SUBJECT, DeviceConfigsConstants.CONFIG_SUBJECT);
        attributes.put(InternalMessagingConstants.RESPONSE_REQUIRED, "false");
        attributes.put(InternalMessagingConstants.ACK_REQUIRED, "true");
        return attributes;
    }

    private boolean isConfigRequest(final Map<String, String> messageAttributes, final String tenantId,
            final String deviceId) {
        if (Strings.isNullOrEmpty(deviceId) || Strings.isNullOrEmpty(tenantId)) {
            log.warn("Skip device onConnect event: deviceId or tenantId is empty");
            return false;
        }
        if (!isMqttConfigRequest(messageAttributes) && !isHttpConfigRequest(messageAttributes)) {
            log.debug("Skip device event");
            return false;
        }
        return true;
    }

    private boolean isMqttConfigRequest(final Map<String, String> messageAttributes) {
        return Objects.equals(messageAttributes.get(messagingConfig.getContentTypeKey()),
                InternalMessagingConstants.EMPTY_NOTIFICATION_EVENT_CONTENT_TYPE) &&
                Objects.equals(messageAttributes.get(messagingConfig.getTtdKey()), DEVICE_CONNECTION_TTD);
    }

    private boolean isHttpConfigRequest(final Map<String, String> messageAttributes) {
        return Objects.equals(messageAttributes.get(messagingConfig.getOrigAdapterKey()), "hono-http")
                && !messageAttributes.get(messagingConfig.getTtdKey()).isBlank()
                && messageAttributes.get(messagingConfig.getOrigAddressKey())
                        .contains(DeviceConfigsConstants.CONFIG_SUBJECT);
    }

    private void publish(final String topicToPublish, final DeviceConfig deviceConfig,
            final Map<String, String> attributes, final int retries, final long initialRetryDelay) {
        final var context = vertx.getOrCreateContext();
        context.executeBlocking(promise -> {
            try {
                final Promise<Void> ackReceived = Promise.promise();
                final var configPayload = Base64.decodeBase64(deviceConfig.getBinaryData().getBytes());
                final var tenantId = attributes.get(InternalMessagingConstants.TENANT_ID);
                final var deviceId = attributes.get(InternalMessagingConstants.DEVICE_ID);
                final var configVersion = deviceConfig.getVersion();
                final Promise<Void> commandPromise = commandAckService.put(tenantId, deviceId, configVersion,
                        ackReceived);
                if (commandPromise != null) {
                    commandPromise.fail("Got new config request");
                }
                internalMessaging.publish(topicToPublish, configPayload, attributes);
                final int retriesWithUpperBound = Math.min(retries, MAX_NUMBER_RETRIES);
                initRetry(retriesWithUpperBound, initialRetryDelay, ackReceived, topicToPublish, configPayload,
                        attributes);
                log.info("Publish device config (tenant {}, device {}, version {}) with {} retries", tenantId, deviceId,
                        configVersion, retriesWithUpperBound);
            } catch (Exception ex) {
                log.error("Error serializing config {}", deviceConfig);
                if (ex instanceof InterruptedException) {
                    Thread.currentThread().interrupt();
                }
            } finally {
                promise.complete();
            }
        });
    }

    private void initRetry(final int retries, final long initialDelay, final Promise<Void> ackReceived,
            final String topicToPublish, final byte[] configPayload,
            final Map<String, String> attributes) {
        retry(retries, initialDelay, 0, ackReceived, topicToPublish, configPayload, attributes);
    }

    private void retry(final int retries, final long delay, final int retryAttempt, final Promise<Void> ackReceived,
            final String topicToPublish, final byte[] configPayload,
            final Map<String, String> attributes) {
        vertx.setTimer(delay, timerId -> {
            try {
                if (!ackReceived.future().isComplete()) {
                    if (retryAttempt < retries) {
                        internalMessaging.publish(topicToPublish, configPayload, attributes);
                        retry(retries, Math.min(delay * 2, MAX_RETRY_DELAY), retryAttempt + 1, ackReceived,
                                topicToPublish, configPayload,
                                attributes);
                    } else {
                        ackReceived.fail("Max retries reached. No acknowledgement received.");
                        final String tenantId = attributes.get(InternalMessagingConstants.TENANT_ID);
                        final String deviceId = attributes.get(InternalMessagingConstants.DEVICE_ID);
                        final String configVersion = attributes.get(InternalMessagingConstants.CORRELATION_ID);
                        log.info(
                                "Max retries reached. No acknowledgement received for config version {} of device" +
                                        "with tenantId {} and deviceId {}.",
                                configVersion, tenantId, deviceId);
                        commandAckService.remove(tenantId, deviceId, configVersion);
                    }
                }
            } catch (Exception e) {
                log.error("Exception during retry of publishing a config", e);
                if (e instanceof InterruptedException) {
                    Thread.currentThread().interrupt();
                }
            }
        });
    }
}
