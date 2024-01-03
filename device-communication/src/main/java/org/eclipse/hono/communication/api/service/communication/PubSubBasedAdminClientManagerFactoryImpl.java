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

import java.util.Objects;

import org.eclipse.hono.client.pubsub.PubSubConfigProperties;

import com.google.api.gax.core.CredentialsProvider;

import io.vertx.core.Vertx;
import jakarta.enterprise.context.ApplicationScoped;

/**
 * A factory to create PubSubBasedAdminClientManagerImpl instances.
 */
@ApplicationScoped
public class PubSubBasedAdminClientManagerFactoryImpl implements PubSubBasedAdminClientManagerFactory {

    private final PubSubConfigProperties pubSubConfigProperties;
    private final Vertx vertx;
    private final CredentialsProvider credentialsProvider;

    /**
     * Creates a new PubSubBasedAdminClientManagerFactory.
     *
     * @param pubSubConfigProperties The Pub/Sub config properties containing the Google project ID.
     * @param vertx The Vert.x instance to use.
     * @param credentialsProvider The Google credentials provider to use.
     * @throws NullPointerException if vertx, projectId or credentialsProvider is {@code null}.
     */
    public PubSubBasedAdminClientManagerFactoryImpl(final PubSubConfigProperties pubSubConfigProperties,
            final CredentialsProvider credentialsProvider, final Vertx vertx) {
        this.pubSubConfigProperties = Objects.requireNonNull(pubSubConfigProperties);
        this.credentialsProvider = Objects.requireNonNull(credentialsProvider);
        this.vertx = Objects.requireNonNull(vertx);
    }

    @Override
    public PubSubBasedAdminClientManager createAdminClientManager() {
        return new PubSubBasedAdminClientManager(pubSubConfigProperties, credentialsProvider, vertx);
    }
}
