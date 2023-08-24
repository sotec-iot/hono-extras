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

import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.anyString;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

import org.eclipse.hono.communication.api.config.ApiCommonConstants;
import org.eclipse.hono.communication.api.data.DeviceConfig;
import org.eclipse.hono.communication.api.data.DeviceConfigEntity;
import org.eclipse.hono.communication.api.data.DeviceConfigRequest;
import org.eclipse.hono.communication.api.mapper.DeviceConfigMapper;
import org.eclipse.hono.communication.api.repository.DeviceConfigRepository;
import org.eclipse.hono.communication.api.repository.DeviceConfigRepositoryImpl;
import org.eclipse.hono.communication.api.service.command.CommandAckService;
import org.eclipse.hono.communication.api.service.communication.InternalMessaging;
import org.eclipse.hono.communication.core.app.InternalMessagingConfig;
import org.eclipse.hono.communication.core.app.InternalMessagingConstants;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

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
    private final CommandAckService commandAckServiceMock;
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
        this.commandAckServiceMock = mock(CommandAckService.class);
        this.deviceConfigService = createServiceObj();
    }

    DeviceConfigServiceImpl createServiceObj() {
        return new DeviceConfigServiceImpl(repositoryMock,
                mapperMock,
                communicationConfigMock,
                internalCommunicationMock,
                commandAckServiceMock,
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
                commandAckServiceMock,
                vertxMock,
                contextMock);
    }

    @Test
    void modifyCloudToDeviceConfig_success() throws Exception {
        final var deviceConfigRequest = new DeviceConfigRequest();
        deviceConfigRequest.setBinaryData(CONFIG_BASE_64);

        final var deviceConfigEntity = new DeviceConfigEntity();

        final var deviceConfigEntityResponse = new DeviceConfig();
        final String version = "1";
        deviceConfigEntityResponse.setVersion(version);
        deviceConfigEntityResponse.setBinaryData(CONFIG_BASE_64);

        when(repositoryMock.createNew(any())).thenReturn(Future.succeededFuture(deviceConfigEntity));

        when(mapperMock.configRequestToDeviceConfigEntity(deviceConfigRequest)).thenReturn(deviceConfigEntity);
        when(mapperMock.deviceConfigEntityToConfig(deviceConfigEntity)).thenReturn(deviceConfigEntityResponse);

        when(communicationConfigMock.getCommandTopicFormat()).thenReturn("%s.config");
        when(communicationConfigMock.getCommandTopicFormat()).thenReturn("version");
        when(commandAckServiceMock.put(anyString(), anyString(), anyString(), any())).thenReturn(null);
        when(commandAckServiceMock.remove(anyString(), anyString(), anyString())).thenReturn(Promise.promise());

        doAnswer(invocation -> {
            final Promise<Object> result = Promise.promise();
            final Handler<Promise<Object>> handler = invocation.getArgument(0);
            handler.handle(result);
            return result.future();
        }).when(contextMock).executeBlocking(any());
        doAnswer(invocation -> {
            final long result = 1000L;
            final Handler<Long> handler = invocation.getArgument(1);
            handler.handle(result);
            return result;
        }).when(vertxMock).setTimer(anyLong(), any());

        when(vertxMock.getOrCreateContext()).thenReturn(contextMock);

        doNothing().when(internalCommunicationMock).publish(anyString(), any(), any());

        final var results = deviceConfigService.modifyCloudToDeviceConfig(deviceConfigRequest, deviceId, tenantId);

        verify(repositoryMock).createNew(any());
        verify(mapperMock, times(1)).configRequestToDeviceConfigEntity(deviceConfigRequest);
        verify(mapperMock, times(1)).deviceConfigEntityToConfig(deviceConfigEntity);
        verify(communicationConfigMock).getCommandTopicFormat();
        verify(commandAckServiceMock).put(anyString(), anyString(), anyString(), any());
        verify(commandAckServiceMock).remove(anyString(), anyString(), anyString());
        verify(contextMock).executeBlocking(any());
        verify(internalCommunicationMock).publish(anyString(), any(), any());
        verify(vertxMock).getOrCreateContext();
        verify(vertxMock).setTimer(anyLong(), any());
        Assertions.assertTrue(results.succeeded());
    }

    @Test
    void modifyCloudToDeviceConfig_preExistingPromiseInMap_success() throws Exception {
        final var deviceConfigRequest = new DeviceConfigRequest();
        deviceConfigRequest.setBinaryData(CONFIG_BASE_64);

        final var deviceConfigEntity = new DeviceConfigEntity();

        final var deviceConfigEntityResponse = new DeviceConfig();
        final String version = "1";
        deviceConfigEntityResponse.setVersion(version);
        deviceConfigEntityResponse.setBinaryData(CONFIG_BASE_64);

        when(repositoryMock.createNew(any())).thenReturn(Future.succeededFuture(deviceConfigEntity));

        when(mapperMock.configRequestToDeviceConfigEntity(deviceConfigRequest)).thenReturn(deviceConfigEntity);
        when(mapperMock.deviceConfigEntityToConfig(deviceConfigEntity)).thenReturn(deviceConfigEntityResponse);

        when(communicationConfigMock.getCommandTopicFormat()).thenReturn("%s.config");
        when(communicationConfigMock.getCommandTopicFormat()).thenReturn("version");
        final Promise<Void> preExistingPromise = Promise.promise();
        when(commandAckServiceMock.put(anyString(), anyString(), anyString(), any())).thenReturn(preExistingPromise);

        doAnswer(invocation -> {
            final Promise<Object> result = Promise.promise();
            final Handler<Promise<Object>> handler = invocation.getArgument(0);
            handler.handle(result);
            return result.future();
        }).when(contextMock).executeBlocking(any());
        doAnswer(invocation -> {
            final long result = 1000L;
            final Handler<Long> handler = invocation.getArgument(1);
            handler.handle(result);
            return result;
        }).when(vertxMock).setTimer(anyLong(), any());

        when(vertxMock.getOrCreateContext()).thenReturn(contextMock);

        doNothing().when(internalCommunicationMock).publish(anyString(), any(), any());

        final var results = deviceConfigService.modifyCloudToDeviceConfig(deviceConfigRequest, deviceId, tenantId);

        Assertions.assertTrue(results.succeeded());
        Assertions.assertTrue(preExistingPromise.future().failed());
        verify(repositoryMock).createNew(any());
        verify(mapperMock, times(1)).configRequestToDeviceConfigEntity(deviceConfigRequest);
        verify(mapperMock, times(1)).deviceConfigEntityToConfig(deviceConfigEntity);
        verify(communicationConfigMock).getCommandTopicFormat();
        verify(commandAckServiceMock).put(anyString(), anyString(), anyString(), any());
        verify(commandAckServiceMock).remove(anyString(), anyString(), anyString());
        verify(contextMock).executeBlocking(any());
        verify(internalCommunicationMock).publish(anyString(), any(), any());
        verify(vertxMock).getOrCreateContext();
        verify(vertxMock).setTimer(anyLong(), any());
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
    void onDeviceConfigAckResponse_success() {
        final Map<String, String> messageAttributes = Map.of(
                InternalMessagingConstants.DEVICE_ID, deviceId,
                InternalMessagingConstants.TENANT_ID, tenantId,
                InternalMessagingConstants.CORRELATION_ID, "12");

        doReturn(Future.succeededFuture()).when(repositoryMock).updateDeviceAckTime(anyString(), anyString(), anyInt(),
                anyString());

        deviceConfigService.onDeviceConfigAckResponse(messageAttributes);
        verify(repositoryMock).updateDeviceAckTime(anyString(), anyString(), anyInt(), anyString());
    }

    @Test
    void onDeviceConfigRequest_SkipsIfDeviceIdOrTenantIdIsEmpty() {
        when(pubsubMessageMock.getAttributesMap())
                .thenReturn(Map.of(
                        ApiCommonConstants.DEVICE_ID_CAPTION, "",
                        ApiCommonConstants.TENANT_ID_CAPTION, tenantId));
        when(pubsubMessageMock.getData()).thenReturn(ByteString.copyFromUtf8("{\"cause\": \"connected\"}"));

        when(communicationConfigMock.getContentTypeKey()).thenReturn("content-type");

        deviceConfigService.onDeviceConfigRequest(pubsubMessageMock, ackReplyConsumerMock);

        verify(pubsubMessageMock).getAttributesMap();
        verify(ackReplyConsumerMock).ack();
    }

    @Test
    void onDeviceConfigRequest_SkipsEvent() {
        when(pubsubMessageMock.getAttributesMap())
                .thenReturn(Map.of(
                        ApiCommonConstants.DEVICE_ID_CAPTION, deviceId,
                        ApiCommonConstants.TENANT_ID_CAPTION, tenantId,
                        "content-type", "test",
                        "orig_adapter", "adapter-mqtt"));


        when(communicationConfigMock.getContentTypeKey()).thenReturn("content-type");
        when(communicationConfigMock.getOrigAdapterKey()).thenReturn("adapter-mqtt");

        deviceConfigService.onDeviceConfigRequest(pubsubMessageMock, ackReplyConsumerMock);

        verify(pubsubMessageMock).getAttributesMap();
        verify(communicationConfigMock).getContentTypeKey();
        verify(communicationConfigMock).getOrigAdapterKey();

        verify(ackReplyConsumerMock).ack();
    }

    @Test
    void onDeviceConfigRequest_mqttConfigRequest_PublishesDeviceConfig() throws Exception {
        final String topic = "tenant-123-config";
        final String message = "{}";
        final Map<String, String> messageAttributes = Map.of(
                ApiCommonConstants.DEVICE_ID_CAPTION, deviceId,
                ApiCommonConstants.TENANT_ID_CAPTION, tenantId,
                "content", InternalMessagingConstants.EMPTY_NOTIFICATION_EVENT_CONTENT_TYPE,
                "ttd", "-1");
        final var deviceConfigEntity = new DeviceConfigEntity();
        final var deviceConfigEntityResponse = new DeviceConfig();
        final String version = "1";
        deviceConfigEntityResponse.setVersion(version);
        deviceConfigEntityResponse.setBinaryData(message);

        when(pubsubMessageMock.getAttributesMap()).thenReturn(messageAttributes);
        when(repositoryMock.getDeviceLatestConfig(tenantId, deviceId))
                .thenReturn(Future.succeededFuture(deviceConfigEntity));
        when(mapperMock.deviceConfigEntityToConfig(deviceConfigEntity)).thenReturn(deviceConfigEntityResponse);
        when(communicationConfigMock.getCommandTopicFormat()).thenReturn("%s-config");

        when(communicationConfigMock.getContentTypeKey()).thenReturn("content");
        when(communicationConfigMock.getTtdKey()).thenReturn("ttd");
        when(communicationConfigMock.getConfigOnDeviceRequestRetries()).thenReturn(2);
        when(communicationConfigMock.getConfigInternalRetryDelay()).thenReturn(1000L);
        doNothing().when(internalCommunicationMock).publish(topic, message.getBytes(), messageAttributes);
        when(commandAckServiceMock.put(anyString(), anyString(), anyString(), any())).thenReturn(null);
        doAnswer(invocation -> {
            final Promise<Object> result = Promise.promise();
            final Handler<Promise<Object>> handler = invocation.getArgument(0);
            handler.handle(result);
            return result.future();
        }).when(contextMock).executeBlocking(any());
        doAnswer(invocation -> {
            final long result = 1000L;
            final Handler<Long> handler = invocation.getArgument(1);
            handler.handle(result);
            return result;
        }).when(vertxMock).setTimer(anyLong(), any());
        when(vertxMock.getOrCreateContext()).thenReturn(contextMock);

        deviceConfigService.onDeviceConfigRequest(pubsubMessageMock, ackReplyConsumerMock);

        verify(pubsubMessageMock).getAttributesMap();
        verify(repositoryMock).getDeviceLatestConfig(tenantId, deviceId);
        verify(mapperMock).deviceConfigEntityToConfig(deviceConfigEntity);
        verify(internalCommunicationMock, times(3)).publish(anyString(), any(), any());
        verify(communicationConfigMock).getCommandTopicFormat();
        verify(communicationConfigMock).getContentTypeKey();
        verify(communicationConfigMock).getTtdKey();
        verify(communicationConfigMock).getConfigOnDeviceRequestRetries();
        verify(communicationConfigMock).getConfigInternalRetryDelay();
        verify(commandAckServiceMock).put(anyString(), anyString(), anyString(), any());
        verify(commandAckServiceMock).remove(anyString(), anyString(), anyString());
        verify(contextMock).executeBlocking(any());
        verify(vertxMock, times(3)).setTimer(anyLong(), any());
        verify(vertxMock).getOrCreateContext();
        verify(ackReplyConsumerMock).ack();
    }

    @Test
    void onDeviceConfigRequest_httpConfigRequest_PublishesDeviceConfig() throws Exception {
        final String topic = "tenant-123-config";
        final String message = "{}";
        final Map<String, String> messageAttributes = Map.of(
                ApiCommonConstants.DEVICE_ID_CAPTION, deviceId,
                ApiCommonConstants.TENANT_ID_CAPTION, tenantId,
                "ttd", "15",
                "orig_adapter", "hono-http",
                "orig_address", "event///config");
        final var deviceConfigEntity = new DeviceConfigEntity();
        final var deviceConfigEntityResponse = new DeviceConfig();
        final String version = "1";
        deviceConfigEntityResponse.setVersion(version);
        deviceConfigEntityResponse.setBinaryData(message);

        when(pubsubMessageMock.getAttributesMap()).thenReturn(messageAttributes);
        when(repositoryMock.getDeviceLatestConfig(tenantId, deviceId))
                .thenReturn(Future.succeededFuture(deviceConfigEntity));
        when(mapperMock.deviceConfigEntityToConfig(deviceConfigEntity)).thenReturn(deviceConfigEntityResponse);
        when(communicationConfigMock.getCommandTopicFormat()).thenReturn("%s-config");
        when(communicationConfigMock.getContentTypeKey()).thenReturn("content");
        when(communicationConfigMock.getOrigAdapterKey()).thenReturn("orig_adapter");
        when(communicationConfigMock.getOrigAddressKey()).thenReturn("orig_address");
        when(communicationConfigMock.getTtdKey()).thenReturn("ttd");
        when(communicationConfigMock.getConfigOnDeviceRequestRetries()).thenReturn(2);
        when(communicationConfigMock.getConfigInternalRetryDelay()).thenReturn(1000L);
        doNothing().when(internalCommunicationMock).publish(topic, message.getBytes(), messageAttributes);
        when(commandAckServiceMock.put(anyString(), anyString(), anyString(), any())).thenReturn(null);
        doAnswer(invocation -> {
            final Promise<Object> result = Promise.promise();
            final Handler<Promise<Object>> handler = invocation.getArgument(0);
            handler.handle(result);
            return result.future();
        }).when(contextMock).executeBlocking(any());
        doAnswer(invocation -> {
            final long result = 1000L;
            final Handler<Long> handler = invocation.getArgument(1);
            handler.handle(result);
            return result;
        }).when(vertxMock).setTimer(anyLong(), any());
        when(vertxMock.getOrCreateContext()).thenReturn(contextMock);

        deviceConfigService.onDeviceConfigRequest(pubsubMessageMock, ackReplyConsumerMock);

        verify(pubsubMessageMock).getAttributesMap();
        verify(repositoryMock).getDeviceLatestConfig(tenantId, deviceId);
        verify(mapperMock).deviceConfigEntityToConfig(deviceConfigEntity);
        verify(internalCommunicationMock, times(3)).publish(anyString(), any(), any());
        verify(communicationConfigMock).getCommandTopicFormat();
        verify(communicationConfigMock).getContentTypeKey();
        verify(communicationConfigMock).getOrigAdapterKey();
        verify(communicationConfigMock).getOrigAddressKey();
        verify(communicationConfigMock).getTtdKey();
        verify(communicationConfigMock).getConfigOnDeviceRequestRetries();
        verify(communicationConfigMock).getConfigInternalRetryDelay();
        verify(commandAckServiceMock).put(anyString(), anyString(), anyString(), any());
        verify(commandAckServiceMock).remove(anyString(), anyString(), anyString());
        verify(contextMock).executeBlocking(any());
        verify(vertxMock, times(3)).setTimer(anyLong(), any());
        verify(vertxMock).getOrCreateContext();
        verify(ackReplyConsumerMock).ack();
    }
}
