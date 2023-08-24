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

import javax.inject.Singleton;

import org.eclipse.hono.util.CommandConstants;
import org.eclipse.hono.util.EventConstants;
import org.eclipse.microprofile.config.inject.ConfigProperty;

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

    // Config
    @ConfigProperty(name = "app.internalMessaging.command.ackTopic")
    String commandAckTopicFormat;
    @ConfigProperty(name = "app.internalMessaging.command.commandConfigAckDelay")
    String commandConfigAckDelay;

    // Command
    @ConfigProperty(name = "app.internalMessaging.command.topicFormat")
    String commandTopicFormat;

    public String getCommandTopicFormat() {
        return commandTopicFormat;
    }

    public String getCommandAckTopicFormat() {
        return commandAckTopicFormat;
    }

    public long getCommandConfigAckDelay() {
        return Long.parseLong(commandConfigAckDelay);
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

    public String getEmptyNotificationEventContentType() {
        return EventConstants.CONTENT_TYPE_EMPTY_NOTIFICATION;
    }

    public String getDeliveryFailureNotificationContentType() {
        return CommandConstants.CONTENT_TYPE_DELIVERY_FAILURE_NOTIFICATION;
    }

    public String getStateTopicFormat() {
        return stateTopicFormat;
    }
}
