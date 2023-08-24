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

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.MockedStatic;

import io.quarkus.runtime.Quarkus;
import io.vertx.core.Future;
import io.vertx.core.Vertx;
import io.vertx.core.buffer.Buffer;
import io.vertx.core.file.FileSystem;
import io.vertx.pgclient.PgConnection;
import io.vertx.pgclient.PgPool;

class DatabaseSchemaCreatorImplTest {

    private final Vertx vertxMock;
    private final FileSystem fileSystemMock;
    private final PgPool pgPoolMock;
    private final DatabaseService databaseServiceMock;
    private final PgConnection pgConnection;
    private DatabaseSchemaCreatorImpl databaseSchemaCreator;

    DatabaseSchemaCreatorImplTest() {
        vertxMock = mock(Vertx.class);
        fileSystemMock = mock(FileSystem.class);
        pgPoolMock = mock(PgPool.class);
        databaseServiceMock = mock(DatabaseService.class);
        pgConnection = mock(PgConnection.class);
    }

    @BeforeEach
    void setUp() {
        databaseSchemaCreator = new DatabaseSchemaCreatorImpl(vertxMock, databaseServiceMock);
    }

    @AfterEach
    void tearDown() {
        verifyNoMoreInteractions(vertxMock, pgConnection, databaseServiceMock, pgPoolMock, fileSystemMock);
    }

    @Test
    void setupTable_succeeds() {
        final Buffer buffer = Buffer.buffer(
                "CREATE TABLE test_table (id serial primary key, value varchar(10)); " +
                        "CREATE INDEX IF NOT EXISTS idx_test ON test_table (value);");
        when(vertxMock.fileSystem()).thenReturn(fileSystemMock);
        when(fileSystemMock.readFileBlocking(anyString())).thenReturn(buffer);
        when(databaseServiceMock.getDbClient()).thenReturn(pgPoolMock);
        when(pgPoolMock.withConnection(any())).thenReturn(Future.succeededFuture());

        databaseSchemaCreator.setupTable("valid/file/path", "test_table");

        verify(vertxMock).fileSystem();
        verify(fileSystemMock).readFileBlocking(anyString());
        verify(databaseServiceMock).getDbClient();
        verify(pgPoolMock).withConnection(any());
    }

    @Test
    void setupTable_readFileBlockingFails() {
        try (MockedStatic<Quarkus> quarkusMock = mockStatic(Quarkus.class)) {
            when(vertxMock.fileSystem()).thenReturn(fileSystemMock);
            when(fileSystemMock.readFileBlocking(anyString())).thenThrow(new RuntimeException());

            databaseSchemaCreator.setupTable("invalid/file/path", "test_table");

            verify(vertxMock).fileSystem();
            verify(fileSystemMock).readFileBlocking(anyString());
            quarkusMock.verify(() -> Quarkus.asyncExit(-1));
        }
    }
}
