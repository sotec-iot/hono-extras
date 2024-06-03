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

package org.eclipse.hono.communication.api.service.communication;

import com.google.cloud.pubsub.v1.MessageReceiver;
import com.google.cloud.pubsub.v1.Subscriber;

/**
 * Interface for internal communication topic subscriber.
 */
public interface InternalMessageSubscriber {

    /**
     * Subscribes to a topic.
     *
     * @param subscription The subscription name
     * @param callbackHandler The function to be called when a message is received
     * @return The subscriber
     */
    Subscriber subscribe(String subscription, MessageReceiver callbackHandler);

    /**
     * Closes all active subscribers for the given tenant.
     *
     * @param tenant The tenant
     */
    void closeSubscribersForTenant(String tenant);
}
