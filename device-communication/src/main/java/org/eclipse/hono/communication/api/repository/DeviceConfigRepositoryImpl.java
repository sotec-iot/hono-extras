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
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

import org.eclipse.hono.communication.api.config.ApiCommonConstants;
import org.eclipse.hono.communication.api.data.DeviceConfig;
import org.eclipse.hono.communication.api.data.DeviceConfigEntity;
import org.eclipse.hono.communication.api.exception.DeviceNotFoundException;
import org.eclipse.hono.communication.api.service.database.DatabaseService;
import org.graalvm.collections.Pair;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.vertx.core.Future;
import io.vertx.sqlclient.RowIterator;
import io.vertx.sqlclient.SqlConnection;
import io.vertx.sqlclient.templates.RowMapper;
import io.vertx.sqlclient.templates.SqlTemplate;
import jakarta.enterprise.context.ApplicationScoped;

/**
 * Repository class for making CRUD operations for device config entities.
 */
@ApplicationScoped
public class DeviceConfigRepositoryImpl implements DeviceConfigRepository {

    private static final String SQL_LIST = "SELECT version, cloud_update_time, device_ack_time, binary_data " +
            "FROM device_configs WHERE device_id = #{deviceId} AND tenant_id = #{tenantId} " +
            "ORDER BY version DESC LIMIT #{limit}";
    private static final String SQL_DELETE_MIN_VERSION = "DELETE FROM device_configs WHERE device_id = #{deviceId} " +
            "AND tenant_id = #{tenantId} AND version = (SELECT MIN(version) FROM device_configs " +
            "WHERE device_id = #{deviceId} AND tenant_id = #{tenantId}) RETURNING version";
    private static final String SQL_FIND_TOTAL_AND_MAX_VERSION = "SELECT COALESCE(COUNT(*), 0) AS total, " +
            "COALESCE(MAX(version), 0) AS max_version FROM device_configs " +
            "WHERE device_id = #{deviceId} AND tenant_id = #{tenantId}";
    private static final String SQL_UPDATE_DEVICE_ACK_TIME = "UPDATE device_configs SET device_ack_time = " +
            "#{deviceAckTime} WHERE tenant_id = #{tenantId} AND device_id = #{deviceId} AND version = #{version}";
    private static final String SQL_FIND_DEVICE_CONFIG = "SELECT * FROM device_configs " +
            "WHERE tenant_id = #{tenantId} AND device_id = #{deviceId} AND version = #{version}";
    private static final String SQL_INSERT = "INSERT INTO device_configs (version, tenant_id, device_id, " +
            "cloud_update_time, device_ack_time, binary_data) VALUES (#{version}, #{tenantId}, " +
            "#{deviceId}, #{cloudUpdateTime}, #{deviceAckTime}, #{binaryData}) RETURNING version";
    private static final String DEVICE_ACK_TIME_CAPTION = "deviceAckTime";
    private static final String VERSION_CAPTION = "version";
    private static final int MAX_LIMIT = 10;
    private final Logger log = LoggerFactory.getLogger(DeviceConfigRepositoryImpl.class);

    private final DatabaseService db;

    private final DeviceRepository deviceRepository;

    /**
     * Creates a new DeviceConfigRepositoryImpl.
     *
     * @param db The database connection
     * @param deviceRepository The device repository interface
     */
    public DeviceConfigRepositoryImpl(final DatabaseService db,
            final DeviceRepository deviceRepository) {

        this.db = db;
        this.deviceRepository = deviceRepository;
    }

    private Future<Pair<Integer, Integer>> findMaxVersionAndTotalEntries(final SqlConnection sqlConnection,
            final String deviceId, final String tenantId) {
        final RowMapper<Pair<Integer, Integer>> rowMapper = row -> Pair.create(row.getInteger("total"),
                row.getInteger("max_version"));
        return SqlTemplate
                .forQuery(sqlConnection, SQL_FIND_TOTAL_AND_MAX_VERSION)
                .mapTo(rowMapper)
                .execute(Map.of(ApiCommonConstants.DEVICE_ID_CAPTION, deviceId, ApiCommonConstants.TENANT_ID_CAPTION,
                        tenantId))
                .map(rowSet -> {
                    final RowIterator<Pair<Integer, Integer>> iterator = rowSet.iterator();
                    return iterator.next();
                });

    }

    @Override
    public Future<List<DeviceConfig>> listAll(final String deviceId, final String tenantId, final int limit) {
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
                                            .mapTo(DeviceConfig.class)
                                            .execute(Map.of(ApiCommonConstants.DEVICE_ID_CAPTION, deviceId,
                                                    ApiCommonConstants.TENANT_ID_CAPTION, tenantId,
                                                    "limit", queryLimit))
                                            .map(rowSet -> {
                                                final List<DeviceConfig> configs = new ArrayList<>();
                                                rowSet.forEach(configs::add);
                                                return configs;
                                            })
                                            .onSuccess(success -> log.debug(
                                                    String.format("Listing all configs for device %s and tenant %s",
                                                            deviceId, tenantId)))
                                            .onFailure(throwable -> log.error("Error: {}", throwable.getMessage()));
                                }));
    }

    /**
     * Inserts a new config entity in to the database.
     *
     * @param sqlConnection The sql connection instance
     * @param entity The instance to insert
     * @return A Future of the created DeviceConfigEntity
     */
    private Future<DeviceConfigEntity> insert(final SqlConnection sqlConnection, final DeviceConfigEntity entity) {
        return SqlTemplate
                .forUpdate(sqlConnection, SQL_INSERT)
                .mapFrom(DeviceConfigEntity.class)
                .mapTo(DeviceConfigEntity.class)
                .execute(entity)
                .map(rowSet -> {
                    if (rowSet.rowCount() == 0) {
                        throw new IllegalStateException(String.format("Can't create device config: %s", entity));
                    }

                    final RowIterator<DeviceConfigEntity> iterator = rowSet.iterator();
                    entity.setVersion(iterator.next().getVersion());
                    return entity;

                })
                .onSuccess(success -> log.info("Device config created successfully: {}", success))
                .onFailure(throwable -> log.error(throwable.getMessage()));

    }

    /**
     * Delete the smallest config version.
     *
     * @param sqlConnection The sql connection instance
     * @param entity The device config for searching and deleting the smallest version
     * @return A Future of the deleted version
     */

    private Future<Integer> deleteMinVersion(final SqlConnection sqlConnection, final DeviceConfigEntity entity) {
        final RowMapper<Integer> rowMapper = row -> row.getInteger(VERSION_CAPTION);
        return SqlTemplate
                .forQuery(sqlConnection, SQL_DELETE_MIN_VERSION)
                .mapFrom(DeviceConfigEntity.class)
                .mapTo(rowMapper)
                .execute(entity)
                .map(rowSet -> {
                    final RowIterator<Integer> iterator = rowSet.iterator();
                    return iterator.next();
                })
                .onSuccess(deletedVersion -> log.debug(
                        "Device config version {} was deleted for device with id {} and tenant id {}", deletedVersion,
                        entity.getDeviceId(), entity.getTenantId()));
    }

    @Override
    public Future<DeviceConfigEntity> createNew(final DeviceConfigEntity entity) {
        return db.getDbClient().withTransaction(
                sqlConnection -> deviceRepository
                        .searchForDevice(entity.getDeviceId(), entity.getTenantId(), sqlConnection)
                        .compose(
                                counter -> {
                                    if (counter < 1) {
                                        throw new DeviceNotFoundException(
                                                String.format("Device with id %s and tenant id %s doesn't exist",
                                                        entity.getDeviceId(),
                                                        entity.getTenantId()));
                                    }
                                    return findMaxVersionAndTotalEntries(sqlConnection, entity.getDeviceId(),
                                            entity.getTenantId())
                                            .compose(
                                                    values -> {
                                                        final int total = values.getLeft();
                                                        final int maxVersion = values.getRight();

                                                        entity.setVersion(maxVersion + 1);

                                                        if (total > MAX_LIMIT - 1) {
                                                            return deleteMinVersion(sqlConnection, entity).compose(
                                                                    ok -> insert(sqlConnection, entity)

                                                    );
                                                        }
                                                        return insert(sqlConnection, entity);
                                                    });
                                }).onFailure(error -> log.error(error.getMessage())));
    }

    @Override
    public Future<Void> updateDeviceAckTime(final String tenantId, final String deviceId, final int configVersion,
            final String deviceAckTime) {
        final Map<String, Object> parameters = new HashMap<>();
        parameters.put(ApiCommonConstants.TENANT_ID_CAPTION, tenantId);
        parameters.put(ApiCommonConstants.DEVICE_ID_CAPTION, deviceId);
        parameters.put(VERSION_CAPTION, configVersion);
        parameters.put(DEVICE_ACK_TIME_CAPTION, deviceAckTime);
        return updateConfigField(parameters, SQL_UPDATE_DEVICE_ACK_TIME);
    }

    private Future<Void> updateConfigField(final Map<String, Object> parameters, final String sqlUpdateStatement) {
        return db.getDbClient().withTransaction(
                sqlConnection -> SqlTemplate
                        .forQuery(sqlConnection, sqlUpdateStatement)
                        .execute(parameters)
                        .flatMap(rowSet -> {
                            if (rowSet.rowCount() > 0) {
                                return Future.succeededFuture();
                            } else {
                                final var msg = "Cannot update config field. " +
                                        "Config with tenantId %s, deviceId %s and version %s does not exist."
                                                .formatted(parameters.get(ApiCommonConstants.TENANT_ID_CAPTION),
                                                        parameters.get(ApiCommonConstants.DEVICE_ID_CAPTION),
                                                        parameters.get(VERSION_CAPTION));
                                log.error(msg);
                                throw new NoSuchElementException(msg);
                            }
                        }));
    }

    @Override
    public Future<DeviceConfigEntity> getDeviceLatestConfig(final String tenantId, final String deviceId) {
        return db.getDbClient().withConnection(
                sqlConnection -> findMaxVersionAndTotalEntries(sqlConnection, deviceId, tenantId)
                        .compose(
                                values -> {
                                    final int total = values.getLeft();
                                    final int maxVersion = values.getRight();

                                    if (total == 0) {
                                        return Future.failedFuture(new NoSuchElementException(
                                                "No configs are found for device %s and tenant %s".formatted(deviceId,
                                                        tenantId)));
                                    }
                                    return findDeviceConfig(sqlConnection, tenantId, deviceId, maxVersion);

                                }

                        ));
    }

    private Future<DeviceConfigEntity> findDeviceConfig(final SqlConnection sqlConnection, final String tenantId,
            final String deviceId, final int version) {
        final Map<String, Object> parameters = new HashMap<>();
        parameters.put(ApiCommonConstants.DEVICE_ID_CAPTION, deviceId);
        parameters.put(ApiCommonConstants.TENANT_ID_CAPTION, tenantId);
        parameters.put(VERSION_CAPTION, version);

        return SqlTemplate
                .forQuery(sqlConnection, SQL_FIND_DEVICE_CONFIG)
                .mapTo(DeviceConfigEntity.class)
                .execute(parameters).map(rowSet -> {
                    final RowIterator<DeviceConfigEntity> iterator = rowSet.iterator();
                    return iterator.next();

                });

    }
}
