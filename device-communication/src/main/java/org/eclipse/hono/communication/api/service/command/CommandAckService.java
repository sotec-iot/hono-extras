/*
 * ***********************************************************
 *  Copyright (c) 2024 Contributors to the Eclipse Foundation
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

import io.vertx.core.Promise;

/**
 * Command acknowledgement service interface.
 */
public interface CommandAckService {

    /**
     * Saves the command acknowledgement promise corresponding to the command acknowledgement process identified by the
     * tenantId, deviceId and correlationId. If there is already a command acknowledgement promise associated with the
     * provided identifier it will be replaced with the new promise and returned to the caller.
     *
     * @param tenantId Tenant identifier for command acknowledgement process
     * @param deviceId Device identifier for command acknowledgement process
     * @param correlationId Correlation identifier for command acknowledgement process
     * @param promise Promise of the command acknowledgement process
     * @return The previous promise associated with the tenantId, deviceId and correlationId, or null if there was no
     *         previous promise
     * @throws NullPointerException If one of the input parameters is null
     */
    Promise<Void> put(String tenantId, String deviceId, String correlationId, Promise<Void> promise)
            throws NullPointerException;

    /**
     * Removes the command acknowledgement promise corresponding to the command acknowledgement process identified by
     * the tenantId, deviceId and correlationId.
     *
     * @param tenantId Tenant identifier for command acknowledgement process
     * @param deviceId Device identifier for command acknowledgement process
     * @param correlationId Correlation identifier for command acknowledgement process
     * @return The removed promise, or null if there was no promise with the provided identifier
     * @throws NullPointerException If one of the input parameters is null
     */
    Promise<Void> remove(String tenantId, String deviceId, String correlationId) throws NullPointerException;
}
