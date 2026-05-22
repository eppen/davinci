-- SQL Server: beta.4 -> beta.5 migration. Review before apply.
set @data_base = 'davinci0.3';

DROP TABLE IF EXISTS [platform];
CREATE TABLE [platform]
(
    [id]               BIGINT   NOT NULL,
    [name]             NVARCHAR(255) NOT NULL,
    [platform]         NVARCHAR(255) NOT NULL,
    [code]             NVARCHAR(32)  NOT NULL,
    [checkCode]        NVARCHAR(255) DEFAULT NULL,
    [checkSystemToken] NVARCHAR(255) DEFAULT NULL,
    [checkUrl]         NVARCHAR(255) DEFAULT NULL,
    [alternateField1]  NVARCHAR(255) DEFAULT NULL,
    [alternateField2]  NVARCHAR(255) DEFAULT NULL,
    [alternateField3]  NVARCHAR(255) DEFAULT NULL,
    [alternateField4]  NVARCHAR(255) DEFAULT NULL,
    [alternateField5]  NVARCHAR(255) DEFAULT NULL,
    PRIMARY KEY ([id]) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

DROP TABLE IF EXISTS [download_record];
CREATE TABLE [download_record]
(
    [id]                 BIGINT   NOT NULL AUTO_INCREMENT,
    [name]               NVARCHAR(255) NOT NULL,
    [user_id]            BIGINT   NOT NULL,
    [path]               NVARCHAR(255) DEFAULT NULL,
    [status]             SMALLINT  NOT NULL,
    [create_time]        datetime     NOT NULL,
    [last_download_time] datetime     DEFAULT NULL,
    PRIMARY KEY ([id]) USING BTREE,
    KEY [idx_user] ([user_id]) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;


DROP TABLE IF EXISTS [rel_project_admin];
CREATE TABLE [rel_project_admin]
(
    [id]          BIGINT NOT NULL AUTO_INCREMENT,
    [project_id]  BIGINT NOT NULL,
    [user_id]     BIGINT NOT NULL,
    [create_by]   BIGINT DEFAULT NULL,
    [create_time] datetime   DEFAULT NULL,
    [update_by]   BIGINT DEFAULT NULL,
    [update_time] datetime   DEFAULT NULL,
    PRIMARY KEY ([id]) USING BTREE,
    UNIQUE KEY [idx_project_user] ([project_id], [user_id]) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 6
  DEFAULT CHARSET = utf8mb4;


DROP TABLE IF EXISTS [rel_role_dashboard];
CREATE TABLE [rel_role_dashboard]
(
    [role_id]      BIGINT NOT NULL,
    [dashboard_id] BIGINT NOT NULL,
    [visible]      tinyint(1) NOT NULL DEFAULT '0',
    [create_by]    BIGINT          DEFAULT NULL,
    [create_time]  datetime            DEFAULT NULL,
    [update_by]    BIGINT          DEFAULT NULL,
    [update_time]  datetime            DEFAULT NULL,
    PRIMARY KEY ([role_id], [dashboard_id]) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;


DROP TABLE IF EXISTS [rel_role_display];
CREATE TABLE [rel_role_display]
(
    [role_id]     BIGINT NOT NULL,
    [display_id]  BIGINT NOT NULL,
    [visible]     tinyint(1) NOT NULL DEFAULT '0',
    [create_by]   BIGINT          DEFAULT NULL,
    [create_time] datetime            DEFAULT NULL,
    [update_by]   BIGINT          DEFAULT NULL,
    [update_time] datetime            DEFAULT NULL,
    PRIMARY KEY ([role_id], [display_id]) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;


DROP TABLE IF EXISTS [rel_role_portal];
CREATE TABLE [rel_role_portal]
(
    [role_id]     BIGINT NOT NULL,
    [portal_id]   BIGINT NOT NULL,
    [visible]     tinyint(1) NOT NULL DEFAULT '0',
    [create_by]   BIGINT          DEFAULT NULL,
    [create_time] datetime            DEFAULT NULL,
    [update_by]   BIGINT          DEFAULT NULL,
    [update_time] datetime            DEFAULT NULL,
    PRIMARY KEY ([role_id], [portal_id]) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;


DROP TABLE IF EXISTS [rel_role_project];
CREATE TABLE [rel_role_project]
(
    [id]                  BIGINT  NOT NULL AUTO_INCREMENT,
    [project_id]          BIGINT  NOT NULL,
    [role_id]             BIGINT  NOT NULL,
    [source_permission]   SMALLINT NOT NULL DEFAULT '1',
    [view_permission]     SMALLINT NOT NULL DEFAULT '1',
    [widget_permission]   SMALLINT NOT NULL DEFAULT '1',
    [viz_permission]      SMALLINT NOT NULL DEFAULT '1',
    [schedule_permission] SMALLINT NOT NULL DEFAULT '1',
    [share_permission]    tinyint(1)  NOT NULL DEFAULT '0',
    [download_permission] tinyint(1)  NOT NULL DEFAULT '0',
    [create_by]           BIGINT           DEFAULT NULL,
    [create_time]         datetime             DEFAULT NULL,
    [update_by]           BIGINT           DEFAULT NULL,
    [update_time]         datetime             DEFAULT NULL,
    PRIMARY KEY ([id]) USING BTREE,
    UNIQUE KEY [idx_role_project] ([project_id], [role_id]) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 40
  DEFAULT CHARSET = utf8mb4;


DROP TABLE IF EXISTS [rel_role_slide];
CREATE TABLE [rel_role_slide]
(
    [role_id]     BIGINT NOT NULL,
    [slide_id]    BIGINT NOT NULL,
    [visible]     tinyint(1) NOT NULL DEFAULT '0',
    [create_by]   BIGINT          DEFAULT NULL,
    [create_time] datetime            DEFAULT NULL,
    [update_by]   BIGINT          DEFAULT NULL,
    [update_time] datetime            DEFAULT NULL,
    PRIMARY KEY ([role_id], [slide_id]) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;


DROP TABLE IF EXISTS [rel_role_user];
CREATE TABLE [rel_role_user]
(
    [id]          BIGINT NOT NULL AUTO_INCREMENT,
    [user_id]     BIGINT NOT NULL,
    [role_id]     BIGINT NOT NULL,
    [create_by]   BIGINT DEFAULT NULL,
    [create_time] datetime   DEFAULT NULL,
    [update_by]   BIGINT DEFAULT NULL,
    [update_time] datetime   DEFAULT NULL,
    PRIMARY KEY ([id]) USING BTREE,
    UNIQUE KEY [idx_role_user] ([user_id], [role_id]) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 30
  DEFAULT CHARSET = utf8mb4;


DROP TABLE IF EXISTS [rel_role_view];
CREATE TABLE [rel_role_view]
(
    [view_id]     BIGINT NOT NULL,
    [role_id]     BIGINT NOT NULL,
    [row_auth]    NVARCHAR(MAX),
    [column_auth] NVARCHAR(MAX),
    [create_by]   BIGINT DEFAULT NULL,
    [create_time] datetime   DEFAULT NULL,
    [update_by]   BIGINT DEFAULT NULL,
    [update_time] datetime   DEFAULT NULL,
    PRIMARY KEY ([view_id], [role_id]) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;


DROP TABLE IF EXISTS [role];
CREATE TABLE [role]
(
    [id]          BIGINT   NOT NULL AUTO_INCREMENT,
    [org_id]      BIGINT   NOT NULL,
    [name]        NVARCHAR(100) NOT NULL,
    [description] NVARCHAR(255) DEFAULT NULL,
    [avatar]      NVARCHAR(255) DEFAULT NULL,
    [create_by]   BIGINT   DEFAULT NULL,
    [create_time] datetime     DEFAULT NULL,
    [update_by]   BIGINT   DEFAULT NULL,
    [update_time] datetime     DEFAULT NULL,
    PRIMARY KEY ([id]) USING BTREE,
    KEY [idx_orgid] ([org_id]) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 24
  DEFAULT CHARSET = utf8mb4;


DROP TABLE IF EXISTS [rel_role_display_slide_widget];
CREATE TABLE [rel_role_display_slide_widget]
(
    [role_id]                     BIGINT NOT NULL,
    [mem_display_slide_widget_id] BIGINT NOT NULL,
    [visible]                     tinyint(1) NOT NULL DEFAULT '0',
    [create_by]                   BIGINT          DEFAULT NULL,
    [create_time]                 datetime            DEFAULT NULL,
    [update_by]                   BIGINT          DEFAULT NULL,
    [update_time]                 datetime            DEFAULT NULL,
    PRIMARY KEY ([role_id], [mem_display_slide_widget_id]) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;


DROP TABLE IF EXISTS [rel_role_dashboard_widget];
CREATE TABLE [rel_role_dashboard_widget]
(
    [role_id]                 BIGINT NOT NULL,
    [mem_dashboard_widget_id] BIGINT NOT NULL,
    [visible]                 tinyint(1) NOT NULL DEFAULT '0',
    [create_by]               BIGINT          DEFAULT NULL,
    [create_time]             datetime            DEFAULT NULL,
    [update_by]               BIGINT          DEFAULT NULL,
    [update_time]             datetime            DEFAULT NULL,
    PRIMARY KEY ([role_id], [mem_dashboard_widget_id]) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;


ALTER TABLE dbo.[dbo].[organization]
    ADD INDEX [idx_user_id] ([user_id]),
    ADD INDEX [idx_allow_create_project] ([allow_create_project]),
    ADD INDEX [idx_member_permisson] ([member_permission]);

ALTER TABLE dbo.[dbo].[project]
    ADD INDEX [idx_org_id] ([org_id]),
    ADD INDEX [idx_user_id] ([user_id]),
    ADD INDEX [idx_visibility] ([visibility]);

ALTER TABLE dbo.[dbo].[rel_user_organization]
    ADD INDEX [idx_role] ([role]);



SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'cron_job'
                                AND column_name = 'update_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[cron_job] ADD [update_by] BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'cron_job'
                                AND column_name = 'parent_id') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[cron_job] ADD [parent_id] BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'cron_job'
                                AND column_name = 'full_parent_id') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[cron_job]  ADD [full_parent_id]  NVARCHAR(100)  DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'cron_job'
                                AND column_name = 'is_folder') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[cron_job]  ADD [is_folder]  tinyint(1) DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'cron_job'
                                AND column_name = 'index') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[cron_job] ADD [index] INT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'dashboard'
                                AND column_name = 'full_parent_Id') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[dashboard] ADD [full_parent_Id]  NVARCHAR(100) DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'dashboard'
                                AND column_name = 'create_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[dashboard] ADD [create_by] BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'dashboard'
                                AND column_name = 'create_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[dashboard] ADD [create_time] datetime DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'dashboard'
                                AND column_name = 'update_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[dashboard] ADD [update_by] BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'dashboard'
                                AND column_name = 'update_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[dashboard] ADD [update_time]     datetime DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'dashboard_portal'
                                AND column_name = 'create_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[dashboard_portal] ADD [create_by]   BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'dashboard_portal'
                                AND column_name = 'create_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[dashboard_portal] ADD [create_time] datetime DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'dashboard_portal'
                                AND column_name = 'update_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[dashboard_portal]  ADD [update_by]   BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'dashboard_portal'
                                AND column_name = 'update_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[dashboard_portal] ADD [update_time] datetime DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'display'
                                AND column_name = 'create_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[display] ADD [create_by]   BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'display'
                                AND column_name = 'create_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[display] ADD [create_time] datetime DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'display'
                                AND column_name = 'update_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[display] ADD [update_by]   BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'display'
                                AND column_name = 'update_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[display] ADD [update_time] datetime DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'display_slide'
                                AND column_name = 'create_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[display_slide] ADD [create_by]   BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'display_slide'
                                AND column_name = 'create_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[display_slide] ADD [create_time] datetime DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'display_slide'
                                AND column_name = 'update_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[display_slide] ADD [update_by]   BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'display_slide'
                                AND column_name = 'update_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[display_slide] ADD [update_time] datetime DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'mem_dashboard_widget'
                                AND column_name = 'config') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[mem_dashboard_widget] ADD [config] NVARCHAR(MAX);"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'mem_dashboard_widget'
                                AND column_name = 'create_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[mem_dashboard_widget] ADD [create_by]  BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'mem_dashboard_widget'
                                AND column_name = 'create_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[mem_dashboard_widget] ADD [create_time] datetime DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'mem_dashboard_widget'
                                AND column_name = 'update_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[mem_dashboard_widget] ADD [update_by]   BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'mem_dashboard_widget'
                                AND column_name = 'update_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[mem_dashboard_widget] ADD [update_time] datetime DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'mem_display_slide_widget'
                                AND column_name = 'create_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[mem_display_slide_widget] ADD [create_by]   BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'mem_display_slide_widget'
                                AND column_name = 'create_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[mem_display_slide_widget] ADD [create_time] datetime DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'mem_display_slide_widget'
                                AND column_name = 'update_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[mem_display_slide_widget] ADD [update_by]   BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'mem_display_slide_widget'
                                AND column_name = 'update_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[mem_display_slide_widget] ADD [update_time] datetime DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'project'
                                AND column_name = 'create_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[project] ADD [create_by]   BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'project'
                                AND column_name = 'create_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[project] ADD [create_time] datetime NULL DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'project'
                                AND column_name = 'update_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[project] ADD [update_by]   BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'project'
                                AND column_name = 'update_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[project] ADD [update_time] datetime DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'source'
                                AND column_name = 'create_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[source] ADD [create_by] BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'source'
                                AND column_name = 'create_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[source] ADD [create_time] datetime DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'source'
                                AND column_name = 'update_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[source] ADD [update_by] BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'source'
                                AND column_name = 'update_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[source] ADD [update_time] datetime DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'source'
                                AND column_name = 'parent_id') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[source] ADD [parent_id] BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'source'
                                AND column_name = 'full_parent_id') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[source] ADD [full_parent_id] NVARCHAR(255) DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'source'
                                AND column_name = 'is_folder') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[source] ADD [is_folder] tinyint(1) DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'source'
                                AND column_name = 'index') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[source] ADD [index] INT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'view'
                                AND column_name = 'variable') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[view] ADD [variable] NVARCHAR(MAX);"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'view'
                                AND column_name = 'create_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[view] ADD [create_by] BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'view'
                                AND column_name = 'create_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[view] ADD [create_time] datetime DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'view'
                                AND column_name = 'update_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[view] ADD [update_by] BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'view'
                                AND column_name = 'update_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[view] ADD [update_time] datetime DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;



SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'view'
                                AND column_name = 'parent_id') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[view] ADD [parent_id] BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'view'
                                AND column_name = 'full_parent_id') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[view] ADD [full_parent_id] NVARCHAR(255) DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'view'
                                AND column_name = 'is_folder') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[view] ADD [is_folder] tinyint(1) DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'view'
                                AND column_name = 'index') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[view] ADD [index] INT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'rel_user_organization'
                                AND column_name = 'create_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[rel_user_organization] ADD [create_by] BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'rel_user_organization'
                                AND column_name = 'create_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[rel_user_organization] ADD [create_time] datetime DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'rel_user_organization'
                                AND column_name = 'update_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[rel_user_organization] ADD [update_by] BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'rel_user_organization'
                                AND column_name = 'update_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[rel_user_organization] ADD [update_time] datetime DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'widget'
                                AND column_name = 'create_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[widget] ADD [create_by] BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'widget'
                                AND column_name = 'create_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[widget] ADD [create_time] datetime DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'widget'
                                AND column_name = 'update_by') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[widget] ADD [update_by] BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'widget'
                                AND column_name = 'update_time') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[widget] ADD [update_time] datetime DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'widget'
                                AND column_name = 'parent_id') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[widget] ADD [parent_id] BIGINT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'widget'
                                AND column_name = 'full_parent_id') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[widget] ADD [full_parent_id] NVARCHAR(255) DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'widget'
                                AND column_name = 'is_folder') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[widget] ADD [is_folder] NVARCHAR(255) DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;



SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'widget'
                                AND column_name = 'index') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[widget] ADD [index] INT DEFAULT NULL;"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = (SELECT IF(
                             (SELECT COUNT(*)
                              FROM INFORMATION_SCHEMA.COLUMNS
                              WHERE table_schema = @data_base
                                AND table_name = 'organization'
                                AND column_name = 'role_num') > 0,
                             "SELECT 1",
                             "ALTER TABLE dbo.[dbo].[organization] CHANGE COLUMN [team_num] [role_num] INT NULL DEFAULT 0 AFTER [member_num];"
                     ));

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

update organization
set role_num = 0;

update download_record
set status = 4
where last_download_time is not null
  and status = 2;
