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

import java.util.ArrayList;
import java.util.List;

import org.eclipse.hono.communication.core.app.DatabaseConfig;

import io.quarkus.runtime.Quarkus;
import io.vertx.core.Vertx;
import io.vertx.core.impl.logging.Logger;
import io.vertx.core.impl.logging.LoggerFactory;
import io.vertx.pgclient.PgConnectOptions;
import io.vertx.pgclient.PgPool;
import io.vertx.sqlclient.PoolOptions;
import io.vertx.sqlclient.SqlConnection;

/**
 * Database utilities class.
 */
public final class DbUtils {

    static final Logger log = LoggerFactory.getLogger(DbUtils.class);

    private DbUtils() {
        // avoid instantiation
    }

    /**
     * Build DB client that is used to manage a pool of connections.
     *
     * @param vertx The quarkus Vertx instance
     * @param dbConfigs The database configs
     * @return PostgreSQL pool
     */
    public static PgPool createDbClient(final Vertx vertx, final DatabaseConfig dbConfigs) {

        final PgConnectOptions connectOptions = new PgConnectOptions()
                .setHost(dbConfigs.getHost())
                .setPort(dbConfigs.getPort())
                .setDatabase(dbConfigs.getName())
                .setUser(dbConfigs.getUserName())
                .setPassword(dbConfigs.getPassword())
                .setCachePreparedStatements(dbConfigs.getCachePreparedStatements());

        final PoolOptions poolOptions = new PoolOptions();
        poolOptions.setMaxSize(dbConfigs.getPoolMaxSize());
        poolOptions.setIdleTimeout(dbConfigs.getConnectionIdleTimeout());
        final var pool = PgPool.pool(vertx, connectOptions, poolOptions);
        final List<SqlConnection> connections = new ArrayList<>();
        for (int i = 0; i < Math.max(dbConfigs.getPoolInitialSize(), 1); i++) {
            pool.getConnection(connection -> {
                if (connection.succeeded()) {
                    connections.add(connection.result());
                } else {
                    log.error(String.format("Failed to connect to Database: %s", connection.cause().getMessage()));
                    Quarkus.asyncExit(-1);
                }
            });
        }
        for (SqlConnection conn : connections) {
            conn.close();
        }
        log.info("Database connection created successfully.");
        return pool;

    }

}
