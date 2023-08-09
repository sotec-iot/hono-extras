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

package org.eclipse.hono.communication.api.config;

import java.util.List;

/**
 * Constant values for PubSub.
 */
public final class PubSubConstants {

    public static final String TENANT_NOTIFICATIONS = "registry-tenant.notification";
    public static final String TELEMETRY_ENDPOINT = "telemetry";
    public static final String EVENT_ENDPOINT = "event";
    public static final String EVENT_STATES_SUBTOPIC_ENDPOINT = "event.state";
    public static final String COMMAND_ENDPOINT = "command";
    public static final String COMMAND_RESPONSE_ENDPOINT = "command_response";

    private PubSubConstants() {
    }

    /**
     * Gets the list of all topics need to be created per tenant.
     *
     * @return List of all topics.
     */
    public static List<String> getTenantTopics() {
        return List.of(EVENT_ENDPOINT,
                COMMAND_ENDPOINT,
                COMMAND_RESPONSE_ENDPOINT,
                EVENT_STATES_SUBTOPIC_ENDPOINT,
                TELEMETRY_ENDPOINT);
    }
}
