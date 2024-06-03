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

package org.eclipse.hono.communication.api.handler;

import org.eclipse.hono.communication.api.config.ApiCommonConstants;
import org.eclipse.hono.communication.api.config.DeviceCommandConstants;
import org.eclipse.hono.communication.api.data.DeviceCommandRequest;
import org.eclipse.hono.communication.api.service.command.DeviceCommandService;
import org.eclipse.hono.communication.core.http.HttpEndpointHandler;
import org.eclipse.hono.communication.core.utils.ResponseUtils;

import io.vertx.core.Vertx;
import io.vertx.ext.web.RoutingContext;
import io.vertx.ext.web.openapi.RouterBuilder;
import jakarta.enterprise.context.ApplicationScoped;

/**
 * Handler for device command endpoints.
 */
@ApplicationScoped
public class DeviceCommandHandler implements HttpEndpointHandler {

    private final DeviceCommandService commandService;

    /**
     * Creates a new DeviceCommandHandler.
     *
     * @param commandService The device command service
     */
    public DeviceCommandHandler(final DeviceCommandService commandService) {
        this.commandService = commandService;
    }

    @Override
    public void addRoutes(final RouterBuilder routerBuilder) {
        routerBuilder.operation(DeviceCommandConstants.POST_DEVICE_COMMAND_OP_ID)
                .handler(this::handlePostCommand);
    }

    /**
     * Handles Post device command.
     *
     * @param routingContext The RoutingContext
     */
    public void handlePostCommand(final RoutingContext routingContext) {
        final var commandRequest = routingContext.body()
                .asJsonObject()
                .mapTo(DeviceCommandRequest.class);
        final var tenantId = routingContext.pathParam(ApiCommonConstants.TENANT_PATH_PARAMS);
        final var deviceId = routingContext.pathParam(ApiCommonConstants.DEVICE_PATH_PARAMS);
        Vertx.currentContext().executeBlocking(promise -> commandService.postCommand(commandRequest, tenantId, deviceId)
                .onSuccess(res -> routingContext.response().setStatusCode(200).end())
                .onFailure(err -> ResponseUtils.errorResponse(routingContext, err)));
    }
}
