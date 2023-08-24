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

import java.util.Base64;

/**
 * String utils.
 */
public abstract class StringUtils {

    private StringUtils() {
        // avoid instantiation
    }

    /**
     * Checks if a given string is base64 encoded.
     *
     * @param stringBase64 String to validate
     * @return True if string is base64 else false
     */
    public static boolean isBase64(final String stringBase64) {
        try {
            Base64.getDecoder().decode(stringBase64);
            return true;
        } catch (IllegalArgumentException e) {
            return false;
        }
    }

    /**
     * Converts the given object to string with each line indented by 4 spaces (except the first line).
     *
     * @param o Object to convert
     * @return The indented String or the String "null" if the object was null
     */
    public static String toIndentedString(final Object o) {
        if (o == null) {
            return "null";
        }
        return o.toString().replace("\n", "\n    ");
    }
}
