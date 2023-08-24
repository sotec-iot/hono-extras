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

import java.io.IOException;
import java.util.Map;

/**
 * Interface for internal communication topic publisher.
 */
public interface InternalMessagePublisher {

    /**
     * Publishes a message to a topic.
     *
     * @param topic The topic to publish the message to
     * @param message The message to publish
     * @param attributes The message attributes
     * @throws IOException If the publisher cannot be built correctly
     * @throws InterruptedException If the publisher cannot be shutdown correctly
     */
    void publish(String topic, byte[] message, Map<String, String> attributes) throws IOException, InterruptedException;
}
