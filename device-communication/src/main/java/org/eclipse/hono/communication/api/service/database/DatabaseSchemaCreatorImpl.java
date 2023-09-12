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

package org.eclipse.hono.communication.api.service.database;

import java.util.ArrayList;
import java.util.List;

import javax.enterprise.context.ApplicationScoped;

import org.eclipse.hono.communication.api.config.DeviceConfigsConstants;
import org.eclipse.hono.communication.api.config.DeviceStatesConstants;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.quarkus.runtime.Quarkus;
import io.vertx.core.Future;
import io.vertx.core.Vertx;

/**
 * Creates all Database tables if they do not exist.
 */

@ApplicationScoped
public class DatabaseSchemaCreatorImpl implements DatabaseSchemaCreator {

    private static final Logger log = LoggerFactory.getLogger(DatabaseSchemaCreatorImpl.class);
    private final Vertx vertx;
    private final DatabaseService db;

    /**
     * Creates a new DatabaseSchemaCreatorImpl.
     *
     * @param vertx The quarkus Vertx instance
     * @param db The database service
     */
    public DatabaseSchemaCreatorImpl(final Vertx vertx, final DatabaseService db) {
        this.vertx = vertx;
        this.db = db;
    }

    @Override
    public void setupDBTables() {
        vertx.executeBlocking(promise -> {
            setupTable(DeviceConfigsConstants.CREATE_SQL_SCRIPT_PATH, "device_config");
            setupTable(DeviceStatesConstants.CREATE_SQL_SCRIPT_PATH, "device_status");
            promise.complete();
        });
    }

    @Override
    public void setupTable(final String filePath, final String tableName) {
        log.info("Setting up table {} with SQL statements from file {}", tableName, filePath);

        try {
            final String sqlContent = vertx.fileSystem().readFileBlocking(filePath).toString();
            final List<String> validStatements = createValidStatementsList(sqlContent);

            db.getDbClient().withConnection(sqlConnection -> {
                for (String statement : validStatements) {
                    sqlConnection
                            .query(statement)
                            .execute()
                            .onFailure(thr -> {
                                log.error("Failed to set up table. Statement: {}.", statement, thr);
                                db.close();
                                Quarkus.asyncExit(-1);
                            });
                }
                return Future.succeededFuture();
            });
            log.info("Successfully set up table: {}.", tableName);
        } catch (RuntimeException e) {
            log.error("Failed to read SQL file for table {}", tableName, e);
            Quarkus.asyncExit(-1);
        }
    }

    private List<String> createValidStatementsList(final String sqlContent) {
        final String[] sqlStatements = sqlContent.split(";");
        final List<String> validStatements = new ArrayList<>();
        for (String sql : sqlStatements) {
            final String trimmedSql = sql.trim();
            if (!trimmedSql.isEmpty()) {
                validStatements.add(trimmedSql);
            }
        }
        return validStatements;
    }
}
