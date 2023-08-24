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
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.eclipse.hono.communication.api.config.ApiCommonConstants;
import org.eclipse.hono.communication.api.data.DeviceState;
import org.eclipse.hono.communication.api.data.DeviceStateEntity;
import org.eclipse.hono.communication.api.exception.DeviceNotFoundException;
import org.eclipse.hono.communication.api.service.database.DatabaseService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.vertx.core.Future;
import io.vertx.sqlclient.Row;
import io.vertx.sqlclient.RowIterator;
import io.vertx.sqlclient.SqlConnection;
import io.vertx.sqlclient.Tuple;
import io.vertx.sqlclient.templates.SqlTemplate;
import jakarta.enterprise.context.ApplicationScoped;

/**
 * Repository class for making CRUD operations for device state entities.
 */
@ApplicationScoped
public class DeviceStateRepositoryImpl implements DeviceStateRepository {

    private static final Logger log = LoggerFactory.getLogger(DeviceStateRepositoryImpl.class);
    private static final String SQL_COUNT_STATES_WITH_PK_FILTER = "SELECT COUNT(*) AS total FROM device_status " +
            "WHERE tenant_id = $1 AND device_id = $2";
    private static final String SQL_INSERT = "INSERT INTO device_status (id, tenant_id, device_id, update_time, " +
            "binary_data) VALUES ($1, $2, $3, $4, $5) RETURNING id";
    private static final String SQL_LIST = "SELECT update_time, binary_data FROM device_status " +
            "WHERE device_id = #{deviceId} AND tenant_id = #{tenantId} ORDER BY update_time DESC LIMIT #{limit}";
    private static final String SQL_DELETE = "DELETE FROM device_status WHERE tenant_id = $1 AND device_id = $2 " +
            "AND id NOT IN (SELECT id FROM device_status WHERE tenant_id = $1 AND device_id = $2 " +
            "ORDER BY update_time DESC LIMIT $3)";
    private static final int MAX_LIMIT = 10;
    private final DatabaseService db;
    private final DeviceRepository deviceRepository;

    /**
     * Creates a new DeviceStateRepositoryImpl.
     *
     * @param db The database connection
     * @param deviceRepository The device repository interface
     */
    public DeviceStateRepositoryImpl(final DatabaseService db,
            final DeviceRepository deviceRepository) {
        this.db = db;
        this.deviceRepository = deviceRepository;
    }

    @Override
    public Future<List<DeviceState>> listAll(final String deviceId, final String tenantId, final int limit) {
        final int queryLimit = limit == 0 ? MAX_LIMIT : limit;
        return db.getDbClient().withConnection(
                sqlConnection -> deviceRepository.searchForDevice(deviceId, tenantId, sqlConnection)
                        .compose(
                                counter -> {
                                    if (counter < 1) {
                                        throw new DeviceNotFoundException(
                                                String.format("Device with id %s and tenant id %s doesn't exist",
                                                        deviceId,
                                                        tenantId));
                                    }
                                    return SqlTemplate
                                            .forQuery(sqlConnection, SQL_LIST)
                                            .mapTo(DeviceStateEntity.class)
                                            .execute(Map.of(ApiCommonConstants.DEVICE_ID_CAPTION, deviceId,
                                                    ApiCommonConstants.TENANT_ID_CAPTION, tenantId,
                                                    "limit",
                                                    queryLimit))
                                            .map(rowSet -> {
                                                final List<DeviceState> states = new ArrayList<>();
                                                rowSet.forEach(
                                                        entity -> states.add(new DeviceState(entity.getUpdateTime(),
                                                                entity.getBinaryData())));
                                                return states;
                                            })
                                            .onSuccess(success -> log.debug(
                                                    String.format("Listing all states for device %s and tenant %s",
                                                            deviceId, tenantId)))
                                            .onFailure(throwable -> log.error("Error: {}", throwable.getMessage()));
                                }));
    }

    @Override
    public Future<DeviceStateEntity> createNew(final DeviceStateEntity entity) {
        return db.getDbClient().withTransaction(
                sqlConnection -> deviceRepository
                        .searchForDevice(entity.getDeviceId(), entity.getTenantId(), sqlConnection)
                        .compose(
                                deviceCounter -> {
                                    if (deviceCounter < 1) {
                                        throw new DeviceNotFoundException(
                                                String.format(
                                                        "Device with id %s and tenant id %s doesn't exist",
                                                        entity.getDeviceId(),
                                                        entity.getTenantId()));
                                    }
                                    return countStates(entity.getDeviceId(), entity.getTenantId(), sqlConnection)
                                            .compose(
                                                    stateCounter -> {
                                                        if (stateCounter >= MAX_LIMIT) {
                                                            deleteStates(sqlConnection, entity, MAX_LIMIT - 1);
                                                        }
                                                        return insert(sqlConnection, entity);
                                                    });
                                }));
    }

    private Future<Integer> countStates(final String deviceId, final String tenantId,
            final SqlConnection sqlConnection) {
        return sqlConnection
                .preparedQuery(SQL_COUNT_STATES_WITH_PK_FILTER)
                .execute(Tuple.of(tenantId, deviceId))
                .map(rowSet -> {
                    final RowIterator<Row> iterator = rowSet.iterator();
                    return iterator.next().getInteger("total");
                });
    }

    private void deleteStates(final SqlConnection sqlConnection, final DeviceStateEntity entity, final int limit) {
        sqlConnection
                .preparedQuery(SQL_DELETE)
                .execute(Tuple.of(entity.getTenantId(), entity.getDeviceId(), limit));
    }

    /**
     * Inserts a new state entity in to the database.
     *
     * @param sqlConnection The sql connection instance.
     * @param entity The instance to insert.
     * @return A Future of the created DeviceStateEntity.
     */
    private Future<DeviceStateEntity> insert(final SqlConnection sqlConnection, final DeviceStateEntity entity) {
        entity.setId(UUID.randomUUID().toString());
        return sqlConnection
                .preparedQuery(SQL_INSERT)
                .execute(Tuple.of(entity.getId(), entity.getTenantId(), entity.getDeviceId(), entity.getUpdateTime(),
                        entity.getBinaryData()))
                .map(rowSet -> {
                    final RowIterator<Row> iterator = rowSet.iterator();
                    if (iterator.hasNext()) {
                        return entity;
                    } else {
                        throw new IllegalStateException(String.format("Can't create device state: %s", entity));
                    }
                });
    }
}
