/*
 * <<
 *  Davinci
 *  ==
 *  Copyright (C) 2016 - 2019 EDP
 *  ==
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *        http://www.apache.org/licenses/LICENSE-2.0
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 *  >>
 */

package edp.core.utils;

/**
 * System datasource dialect helpers (MySQL / SQL Server).
 */
public final class DatabaseDialect {

    public static final String MYSQL = "mysql";
    public static final String SQLSERVER = "sqlserver";

    private DatabaseDialect() {
    }

    public static String resolveFromJdbcUrl(String jdbcUrl) {
        if (jdbcUrl == null || jdbcUrl.trim().isEmpty()) {
            return MYSQL;
        }
        if (isSqlServerJdbcUrl(jdbcUrl.trim().toLowerCase())) {
            return SQLSERVER;
        }
        return MYSQL;
    }

    /**
     * Microsoft JDBC ({@code jdbc:sqlserver:}) and jTDS ({@code jdbc:jtds:sqlserver:}).
     */
    public static boolean isSqlServerJdbcUrl(String jdbcUrlLowerCase) {
        return jdbcUrlLowerCase.startsWith("jdbc:sqlserver:")
                || jdbcUrlLowerCase.startsWith("jdbc:jtds:sqlserver:");
    }

    public static String pageHelperDialect(String jdbcUrl) {
        return SQLSERVER.equals(resolveFromJdbcUrl(jdbcUrl)) ? SQLSERVER : MYSQL;
    }

    public static String mapperIdentity(String jdbcUrl) {
        return SQLSERVER.equals(resolveFromJdbcUrl(jdbcUrl)) ? "SQLSERVER" : "MYSQL";
    }

    public static boolean isSqlServer(String jdbcUrl) {
        return SQLSERVER.equals(resolveFromJdbcUrl(jdbcUrl));
    }

    public static boolean isMySql(String jdbcUrl) {
        return !isSqlServer(jdbcUrl);
    }
}
