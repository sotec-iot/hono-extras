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

package org.eclipse.hono.communication.core.app;

import org.eclipse.microprofile.config.inject.ConfigProperty;

import jakarta.inject.Singleton;

/**
 * Configs for internal communication service.
 */
@Singleton
public class InternalMessagingConfig {

    @ConfigProperty(name = "app.projectId")
    String projectId;

    // Message Attributes
    @ConfigProperty(name = "app.internalMessaging.message.attributeKeys.contentTypeKey")
    String contentTypeKey;
    @ConfigProperty(name = "app.internalMessaging.message.attributeKeys.origAdapterKey")
    String origAdapterKey;
    @ConfigProperty(name = "app.internalMessaging.message.attributeKeys.origAddressKey")
    String origAddressKey;
    @ConfigProperty(name = "app.internalMessaging.message.attributeKeys.ttdKey")
    String ttdKey;

    // Event
    @ConfigProperty(name = "app.internalMessaging.event.topicFormat")
    String eventTopicFormat;

    // State
    @ConfigProperty(name = "app.internalMessaging.state.topicFormat")
    String stateTopicFormat;

    // Command
    @ConfigProperty(name = "app.internalMessaging.command.topicFormat")
    String commandTopicFormat;
    @ConfigProperty(name = "app.internalMessaging.command.ackTopic")
    String commandAckTopicFormat;
    @ConfigProperty(name = "app.internalMessaging.command.defaultAckTimeout")
    String commandDefaultAckTimeout;

    // Config
    @ConfigProperty(name = "app.internalMessaging.command.config.initialRetryDelay")
    String configInternalRetryDelay;
    @ConfigProperty(name = "app.internalMessaging.command.config.onDeviceRequestRetries")
    String configOnDeviceRequestRetries;

    // PubSub
    @ConfigProperty(name = "app.internalMessaging.pubsub.batchInitTenantThreshold")
    int batchInitTenantThreshold;

    public String getCommandTopicFormat() {
        return commandTopicFormat;
    }

    public String getCommandAckTopicFormat() {
        return commandAckTopicFormat;
    }

    public long getCommandDefaultAckTimeout() {
        return Long.parseLong(commandDefaultAckTimeout);
    }

    public long getConfigInternalRetryDelay() {
        return Long.parseLong(configInternalRetryDelay);
    }

    public int getConfigOnDeviceRequestRetries() {
        return Integer.parseInt(configOnDeviceRequestRetries);
    }

    public String getProjectId() {
        return projectId;
    }

    public String getContentTypeKey() {
        return contentTypeKey;
    }

    public String getOrigAdapterKey() {
        return origAdapterKey;
    }

    public String getOrigAddressKey() {
        return origAddressKey;
    }

    public String getTtdKey() {
        return ttdKey;
    }

    public String getEventTopicFormat() {
        return eventTopicFormat;
    }

    public String getStateTopicFormat() {
        return stateTopicFormat;
    }

    public int getBatchInitTenantThreshold() {
        return batchInitTenantThreshold;
    }
}
