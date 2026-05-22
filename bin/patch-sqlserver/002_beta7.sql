DROP TABLE IF EXISTS [davinci_statistic_visitor_operation];
CREATE TABLE [davinci_statistic_visitor_operation]
(
    [id]           BIGINT NOT NULL AUTO_INCREMENT,
    [user_id]      BIGINT      DEFAULT NULL,
    [email]        NVARCHAR(255)    DEFAULT NULL,
    [action]       NVARCHAR(255)    DEFAULT NULL COMMENT 'login/visit/initial/sync/search/linkage/drill/download/print',
    [org_id]       BIGINT      DEFAULT NULL,
    [project_id]   BIGINT      DEFAULT NULL,
    [project_name] NVARCHAR(255)    DEFAULT NULL,
    [viz_type]     NVARCHAR(255)    DEFAULT NULL COMMENT 'dashboard/display',
    [viz_id]       BIGINT      DEFAULT NULL,
    [viz_name]     NVARCHAR(255)    DEFAULT NULL,
    [sub_viz_id]   BIGINT      DEFAULT NULL,
    [sub_viz_name] NVARCHAR(255)    DEFAULT NULL,
    [widget_id]    BIGINT      DEFAULT NULL,
    [widget_name]  NVARCHAR(255)    DEFAULT NULL,
    [variables]    NVARCHAR(500)    DEFAULT NULL,
    [filters]      NVARCHAR(500)    DEFAULT NULL,
    [groups]       NVARCHAR(500)    DEFAULT NULL,
    [create_time]  DATETIME2  NULL DEFAULT NULL,
    PRIMARY KEY ([id]) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

DROP TABLE IF EXISTS [davinci_statistic_terminal];
CREATE TABLE [davinci_statistic_terminal]
(
    [id]               BIGINT NOT NULL AUTO_INCREMENT,
    [user_id]          BIGINT      DEFAULT NULL,
    [email]            NVARCHAR(255)    DEFAULT NULL,
    [browser_name]     NVARCHAR(255)    DEFAULT NULL,
    [browser_version]  NVARCHAR(255)    DEFAULT NULL,
    [engine_name]      NVARCHAR(255)    DEFAULT NULL,
    [engine_version]   NVARCHAR(255)    DEFAULT NULL,
    [os_name]          NVARCHAR(255)    DEFAULT NULL,
    [os_version]       NVARCHAR(255)    DEFAULT NULL,
    [device_model]     NVARCHAR(255)    DEFAULT NULL,
    [device_type]      NVARCHAR(255)    DEFAULT NULL,
    [device_vendor]    NVARCHAR(255)    DEFAULT NULL,
    [cpu_architecture] NVARCHAR(255)    DEFAULT NULL,
    [create_time]      DATETIME2  NULL DEFAULT NULL,
    PRIMARY KEY ([id]) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;


DROP TABLE IF EXISTS [davinci_statistic_duration];
CREATE TABLE [davinci_statistic_duration]
(
    [id]         BIGINT NOT NULL AUTO_INCREMENT,
    [user_id]    BIGINT      DEFAULT NULL,
    [email]      NVARCHAR(255)    DEFAULT NULL,
    [start_time] DATETIME2  NULL DEFAULT NULL,
    [end_time]   DATETIME2  NULL DEFAULT NULL,
    PRIMARY KEY ([id]) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;


DROP TABLE IF EXISTS [share_download_record];
CREATE TABLE [share_download_record]
(
    [id]                 BIGINT   NOT NULL AUTO_INCREMENT,
    [uuid]               NVARCHAR(50)  DEFAULT NULL,
    [name]               NVARCHAR(255) NOT NULL,
    [path]               NVARCHAR(255) DEFAULT NULL,
    [status]             SMALLINT  NOT NULL,
    [create_time]        datetime     NOT NULL,
    [last_download_time] datetime     DEFAULT NULL,
    PRIMARY KEY ([id]) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

