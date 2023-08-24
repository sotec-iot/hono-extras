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

package org.eclipse.hono.communication.api.repository;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.eclipse.hono.communication.api.service.database.DatabaseService;
import org.eclipse.hono.communication.core.app.DatabaseConfig;

import io.vertx.core.Future;
import io.vertx.sqlclient.Row;
import io.vertx.sqlclient.RowIterator;
import io.vertx.sqlclient.SqlConnection;
import io.vertx.sqlclient.Tuple;
import io.vertx.sqlclient.templates.SqlTemplate;
import jakarta.enterprise.context.ApplicationScoped;

/**
 * Device registrations repository.
 */
@ApplicationScoped
public class DeviceRepositoryImpl implements DeviceRepository {

    private static final String SQL_LIST_TENANTS = "SELECT %s FROM %s";
    private final DatabaseConfig databaseConfig;
    private final DatabaseService db;
    private final String sqlFindDeviceWithPkFilter;

    /**
     * Creates a new DeviceRepositoryImpl.
     *
     * @param databaseConfig The database configuration
     * @param databaseService The database service
     */
    public DeviceRepositoryImpl(final DatabaseConfig databaseConfig, final DatabaseService databaseService) {
        this.databaseConfig = databaseConfig;
        this.db = databaseService;

        sqlFindDeviceWithPkFilter = String.format(
                "SELECT 1 AS total FROM public.%s WHERE %s = $1 AND %s = $2 LIMIT 1",
                databaseConfig.getDeviceRegistrationTableName(),
                databaseConfig.getDeviceRegistrationTenantIdColumn(),
                databaseConfig.getDeviceRegistrationDeviceIdColumn());
    }

    @Override
    public Future<Integer> searchForDevice(final String deviceId, final String tenantId,
            final SqlConnection sqlConnection) {
        if (sqlConnection != null) {
            return queryDevice(deviceId, tenantId, sqlConnection);
        }
        return db.getDbClient().withConnection(sqlConn -> queryDevice(deviceId, tenantId, sqlConn));
    }

    private Future<Integer> queryDevice(final String deviceId, final String tenantId,
            final SqlConnection sqlConnection) {
        return sqlConnection
                .preparedQuery(sqlFindDeviceWithPkFilter)
                .execute(Tuple.of(tenantId, deviceId))
                .map(rowSet -> {
                    final RowIterator<Row> iterator = rowSet.iterator();
                    if (iterator.hasNext()) {
                        return iterator.next().getInteger("total");
                    }
                    return 0;
                });
    }

    @Override
    public Future<List<String>> listDistinctTenants() {
        final var sqlCommand = SQL_LIST_TENANTS.formatted(
                databaseConfig.getTenantTableIdColumn(),
                databaseConfig.getTenantTableName());

        return db.getDbClient().withConnection(
                sqlConnection -> SqlTemplate
                        .forQuery(sqlConnection, sqlCommand)
                        .execute(Collections.emptyMap())
                        .map(rowSet -> {
                            final List<String> tenants = new ArrayList<>();
                            rowSet.forEach(
                                    tenant -> tenants.add(tenant.getString(databaseConfig.getTenantTableIdColumn())));
                            return tenants;
                        }));
    }
}
