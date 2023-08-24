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

import static org.mockito.Mockito.any;
import static org.mockito.Mockito.anyLong;
import static org.mockito.Mockito.anyString;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

import org.eclipse.hono.communication.api.config.ApiCommonConstants;
import org.eclipse.hono.communication.api.config.DeviceConfigsConstants;
import org.eclipse.hono.communication.api.data.DeviceConfig;
import org.eclipse.hono.communication.api.data.DeviceConfigEntity;
import org.eclipse.hono.communication.api.data.DeviceConfigRequest;
import org.eclipse.hono.communication.api.mapper.DeviceConfigMapper;
import org.eclipse.hono.communication.api.repository.DeviceConfigRepository;
import org.eclipse.hono.communication.api.repository.DeviceConfigRepositoryImpl;
import org.eclipse.hono.communication.api.service.communication.InternalMessaging;
import org.eclipse.hono.communication.core.app.InternalMessagingConfig;
import org.eclipse.hono.communication.core.app.InternalMessagingConstants;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentMatchers;

import com.google.cloud.pubsub.v1.AckReplyConsumer;
import com.google.protobuf.ByteString;
import com.google.pubsub.v1.PubsubMessage;

import io.vertx.core.Context;
import io.vertx.core.Future;
import io.vertx.core.Handler;
import io.vertx.core.Promise;
import io.vertx.core.Vertx;

class DeviceConfigServiceImplTest {

    public static final String CONFIG_BASE_64 = "dGVzdCBjb25maWcgMjIyMjIy";
    private final DeviceConfigRepository repositoryMock;
    private final DeviceConfigMapper mapperMock;
    private final InternalMessagingConfig communicationConfigMock;
    private final InternalMessaging internalCommunicationMock;
    private final String tenantId = "tenant_ID";
    private final String deviceId = "device_ID";
    private final PubsubMessage pubsubMessageMock;
    private final Context contextMock;
    private final AckReplyConsumer ackReplyConsumerMock;
    private final ByteString byteStringMock;
    private final DeviceConfigServiceImpl deviceConfigService;
    private final Vertx vertxMock;

    DeviceConfigServiceImplTest() {
        this.repositoryMock = mock(DeviceConfigRepositoryImpl.class);
        this.mapperMock = mock(DeviceConfigMapper.class);
        this.communicationConfigMock = mock(InternalMessagingConfig.class);
        this.internalCommunicationMock = mock(InternalMessaging.class);
        this.pubsubMessageMock = mock(PubsubMessage.class);
        this.ackReplyConsumerMock = mock(AckReplyConsumer.class);
        this.contextMock = mock(Context.class);
        this.byteStringMock = mock(ByteString.class);
        this.vertxMock = mock(Vertx.class);
        this.deviceConfigService = createServiceObj();
    }

    private static <T> Handler<T> anyHandler() {
        @SuppressWarnings("unchecked")
        final Handler<T> result = ArgumentMatchers.any(Handler.class);
        return result;
    }

    DeviceConfigServiceImpl createServiceObj() {
        return new DeviceConfigServiceImpl(repositoryMock,
                mapperMock,
                communicationConfigMock,
                internalCommunicationMock,
                vertxMock);
    }

    @AfterEach
    void tearDown() {
        verifyNoMoreInteractions(repositoryMock,
                mapperMock,
                communicationConfigMock,
                internalCommunicationMock,
                pubsubMessageMock,
                ackReplyConsumerMock,
                byteStringMock,
                contextMock);
    }

    @Test
    void modifyCloudToDeviceConfig_success() throws Exception {
        final var deviceConfigRequest = new DeviceConfigRequest();
        deviceConfigRequest.setBinaryData(CONFIG_BASE_64);

        final var deviceConfigEntity = new DeviceConfigEntity();

        final var deviceConfigEntityResponse = new DeviceConfig();
        deviceConfigEntityResponse.setVersion("1");
        deviceConfigEntityResponse.setBinaryData(CONFIG_BASE_64);

        when(repositoryMock.createNew(any())).thenReturn(Future.succeededFuture(deviceConfigEntity));
        when(repositoryMock.updateDeviceConfigError(any())).thenReturn(Future.succeededFuture());
        when(repositoryMock.getDeviceConfig(tenantId, deviceId, 1))
                .thenReturn(Future.succeededFuture(deviceConfigEntity));

        when(mapperMock.configRequestToDeviceConfigEntity(deviceConfigRequest)).thenReturn(deviceConfigEntity);
        when(mapperMock.deviceConfigEntityToConfig(deviceConfigEntity)).thenReturn(deviceConfigEntityResponse);
        when(mapperMock.configRequestToDeviceConfigEntity(any())).thenReturn(deviceConfigEntity);

        when(communicationConfigMock.getCommandTopicFormat()).thenReturn("%s.config");
        when(communicationConfigMock.getCommandTopicFormat()).thenReturn("version");

        doAnswer(invocation -> {
            final Promise<Object> result = Promise.promise();
            final Handler<Promise<Object>> handler = invocation.getArgument(0);
            handler.handle(result);
            return result.future();
        }).when(contextMock).executeBlocking(any());

        when(vertxMock.getOrCreateContext()).thenReturn(contextMock);

        doAnswer(invocation -> {
            final Handler<Long> task = invocation.getArgument(1);
            task.handle(1L);
            return 1L;
        }).when(vertxMock).setTimer(anyLong(), anyHandler());

        doNothing().when(internalCommunicationMock).publish(anyString(), any(), any());

        final var results = deviceConfigService.modifyCloudToDeviceConfig(deviceConfigRequest, deviceId, tenantId);

        verify(repositoryMock).createNew(any());
        verify(repositoryMock).updateDeviceConfigError(any());
        verify(repositoryMock).getDeviceConfig(tenantId, deviceId, 1);
        verify(repositoryMock).updateDeviceAckTime(any(), any());
        verify(mapperMock, times(1)).configRequestToDeviceConfigEntity(deviceConfigRequest);
        verify(mapperMock, times(1)).deviceConfigEntityToConfig(deviceConfigEntity);
        verify(communicationConfigMock).getCommandTopicFormat();
        verify(communicationConfigMock).getCommandConfigAckDelay();
        verify(contextMock).executeBlocking(any());
        verify(internalCommunicationMock).publish(anyString(), any(), any());
        Assertions.assertTrue(results.succeeded());
    }

    @Test
    void modifyCloudToDeviceConfig_failure() {
        final var deviceConfigRequest = new DeviceConfigRequest();
        deviceConfigRequest.setBinaryData(CONFIG_BASE_64);
        final var deviceConfigEntity = new DeviceConfigEntity();
        deviceConfigEntity.setBinaryData(CONFIG_BASE_64);

        when(repositoryMock.createNew(any())).thenReturn(Future.failedFuture(new NoSuchElementException()));
        when(mapperMock.configRequestToDeviceConfigEntity(deviceConfigRequest)).thenReturn(deviceConfigEntity);

        final var results = deviceConfigService.modifyCloudToDeviceConfig(deviceConfigRequest, deviceId, tenantId);

        verify(mapperMock).configRequestToDeviceConfigEntity(any());
        verify(repositoryMock).createNew(any());
        Assertions.assertTrue(results.failed());
    }

    @Test
    void modifyCloudToDeviceConfig_failure_noBase64() {
        final var deviceConfigRequest = new DeviceConfigRequest();
        deviceConfigRequest.setBinaryData("test 2");
        final var deviceConfigEntity = new DeviceConfigEntity();
        deviceConfigEntity.setBinaryData("");

        when(repositoryMock.createNew(any())).thenReturn(Future.failedFuture(new NoSuchElementException()));
        when(mapperMock.configRequestToDeviceConfigEntity(deviceConfigRequest)).thenReturn(deviceConfigEntity);

        final var results = deviceConfigService.modifyCloudToDeviceConfig(deviceConfigRequest, deviceId, tenantId);

        Assertions.assertTrue(results.failed());
    }

    @Test
    void listAll_success() {
        when(repositoryMock.listAll(deviceId, tenantId, 10))
                .thenReturn(Future.succeededFuture(List.of(new DeviceConfig())));

        final var results = deviceConfigService.listAll(deviceId, tenantId, 10);

        verify(repositoryMock).listAll(deviceId, tenantId, 10);
        Assertions.assertTrue(results.succeeded());
    }

    @Test
    void listAll_failed() {
        when(repositoryMock.listAll(deviceId, tenantId, 10)).thenReturn(Future.failedFuture(new RuntimeException()));

        final var results = deviceConfigService.listAll(deviceId, tenantId, 10);

        verify(repositoryMock).listAll(deviceId, tenantId, 10);
        Assertions.assertTrue(results.failed());
    }

    @Test
    void updateDeviceAckTime() {
        doReturn(Future.succeededFuture()).when(repositoryMock).updateDeviceAckTime(any(), anyString());

        deviceConfigService.updateDeviceAckTime(new DeviceConfigEntity(), Instant.now().toString());

        verify(repositoryMock).updateDeviceAckTime(any(), anyString());
    }

    @Test
    void onDeviceConfigResponse() {
        when(pubsubMessageMock.getAttributesMap())
                .thenReturn(Map.of(
                        InternalMessagingConstants.DEVICE_ID, "device-123",
                        InternalMessagingConstants.TENANT_ID, "tenant-123",
                        InternalMessagingConstants.STATUS, "500",
                        InternalMessagingConstants.CORRELATION_ID, "12",
                        InternalMessagingConstants.DELIVERY_FAILURE_NOTIFICATION_METADATA_SUBJECT, DeviceConfigsConstants.CONFIG_SUBJECT));
        when(pubsubMessageMock.getData())
                .thenReturn(ByteString.copyFromUtf8("{\"error\": \"test\"}"));

        doReturn(Future.succeededFuture()).when(repositoryMock).updateDeviceConfigError(any());

        deviceConfigService.onDeviceConfigErrorResponse(pubsubMessageMock);
        verify(pubsubMessageMock).getAttributesMap();
        verify(pubsubMessageMock).getData();
        verify(repositoryMock).updateDeviceConfigError(any());
    }

    @Test
    public void onDeviceConfigRequest_SkipsIfDeviceIdOrTenantIdIsEmpty() {
        when(pubsubMessageMock.getAttributesMap())
                .thenReturn(Map.of(
                        ApiCommonConstants.DEVICE_ID_CAPTION, "",
                        ApiCommonConstants.TENANT_ID_CAPTION, "tenant-123"));
        when(pubsubMessageMock.getData()).thenReturn(ByteString.copyFromUtf8("{\"cause\": \"connected\"}"));

        when(communicationConfigMock.getContentTypeKey()).thenReturn("content-type");

        deviceConfigService.onDeviceConfigRequest(pubsubMessageMock, ackReplyConsumerMock);

        verify(pubsubMessageMock).getAttributesMap();
        verify(ackReplyConsumerMock).ack();
    }

    @Test
    public void onDeviceConfigRequest_SkipsEvent() {
        when(pubsubMessageMock.getAttributesMap())
                .thenReturn(Map.of(
                        ApiCommonConstants.DEVICE_ID_CAPTION, "device-123",
                        ApiCommonConstants.TENANT_ID_CAPTION, "tenant-123",
                        "content-type", "test",
                        "orig_adapter", "adapter-mqtt"));


        when(communicationConfigMock.getContentTypeKey()).thenReturn("content-type");
        when(communicationConfigMock.getOrigAdapterKey()).thenReturn("adapter-mqtt");
        when(communicationConfigMock.getEmptyNotificationEventContentType()).thenReturn("skip-content");

        deviceConfigService.onDeviceConfigRequest(pubsubMessageMock, ackReplyConsumerMock);

        verify(pubsubMessageMock).getAttributesMap();
        verify(communicationConfigMock).getContentTypeKey();
        verify(communicationConfigMock).getOrigAdapterKey();
        verify(communicationConfigMock, times(1)).getEmptyNotificationEventContentType();

        verify(ackReplyConsumerMock).ack();
    }

    @Test
    public void onDeviceConfigRequest_PublishesDeviceConfig() throws Exception {
        final String deviceId = "device-123";
        final String tenantId = "tenant-123";

        final String topic = "tenant-123-config";
        final byte[] message = "{}".getBytes();
        final Map<String, String> messageAttributes = Map.of(
                ApiCommonConstants.DEVICE_ID_CAPTION, deviceId,
                ApiCommonConstants.TENANT_ID_CAPTION, tenantId,
                "content", "event",
                "ttd", "-1");
        final var deviceConfigEntity = new DeviceConfigEntity();
        final var deviceConfigEntityResponse = new DeviceConfig();

        when(pubsubMessageMock.getAttributesMap()).thenReturn(messageAttributes);
        when(repositoryMock.getDeviceLatestConfig(tenantId, deviceId))
                .thenReturn(Future.succeededFuture(deviceConfigEntity));
        when(mapperMock.deviceConfigEntityToConfig(deviceConfigEntity)).thenReturn(deviceConfigEntityResponse);
        when(communicationConfigMock.getCommandTopicFormat()).thenReturn("%s-config");

        when(communicationConfigMock.getContentTypeKey()).thenReturn("content");
        when(communicationConfigMock.getEmptyNotificationEventContentType()).thenReturn("event");
        when(communicationConfigMock.getTtdKey()).thenReturn("ttd");
        doNothing().when(internalCommunicationMock).publish(topic, message, messageAttributes);
        when(vertxMock.getOrCreateContext()).thenReturn(contextMock);

        deviceConfigService.onDeviceConfigRequest(pubsubMessageMock, ackReplyConsumerMock);

        verify(pubsubMessageMock).getAttributesMap();
        verify(repositoryMock).getDeviceLatestConfig(tenantId, deviceId);
        verify(mapperMock).deviceConfigEntityToConfig(deviceConfigEntity);
        verify(communicationConfigMock).getCommandTopicFormat();
        verify(communicationConfigMock).getContentTypeKey();
        verify(communicationConfigMock).getEmptyNotificationEventContentType();
        verify(communicationConfigMock).getTtdKey();

        verify(contextMock).executeBlocking(any());

        verify(ackReplyConsumerMock).ack();
    }

    @Test
    public void onDeviceConfigRequest_PublishesDeviceConfig_failed() {
        final String deviceId = "device-123";
        final String tenantId = "tenant-123";

        final Map<String, String> messageAttributes = Map.of(
                ApiCommonConstants.DEVICE_ID_CAPTION, deviceId,
                "content", "event",
                ApiCommonConstants.TENANT_ID_CAPTION, tenantId,
                "ttd", "-1");

        when(pubsubMessageMock.getAttributesMap()).thenReturn(messageAttributes);
        when(repositoryMock.getDeviceLatestConfig(tenantId, deviceId))
                .thenReturn(Future.failedFuture(new RuntimeException()));
        when(pubsubMessageMock.getData()).thenReturn(ByteString.copyFromUtf8("{\"cause\": \"connected\"}"));

        when(communicationConfigMock.getContentTypeKey()).thenReturn("content");
        when(communicationConfigMock.getEmptyNotificationEventContentType()).thenReturn("event");
        when(communicationConfigMock.getTtdKey()).thenReturn("ttd");
        when(communicationConfigMock.getCommandAckTopicFormat()).thenReturn("%s.ack");

        deviceConfigService.onDeviceConfigRequest(pubsubMessageMock, ackReplyConsumerMock);

        verify(pubsubMessageMock).getAttributesMap();
        verify(repositoryMock).getDeviceLatestConfig(tenantId, deviceId);
        verify(ackReplyConsumerMock).ack();

        verify(communicationConfigMock).getContentTypeKey();
        verify(communicationConfigMock).getEmptyNotificationEventContentType();
        verify(communicationConfigMock).getTtdKey();
    }
}
