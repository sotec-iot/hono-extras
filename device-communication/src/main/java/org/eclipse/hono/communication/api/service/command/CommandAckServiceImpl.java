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

import java.util.Objects;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

import io.vertx.core.Promise;
import jakarta.inject.Singleton;

/**
 * Service for command acknowledgements.
 */
@Singleton
public class CommandAckServiceImpl implements CommandAckService {

    public static final String KEY_FORMAT = "%s_%s_%s";
    private final ConcurrentMap<String, Promise<Void>> commandPromiseMap = new ConcurrentHashMap<>();

    @Override
    public Promise<Void> put(final String tenantId, final String deviceId, final String correlationId,
            final Promise<Void> promise) {
        Objects.requireNonNull(tenantId);
        Objects.requireNonNull(deviceId);
        Objects.requireNonNull(correlationId);
        Objects.requireNonNull(promise);
        return commandPromiseMap.put(getKey(tenantId, deviceId, correlationId), promise);
    }

    @Override
    public Promise<Void> remove(final String tenantId, final String deviceId, final String correlationId) {
        Objects.requireNonNull(tenantId);
        Objects.requireNonNull(deviceId);
        Objects.requireNonNull(correlationId);
        return commandPromiseMap.remove(getKey(tenantId, deviceId, correlationId));
    }

    private String getKey(final String tenantId, final String deviceId, final String correlationId) {
        return String.format(KEY_FORMAT, tenantId, deviceId, correlationId);
    }
}
