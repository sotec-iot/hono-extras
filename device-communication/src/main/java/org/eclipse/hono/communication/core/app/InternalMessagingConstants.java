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

import org.eclipse.hono.util.CommandConstants;
import org.eclipse.hono.util.EventConstants;

/**
 * Internal Messaging Constant values.
 */
public class InternalMessagingConstants {

    public static final String DEVICE_ID = "device_id";
    public static final String TENANT_ID = "tenant_id";
    public static final String SUBJECT = "subject";
    public static final String CORRELATION_ID = "correlation-id";
    public static final String RESPONSE_REQUIRED = "response-required";
    public static final String ACK_REQUIRED = "ack-required";
    public static final String CONTENT_TYPE = "content-type";
    public static final String EMPTY_NOTIFICATION_EVENT_CONTENT_TYPE = EventConstants.CONTENT_TYPE_EMPTY_NOTIFICATION;
    public static final String DELIVERY_SUCCESS_NOTIFICATION_CONTENT_TYPE = CommandConstants.CONTENT_TYPE_DELIVERY_SUCCESS_NOTIFICATION;

    private InternalMessagingConstants() {
    }
}
