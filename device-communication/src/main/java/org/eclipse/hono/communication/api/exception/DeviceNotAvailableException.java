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

package org.eclipse.hono.communication.api.exception;

/**
 * Device not available exception code: 504.
 */
public class DeviceNotAvailableException extends RuntimeException {

    /**
     * Creates a new DeviceNotAvailableException.
     */
    public DeviceNotAvailableException() {
    }

    /**
     * Creates a new DeviceNotAvailableException.
     *
     * @param msg String message
     */
    public DeviceNotAvailableException(final String msg) {
        super(msg);
    }

    /**
     * Creates a new DeviceNotAvailableException.
     *
     * @param msg String message
     * @param cause Throwable
     */
    public DeviceNotAvailableException(final String msg, final Throwable cause) {
        super(msg, cause);
    }

    /**
     * Creates a new DeviceNotAvailableException.
     *
     * @param cause Throwable
     */
    public DeviceNotAvailableException(final Throwable cause) {
        super(cause);
    }
}
