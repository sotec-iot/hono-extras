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
import java.util.Objects;

import javax.inject.Singleton;

import org.apache.commons.codec.binary.Base64;
import org.eclipse.hono.communication.api.config.ApiCommonConstants;
import org.eclipse.hono.communication.api.config.DeviceConfigsConstants;
import org.eclipse.hono.communication.api.data.DeviceConfig;
import org.eclipse.hono.communication.api.data.DeviceConfigEntity;
import org.eclipse.hono.communication.api.data.DeviceConfigInternalResponse;
import org.eclipse.hono.communication.api.data.DeviceConfigRequest;
import org.eclipse.hono.communication.api.data.ListDeviceConfigVersionsResponse;
import org.eclipse.hono.communication.api.handler.ConfigTopicEventHandler;
import org.eclipse.hono.communication.api.mapper.DeviceConfigMapper;
import org.eclipse.hono.communication.api.repository.DeviceConfigRepository;
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
import io.vertx.core.Vertx;
import io.vertx.core.json.JsonObject;

/**
 * Service for device commands.
 */

@Singleton
public class DeviceConfigServiceImpl extends DeviceServiceAbstract
        implements DeviceConfigService, ConfigTopicEventHandler {

    private static final String DEVICE_CONNECTION_TTD = "-1";

    private final Logger log = LoggerFactory.getLogger(DeviceConfigServiceImpl.class);
    private final DeviceConfigRepository repository;
    private final DeviceConfigMapper mapper;
    private final Vertx vertx;

    /**
     * Creates a new DeviceConfigServiceImpl.
     *
     * @param repository The device config repository
     * @param mapper The device config mapper
     * @param internalMessagingConfig The internal messaging config
     * @param internalMessaging The internal messaging interface
     * @param vertx The vertx instance
     */
    public DeviceConfigServiceImpl(final DeviceConfigRepository repository,
            final DeviceConfigMapper mapper,
            final InternalMessagingConfig internalMessagingConfig,
            final InternalMessaging internalMessaging, final Vertx vertx) {

        super(internalMessagingConfig, internalMessaging);

        this.repository = repository;
        this.mapper = mapper;
        this.vertx = vertx;
    }

    /**
     * Create and publish new device configs.
     *
     * @param deviceConfig The device configs
     * @param deviceId The device id
     * @param tenantId The tenant id
     * @return Future of device config
     */
    public Future<DeviceConfig> modifyCloudToDeviceConfig(final DeviceConfigRequest deviceConfig, final String deviceId,
            final String tenantId) {

        if (!StringValidateUtils.isBase64(deviceConfig.getBinaryData())) {
            return Future
                    .failedFuture(new IllegalStateException("Field binaryData type should be String base64 encoded."));
        }

        final var entity = mapper.configRequestToDeviceConfigEntity(deviceConfig);
        entity.setDeviceId(deviceId);
        entity.setTenantId(tenantId);

        return repository.createNew(entity)
                .map(mapper::deviceConfigEntityToConfig)
                .onSuccess(result -> {
                    final var topicToPublish = String.format(messagingConfig.getCommandTopicFormat(),
                            entity.getTenantId());
                    final var messageAttributes = Map.of(
                            InternalMessagingConstants.DEVICE_ID, entity.getDeviceId(),
                            InternalMessagingConstants.TENANT_ID, entity.getTenantId(),
                            InternalMessagingConstants.CORRELATION_ID, result.getVersion(),
                            InternalMessagingConstants.SUBJECT, DeviceConfigsConstants.CONFIG_SUBJECT,
                            InternalMessagingConstants.DELIVERY_FAILURE_NOTIFICATION_METADATA_SUBJECT,
                            DeviceConfigsConstants.CONFIG_SUBJECT,
                            InternalMessagingConstants.RESPONSE_REQUIRED, "true");
                    publish(topicToPublish, result, messageAttributes);
                });
    }

    /**
     * List all device configs.
     *
     * @param deviceId The device id
     * @param tenantId The tenant id
     * @param limit The limit max=10
     * @return Future of ListDeviceConfigVersionsResponse
     */
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
    public void onDeviceConfigErrorResponse(final PubsubMessage pubsubMessage) {
        final var messageAttributes = pubsubMessage.getAttributesMap();

        final var deviceId = messageAttributes.get(InternalMessagingConstants.DEVICE_ID);
        final var tenantId = messageAttributes.get(InternalMessagingConstants.TENANT_ID);
        final var version = messageAttributes.get(InternalMessagingConstants.CORRELATION_ID);
        final var status = messageAttributes.get(InternalMessagingConstants.STATUS);
        final var errorPayload = new JsonObject(pubsubMessage.getData().toStringUtf8());
        final var error = "error %s: %s".formatted(status, errorPayload.getString("error"));

        final var configErrorResponse = new DeviceConfigInternalResponse(tenantId, deviceId, version, error);

        log.info("Config returned an error: {}", configErrorResponse);
        updateDeviceConfigError(configErrorResponse);
    }

    @Override
    public void onDeviceConfigRequest(final PubsubMessage pubsubMessage, final AckReplyConsumer consumer) {

        consumer.ack(); // message was received and processed only once

        final var messageAttributes = pubsubMessage.getAttributesMap();
        final var deviceId = messageAttributes.get(ApiCommonConstants.DEVICE_ID_CAPTION);
        final var tenantId = messageAttributes.get(ApiCommonConstants.TENANT_ID_CAPTION);

        if (isNotConfigRequest(messageAttributes, tenantId, deviceId)) {
            return;
        }

        repository.getDeviceLatestConfig(tenantId, deviceId)
                .onSuccess(res -> {
                    final var config = mapper.deviceConfigEntityToConfig(res);
                    final var topicToPublish = String.format(messagingConfig.getCommandTopicFormat(), tenantId);
                    final var attributes = new HashMap<String, String>();
                    attributes.put(InternalMessagingConstants.CORRELATION_ID, config.getVersion());
                    attributes.put(InternalMessagingConstants.DEVICE_ID, deviceId);
                    attributes.put(InternalMessagingConstants.TENANT_ID, tenantId);
                    attributes.put(InternalMessagingConstants.SUBJECT, DeviceConfigsConstants.CONFIG_SUBJECT);
                    attributes.put(InternalMessagingConstants.DELIVERY_FAILURE_NOTIFICATION_METADATA_SUBJECT,
                            DeviceConfigsConstants.CONFIG_SUBJECT);
                    attributes.put(InternalMessagingConstants.RESPONSE_REQUIRED, "true");
                    log.debug("Handle config request event");
                    publish(topicToPublish, config, attributes);
                })
                .onFailure(err -> log.error("Can't publish configs: {}", err.getMessage()));
    }

    private boolean isNotConfigRequest(final Map<String, String> messageAttributes, final String tenantId,
            final String deviceId) {
        if (Strings.isNullOrEmpty(deviceId) || Strings.isNullOrEmpty(tenantId)) {
            log.warn("Skip device onConnect event: deviceId or tenantId is empty");
            return true;
        }
        if (!isMqttConfigRequest(messageAttributes) && !isHttpConfigRequest(messageAttributes)) {
            log.debug("Skip device event");
            return true;
        }
        return false;
    }

    private boolean isMqttConfigRequest(final Map<String, String> messageAttributes) {
        return Objects.equals(messageAttributes.get(messagingConfig.getContentTypeKey()),
                messagingConfig.getEmptyNotificationEventContentType()) &&
                Objects.equals(messageAttributes.get(messagingConfig.getTtdKey()), DEVICE_CONNECTION_TTD);
    }

    private boolean isHttpConfigRequest(final Map<String, String> messageAttributes) {
        return Objects.equals(messageAttributes.get(messagingConfig.getOrigAdapterKey()), "hono-http")
                && !messageAttributes.get(messagingConfig.getTtdKey()).isBlank()
                && messageAttributes.get(messagingConfig.getOrigAddressKey())
                        .contains(DeviceConfigsConstants.CONFIG_SUBJECT);
    }

    private void publish(final String topicToPublish, final DeviceConfig deviceConfig,
            final Map<String, String> attributes) {
        final var context = vertx.getOrCreateContext();
        context.executeBlocking(promise -> {
            try {
                final var configPayload = Base64.decodeBase64(deviceConfig.getBinaryData().getBytes());
                final var tenantId = attributes.get(InternalMessagingConstants.TENANT_ID);
                final var deviceId = attributes.get(InternalMessagingConstants.DEVICE_ID);
                final var configVersion = deviceConfig.getVersion();

                resetError(tenantId, deviceId, configVersion);
                internalMessaging.publish(topicToPublish, configPayload, attributes);
                log.info("Publish device config {}", configPayload);
                vertx.setTimer(
                        messagingConfig.getCommandConfigAckDelay(),
                        id -> configSendSuccess(tenantId, deviceId, configVersion)
                                .onSuccess(config -> updateDeviceAckTime(config, Instant.now().toString())));
            } catch (Exception ex) {
                log.error("Error serialize config {}", deviceConfig);
            } finally {
                promise.complete();
            }
        });
    }

    private Future<DeviceConfigEntity> configSendSuccess(final String tenantId, final String deviceId,
            final String configVersion) {

        return repository.getDeviceConfig(tenantId, deviceId, Integer.parseInt(configVersion))
                .compose(config -> {
                    if (config.getDeviceAckError() == null) {
                        return Future.succeededFuture(config);
                    } else {
                        return Future.failedFuture("Config could not successfully be send");
                    }
                });
    }

    private void resetError(final String tenantId, final String deviceId, final String configVersion) {
        updateDeviceConfigError(new DeviceConfigInternalResponse(tenantId, deviceId, configVersion, null));
    }

    @Override
    public void updateDeviceAckTime(final DeviceConfigEntity config, final String deviceAckTime) {
        repository.updateDeviceAckTime(config, deviceAckTime)
                .onSuccess(ok -> log.info(
                        "Successfully updated device acknowledged time for config version {} for device {} in tenant {}",
                        config.getVersion(), config.getDeviceId(), config.getTenantId()));
    }

    @Override
    public void updateDeviceConfigError(final DeviceConfigInternalResponse configErrorResponse) {
        repository.updateDeviceConfigError(configErrorResponse)
                .onSuccess(
                        ok -> log.debug("Successfully updated error for config version {} for device {} in tenant {}",
                                configErrorResponse.getVersion(), configErrorResponse.getDeviceId(),
                                configErrorResponse.getTenantId()));
    }
}
