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

package org.eclipse.hono.communication.api.data;

import java.util.Objects;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Device config response object.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public class DeviceConfigInternalResponse {

    private String version;
    private String tenantId;
    private String deviceId;
    private String deviceAckError;

    /**
     * Creates a new DeviceConfigInternalResponse.
     */
    public DeviceConfigInternalResponse() {
    }

    /**
     * Creates a new DeviceConfigInternalResponse.
     *
     * @param tenantId Tenant id
     * @param deviceId Device id
     * @param version Device config version
     * @param deviceAckError Device acknowledgement error
     */
    public DeviceConfigInternalResponse(final String tenantId, final String deviceId, final String version,
            final String deviceAckError) {
        this.version = version;
        this.tenantId = tenantId;
        this.deviceId = deviceId;
        this.deviceAckError = deviceAckError;
    }

    @JsonProperty("version")
    public String getVersion() {
        return version;
    }

    public void setVersion(final String version) {
        this.version = version;
    }

    @JsonProperty("tenantId")
    public String getTenantId() {
        return tenantId;
    }

    public void setTenantId(final String tenantId) {
        this.tenantId = tenantId;
    }

    @JsonProperty("deviceId")
    public String getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(final String deviceId) {
        this.deviceId = deviceId;
    }

    @JsonProperty("device_ack_error")
    public String getDeviceAckError() {
        return deviceAckError;
    }

    public void setDeviceAckError(final String deviceAckError) {
        this.deviceAckError = deviceAckError;
    }

    @Override
    public String toString() {
        return "DeviceConfigAckResponse{" +
                "version='" + version + '\'' +
                ", tenantId='" + tenantId + '\'' +
                ", deviceId='" + deviceId + '\'' +
                ", device_ack_error='" + deviceAckError + '\'' +
                '}';
    }

    @Override
    public boolean equals(final Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        final DeviceConfigInternalResponse that = (DeviceConfigInternalResponse) o;
        return version.equals(that.version) && tenantId.equals(that.tenantId) && deviceId.equals(that.deviceId)
                && deviceAckError.equals(that.deviceAckError);
    }

    @Override
    public int hashCode() {
        return Objects.hash(version, tenantId, deviceId, deviceAckError);
    }

}
