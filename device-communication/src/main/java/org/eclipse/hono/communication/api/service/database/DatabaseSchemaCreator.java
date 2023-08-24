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

/**
 * Interface for setting up database tables at application startup.
 */
public interface DatabaseSchemaCreator {

    /**
     * Sets up the database tables.
     */
    void setupDBTables();

    /**
     * Sets up a database table.
     *
     * @param filePath Path to the SQL script file
     * @param tableName Name of the table
     */
    void setupTable(String filePath, String tableName);
}
