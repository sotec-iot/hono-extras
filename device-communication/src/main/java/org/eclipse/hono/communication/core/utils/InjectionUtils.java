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

package org.eclipse.hono.communication.core.utils;

import java.util.Random;

import jakarta.enterprise.inject.Produces;

/**
 * Injection utilities class.
 */
public class InjectionUtils {

    /**
     * Producer for Random object.
     *
     * @return A Random object
     */
    @Produces
    public Random produceRandom() {
        return new Random();
    }
}
