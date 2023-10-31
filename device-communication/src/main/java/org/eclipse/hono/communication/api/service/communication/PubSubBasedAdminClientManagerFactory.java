/*******************************************************************************
 * Copyright (c) 2023 Contributors to the Eclipse Foundation
 *
 * See the NOTICE file(s) distributed with this work for additional
 * information regarding copyright ownership.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0
 *
 * SPDX-License-Identifier: EPL-2.0
 *******************************************************************************/


package org.eclipse.hono.communication.api.service.communication;

import org.eclipse.hono.client.pubsub.PubSubBasedAdminClientManager;

/**
 * A factory to create PubSubBasedAdminClientManager instances.
 */
public interface PubSubBasedAdminClientManagerFactory {

    /**
     * Creates a new PubSubBasedAdminClientManager instance.
     *
     * @return A new PubSubBasedAdminClientManager instance.
     */
    PubSubBasedAdminClientManager createAdminClientManager();
}
