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

package org.eclipse.hono.communication.api.service;

import java.util.List;

import org.eclipse.hono.communication.api.handler.DeviceCommandHandler;
import org.eclipse.hono.communication.api.handler.DeviceConfigsHandler;
import org.eclipse.hono.communication.api.handler.DeviceStatesHandler;
import org.eclipse.hono.communication.core.http.HttpEndpointHandler;

import jakarta.enterprise.context.ApplicationScoped;

/**
 * Provides and manages available HTTP Vert.x handlers.
 */
@ApplicationScoped
public class VertxHttpHandlerManagerService {

    /**
     * Available Vert.x endpoints handler services.
     */
    private final List<HttpEndpointHandler> availableHandlerServices;

    /**
     * Creates a new VertxHttpHandlerManagerService with all dependencies.
     *
     * @param configHandler The configuration handler.
     * @param commandHandler The command handler.
     * @param stateHandler The state handler.
     */
    public VertxHttpHandlerManagerService(final DeviceConfigsHandler configHandler,
            final DeviceCommandHandler commandHandler, final DeviceStatesHandler stateHandler) {
        this.availableHandlerServices = List.of(configHandler, commandHandler, stateHandler);
    }

    public List<HttpEndpointHandler> getAvailableHandlerServices() {
        return availableHandlerServices;
    }
}
