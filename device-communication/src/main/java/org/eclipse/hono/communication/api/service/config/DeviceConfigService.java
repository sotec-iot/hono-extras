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

package org.eclipse.hono.communication.api.service.config;

import org.eclipse.hono.communication.api.data.DeviceConfig;
import org.eclipse.hono.communication.api.data.DeviceConfigRequest;
import org.eclipse.hono.communication.api.data.ListDeviceConfigVersionsResponse;

import io.vertx.core.Future;

/**
 * Device configuration service interface.
 */
public interface DeviceConfigService {

    /**
     * Creates a new device configuration and sends it to the device.
     *
     * @param deviceConfig The device configuration
     * @param deviceId The device id
     * @param tenantId The tenant id
     * @return Future of DeviceConfig
     */
    Future<DeviceConfig> modifyCloudToDeviceConfig(DeviceConfigRequest deviceConfig, String deviceId, String tenantId);

    /**
     * Lists the configurations for a specific device.
     *
     * @param deviceId Device Id
     * @param tenantId Tenant Id
     * @param limit The maximum number of configs to get
     * @return Future of ListDeviceConfigVersionsResponse
     */
    Future<ListDeviceConfigVersionsResponse> listAll(String deviceId, String tenantId, int limit);
}
