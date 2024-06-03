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

import static org.mockito.Mockito.any;
import static org.mockito.Mockito.anyLong;
import static org.mockito.Mockito.anyString;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;

import java.io.IOException;
import java.util.Map;
import java.util.Random;

import org.eclipse.hono.communication.api.config.DeviceConfigsConstants;
import org.eclipse.hono.communication.api.data.DeviceCommandRequest;
import org.eclipse.hono.communication.api.exception.DeviceNotFoundException;
import org.eclipse.hono.communication.api.handler.ConfigTopicEventHandler;
import org.eclipse.hono.communication.api.repository.DeviceRepository;
import org.eclipse.hono.communication.api.service.communication.InternalMessaging;
import org.eclipse.hono.communication.api.service.database.DatabaseService;
import org.eclipse.hono.communication.api.service.database.DatabaseServiceImpl;
import org.eclipse.hono.communication.core.app.DatabaseConfig;
import org.eclipse.hono.communication.core.app.InternalMessagingConfig;
import org.eclipse.hono.communication.core.app.InternalMessagingConstants;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

import com.google.cloud.pubsub.v1.AckReplyConsumer;
import com.google.pubsub.v1.PubsubMessage;

import io.vertx.core.Future;
import io.vertx.core.Vertx;

class DeviceCommandServiceImplTest {

    private final DeviceRepository repositoryMock;
    private final DatabaseService dbMock;
    private final DeviceCommandServiceImpl deviceCommandService;
    private final InternalMessagingConfig communicationConfig;
    private final InternalMessaging internalCommunication;
    private final PubsubMessage pubsubMessageMock;
    private final DatabaseConfig databaseConfig;
    private final AckReplyConsumer ackReplyConsumerMock;
    private final ConfigTopicEventHandler configTopicEventHandler;
    private final Vertx vertxMock;
    private final Random randomMock;

    DeviceCommandServiceImplTest() {
        this.repositoryMock = mock(DeviceRepository.class);
        this.dbMock = mock(DatabaseServiceImpl.class);
        this.communicationConfig = mock(InternalMessagingConfig.class);
        this.internalCommunication = mock(InternalMessaging.class);
        this.pubsubMessageMock = mock(PubsubMessage.class);
        this.databaseConfig = mock(DatabaseConfig.class);
        this.ackReplyConsumerMock = mock(AckReplyConsumer.class);
        this.configTopicEventHandler = mock(ConfigTopicEventHandler.class);
        this.vertxMock = mock(Vertx.class);
        this.randomMock = mock(Random.class);
        this.deviceCommandService = new DeviceCommandServiceImpl(
                repositoryMock,
                internalCommunication,
                communicationConfig,
                configTopicEventHandler,
                new CommandAckServiceImpl(),
                vertxMock, randomMock);
    }

    @AfterEach
    void tearDown() {
        verifyNoMoreInteractions(dbMock,
                databaseConfig,
                repositoryMock,
                internalCommunication,
                pubsubMessageMock,
                databaseConfig,
                communicationConfig,
                ackReplyConsumerMock,
                configTopicEventHandler,
                vertxMock, randomMock);
    }

    @Test
    void postCommand_oneWayCommandDeviceExists_succeeds() throws Exception {
        final String deviceId = "device123";
        final String tenantId = "tenant123";
        final DeviceCommandRequest commandRequest = new DeviceCommandRequest();
        commandRequest.setBinaryData("dGVzdCBjb25maWcgMjIyMjIy");

        when(repositoryMock.searchForDevice(deviceId, tenantId, null)).thenReturn(Future.succeededFuture(1));
        when(communicationConfig.getCommandTopicFormat()).thenReturn("%s.command");
        doNothing().when(internalCommunication).publish(anyString(), any(), any());

        final Future<Void> result = deviceCommandService.postCommand(commandRequest, tenantId, deviceId);

        verify(repositoryMock).searchForDevice(deviceId, tenantId, null);
        verify(communicationConfig).getCommandTopicFormat();
        verify(internalCommunication).publish(anyString(), any(), any());
        verify(vertxMock, never()).setTimer(anyLong(), any());
        Assertions.assertTrue(result.succeeded());
    }

    @Test
    void postCommand_responseRequiredCommandDeviceExists_succeeds() throws Exception {
        final String deviceId = "device123";
        final String tenantId = "tenant123";
        final DeviceCommandRequest commandRequest = new DeviceCommandRequest();
        commandRequest.setBinaryData("dGVzdCBjb25maWcgMjIyMjIy");
        commandRequest.setResponseRequired(true);

        when(repositoryMock.searchForDevice(deviceId, tenantId, null)).thenReturn(Future.succeededFuture(1));
        when(communicationConfig.getCommandTopicFormat()).thenReturn("%s.command");
        when(randomMock.nextLong(anyLong(), anyLong())).thenReturn(10000L);
        doNothing().when(internalCommunication).publish(anyString(), any(), any());

        final Future<Void> result = deviceCommandService.postCommand(commandRequest, tenantId, deviceId);

        verify(repositoryMock).searchForDevice(deviceId, tenantId, null);
        verify(communicationConfig).getCommandTopicFormat();
        verify(internalCommunication).publish(anyString(), any(), any());
        verify(randomMock).nextLong(anyLong(), anyLong());
        verify(vertxMock, never()).setTimer(anyLong(), any());
        Assertions.assertTrue(result.succeeded());
    }

    @Test
    void postCommand_ackRequiredCommandDeviceExists_succeeds() throws Exception {
        final String deviceId = "device123";
        final String tenantId = "tenant123";
        final DeviceCommandRequest commandRequest = new DeviceCommandRequest();
        commandRequest.setBinaryData("dGVzdCBjb25maWcgMjIyMjIy");
        commandRequest.setAckRequired(true);

        when(repositoryMock.searchForDevice(deviceId, tenantId, null)).thenReturn(Future.succeededFuture(1));
        when(communicationConfig.getCommandTopicFormat()).thenReturn("%s.command");
        when(randomMock.nextLong(anyLong(), anyLong())).thenReturn(10000L);
        doNothing().when(internalCommunication).publish(anyString(), any(), any());

        final Future<Void> result = deviceCommandService.postCommand(commandRequest, tenantId, deviceId);

        verify(repositoryMock).searchForDevice(deviceId, tenantId, null);
        verify(communicationConfig).getCommandTopicFormat();
        verify(internalCommunication).publish(anyString(), any(), any());
        verify(randomMock).nextLong(anyLong(), anyLong());
        verify(vertxMock, times(1)).setTimer(anyLong(), any());
        verify(communicationConfig, times(1)).getCommandDefaultAckTimeout();
        Assertions.assertFalse(result.isComplete());
    }

    @Test
    void postCommand_DeviceDoesNotExist_throwsDeviceNotFoundException() {
        final String deviceId = "device123";
        final String tenantId = "tenant123";
        final DeviceCommandRequest commandRequest = new DeviceCommandRequest();
        commandRequest.setBinaryData("dGVzdCBjb25maWcgMjIyMjIy");

        when(repositoryMock.searchForDevice(deviceId, tenantId, null)).thenReturn(Future.succeededFuture(0));

        final Future<Void> result = deviceCommandService.postCommand(commandRequest, tenantId, deviceId);
        verify(repositoryMock).searchForDevice(deviceId, tenantId, null);
        Assertions.assertTrue(result.failed());
        Assertions.assertSame(result.cause().getClass(), DeviceNotFoundException.class);
    }

    @Test
    void postCommand_publishError_fails() throws Exception {
        final String deviceId = "device123";
        final String tenantId = "tenant123";
        final DeviceCommandRequest commandRequest = new DeviceCommandRequest();
        commandRequest.setBinaryData("dGVzdCBjb25maWcgMjIyMjIy");

        when(repositoryMock.searchForDevice(deviceId, tenantId, null)).thenReturn(Future.succeededFuture(1));
        when(communicationConfig.getCommandTopicFormat()).thenReturn("%s.command");
        doThrow(new IOException()).when(internalCommunication).publish(anyString(), any(), any());

        final Future<Void> result = deviceCommandService.postCommand(commandRequest, tenantId, deviceId);

        verify(repositoryMock).searchForDevice(deviceId, tenantId, null);
        verify(communicationConfig).getCommandTopicFormat();
        verify(internalCommunication).publish(anyString(), any(), any());
        Assertions.assertTrue(result.failed());
        Assertions.assertSame(result.cause().getClass(), IOException.class);
    }

    @Test
    void postCommand_binaryDataNotBase64_fails() throws Exception {
        final String deviceId = "device123";
        final String tenantId = "tenant123";
        final DeviceCommandRequest commandRequest = new DeviceCommandRequest();
        commandRequest.setBinaryData("test 2");

        when(repositoryMock.searchForDevice(deviceId, tenantId, null)).thenReturn(Future.succeededFuture(1));
        when(communicationConfig.getCommandTopicFormat()).thenReturn("%s.command");
        doThrow(new IOException()).when(internalCommunication).publish(anyString(), any(), any());

        final Future<Void> result = deviceCommandService.postCommand(commandRequest, tenantId, deviceId);

        Assertions.assertTrue(result.failed());
        Assertions.assertSame(result.cause().getClass(), IllegalStateException.class);
    }

    @Test
    void onDeviceCommandResponse_skipIfNoAckResponse() {
        when(pubsubMessageMock.getAttributesMap())
                .thenReturn(Map.of(
                        InternalMessagingConstants.DEVICE_ID, "device-123",
                        InternalMessagingConstants.CORRELATION_ID, "12"));

        when(communicationConfig.getContentTypeKey()).thenReturn("content-type");

        deviceCommandService.onDeviceCommandResponse(pubsubMessageMock, ackReplyConsumerMock);
        verify(ackReplyConsumerMock).ack();
        verify(pubsubMessageMock).getAttributesMap();
        verify(communicationConfig).getContentTypeKey();
    }

    @Test
    void onDeviceCommandResponse_receiveConfigAckResponse() {
        when(pubsubMessageMock.getAttributesMap())
                .thenReturn(Map.of(
                        InternalMessagingConstants.TENANT_ID, "tenant-123",
                        InternalMessagingConstants.DEVICE_ID, "device-123",
                        InternalMessagingConstants.CORRELATION_ID, "12",
                        InternalMessagingConstants.CONTENT_TYPE,
                        InternalMessagingConstants.DELIVERY_SUCCESS_NOTIFICATION_CONTENT_TYPE,
                        InternalMessagingConstants.SUBJECT, DeviceConfigsConstants.CONFIG_SUBJECT));

        when(communicationConfig.getContentTypeKey()).thenReturn("content-type");

        deviceCommandService.onDeviceCommandResponse(pubsubMessageMock, ackReplyConsumerMock);
        verify(ackReplyConsumerMock).ack();
        verify(pubsubMessageMock).getAttributesMap();
        verify(communicationConfig).getContentTypeKey();
        verify(configTopicEventHandler).onDeviceConfigAckResponse(any());
    }

    @Test
    void onDeviceCommandResponse_receiveCommandAckResponse() {
        when(pubsubMessageMock.getAttributesMap())
                .thenReturn(Map.of(
                        InternalMessagingConstants.TENANT_ID, "tenant-123",
                        InternalMessagingConstants.DEVICE_ID, "device-123",
                        InternalMessagingConstants.CORRELATION_ID, "12",
                        InternalMessagingConstants.CONTENT_TYPE,
                        InternalMessagingConstants.DELIVERY_SUCCESS_NOTIFICATION_CONTENT_TYPE,
                        "commandSubject", "command"));

        when(communicationConfig.getContentTypeKey()).thenReturn("content-type");

        deviceCommandService.onDeviceCommandResponse(pubsubMessageMock, ackReplyConsumerMock);
        verify(ackReplyConsumerMock).ack();
        verify(pubsubMessageMock).getAttributesMap();
        verify(communicationConfig).getContentTypeKey();
    }
}
