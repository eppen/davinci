/*
 * Phase 1: Chart Registry (SQL Server)
 */

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'chart_type')
BEGIN
    CREATE TABLE chart_type (
        id              BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        code            NVARCHAR(64)  NOT NULL,
        name            NVARCHAR(64)  NOT NULL,
        title           NVARCHAR(128) NOT NULL,
        category        NVARCHAR(32)  NOT NULL DEFAULT 'general',
        icon            NVARCHAR(64)  NULL,
        renderer        NVARCHAR(32)  NOT NULL DEFAULT 'echarts',
        config_schema   NVARCHAR(MAX) NOT NULL,
        data_schema     NVARCHAR(MAX) NOT NULL,
        option_template NVARCHAR(MAX) NULL,
        version         INT           NOT NULL DEFAULT 1,
        builtin         BIT           NOT NULL DEFAULT 0,
        enabled         BIT           NOT NULL DEFAULT 1,
        description     NVARCHAR(512) NULL,
        create_by       BIGINT        NULL,
        create_time     DATETIME      NULL,
        update_by       BIGINT        NULL,
        update_time     DATETIME      NULL,
        CONSTRAINT uk_chart_type_code UNIQUE (code)
    );
END
