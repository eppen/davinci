-- Davinci system database schema for Microsoft SQL Server
-- Generated from bin/davinci.sql

IF OBJECT_ID(N'dbo.cron_job', N'U') IS NOT NULL DROP TABLE dbo.[cron_job];
CREATE TABLE dbo.[cron_job] (
    [id]              BIGINT                          NOT NULL IDENTITY(1,1),
    [name]            NVARCHAR(45) NOT NULL,
    [project_id]      BIGINT                          NOT NULL,
    [job_type]        NVARCHAR(45) NOT NULL,
    [job_status]      NVARCHAR(10) NOT NULL DEFAULT N'',
    [cron_expression] NVARCHAR(45) NOT NULL,
    [start_date]      DATETIME2                            NOT NULL,
    [end_date]        DATETIME2                            NOT NULL,
    [config]          NVARCHAR(MAX)        NOT NULL,
    [description]     NVARCHAR(255)         DEFAULT NULL,
    [exec_log]        NVARCHAR(MAX),
    [create_by]       BIGINT                          NOT NULL,
    [create_time]     DATETIME2                           NOT NULL DEFAULT GETDATE(),
    [update_by]       BIGINT                                   DEFAULT NULL,
    [update_time]     DATETIME2                           NULL     DEFAULT NULL,
    [parent_id]       BIGINT                                   DEFAULT NULL,
    [full_parent_id]  NVARCHAR(255)         DEFAULT NULL,
    [is_folder]       TINYINT                                   DEFAULT NULL,
    [index]           INT                                       DEFAULT NULL,
    PRIMARY KEY ([id]),
    CONSTRAINT [idx_name_project] UNIQUE ([name],[project_id])
);
GO

IF OBJECT_ID(N'dbo.dashboard', N'U') IS NOT NULL DROP TABLE dbo.[dashboard];
CREATE TABLE dbo.[dashboard] (
    [id]                  BIGINT   NOT NULL IDENTITY(1,1),
    [name]                NVARCHAR(255) NOT NULL,
    [dashboard_portal_id] BIGINT   NOT NULL,
    [type]                SMALLINT  NOT NULL,
    [index]               INT       NOT NULL,
    [parent_id]           BIGINT   NOT NULL DEFAULT 0,
    [config]              NVARCHAR(MAX),
    [full_parent_Id]      NVARCHAR(100)          DEFAULT NULL,
    [create_by]           BIGINT            DEFAULT NULL,
    [create_time]         DATETIME2              DEFAULT NULL,
    [update_by]           BIGINT            DEFAULT NULL,
    [update_time]         DATETIME2              DEFAULT NULL,
    PRIMARY KEY ([id])
);
GO

IF OBJECT_ID(N'dbo.dashboard_portal', N'U') IS NOT NULL DROP TABLE dbo.[dashboard_portal];
CREATE TABLE dbo.[dashboard_portal] (
    [id]          BIGINT   NOT NULL IDENTITY(1,1),
    [name]        NVARCHAR(255) NOT NULL,
    [description] NVARCHAR(255)          DEFAULT NULL,
    [project_id]  BIGINT   NOT NULL,
    [avatar]      NVARCHAR(255)          DEFAULT NULL,
    [publish]     TINYINT   NOT NULL DEFAULT 0,
    [create_by]   BIGINT            DEFAULT NULL,
    [create_time] DATETIME2              DEFAULT NULL,
    [update_by]   BIGINT            DEFAULT NULL,
    [update_time] DATETIME2              DEFAULT NULL,
    PRIMARY KEY ([id])
);
GO

IF OBJECT_ID(N'dbo.display', N'U') IS NOT NULL DROP TABLE dbo.[display];
CREATE TABLE dbo.[display] (
    [id]          BIGINT   NOT NULL IDENTITY(1,1),
    [name]        NVARCHAR(255) NOT NULL,
    [description] NVARCHAR(255) DEFAULT NULL,
    [project_id]  BIGINT   NOT NULL,
    [avatar]      NVARCHAR(255) DEFAULT NULL,
    [publish]     TINYINT   NOT NULL,
    [config]      NVARCHAR(MAX)         NULL,
    [create_by]   BIGINT   DEFAULT NULL,
    [create_time] DATETIME2     DEFAULT NULL,
    [update_by]   BIGINT   DEFAULT NULL,
    [update_time] DATETIME2     DEFAULT NULL,
    PRIMARY KEY ([id])
);
GO

IF OBJECT_ID(N'dbo.display_slide', N'U') IS NOT NULL DROP TABLE dbo.[display_slide];
CREATE TABLE dbo.[display_slide] (
    [id]          BIGINT NOT NULL IDENTITY(1,1),
    [display_id]  BIGINT NOT NULL,
    [index]       INT    NOT NULL,
    [config]      NVARCHAR(MAX)       NOT NULL,
    [create_by]   BIGINT DEFAULT NULL,
    [create_time] DATETIME2   DEFAULT NULL,
    [update_by]   BIGINT DEFAULT NULL,
    [update_time] DATETIME2   DEFAULT NULL,
    PRIMARY KEY ([id])
);
GO

IF OBJECT_ID(N'dbo.download_record', N'U') IS NOT NULL DROP TABLE dbo.[download_record];
CREATE TABLE dbo.[download_record] (
    [id]                 BIGINT   NOT NULL IDENTITY(1,1),
    [name]               NVARCHAR(255) NOT NULL,
    [user_id]            BIGINT   NOT NULL,
    [path]               NVARCHAR(255) DEFAULT NULL,
    [status]             SMALLINT  NOT NULL,
    [create_time]        DATETIME2     NOT NULL,
    [last_download_time] DATETIME2     DEFAULT NULL,
    PRIMARY KEY ([id])
);
GO

IF OBJECT_ID(N'dbo.favorite', N'U') IS NOT NULL DROP TABLE dbo.[favorite];
CREATE TABLE dbo.[favorite] (
    [id]          BIGINT NOT NULL IDENTITY(1,1),
    [user_id]     BIGINT NOT NULL,
    [project_id]  BIGINT NOT NULL,
    [create_time] DATETIME2   NOT NULL ,
    PRIMARY KEY ([id]),
    CONSTRAINT [idx_user_project] UNIQUE ([user_id], [project_id])
);
GO

IF OBJECT_ID(N'dbo.mem_dashboard_widget', N'U') IS NOT NULL DROP TABLE dbo.[mem_dashboard_widget];
CREATE TABLE dbo.[mem_dashboard_widget] (
    [id]           BIGINT NOT NULL IDENTITY(1,1),
    [alias]        NVARCHAR(30) NULL,
    [dashboard_id] BIGINT NOT NULL,
    [widget_Id]    BIGINT          DEFAULT NULL,
    [x]            INT    NOT NULL,
    [y]            INT    NOT NULL,
    [width]        INT    NOT NULL,
    [height]       INT    NOT NULL,
    [polling]      TINYINT NOT NULL DEFAULT 0,
    [frequency]    INT             DEFAULT NULL,
    [config]       NVARCHAR(MAX),
    [create_by]    BIGINT          DEFAULT NULL,
    [create_time]  DATETIME2            DEFAULT NULL,
    [update_by]    BIGINT          DEFAULT NULL,
    [update_time]  DATETIME2            DEFAULT NULL,
    PRIMARY KEY ([id])
);
GO

IF OBJECT_ID(N'dbo.mem_display_slide_widget', N'U') IS NOT NULL DROP TABLE dbo.[mem_display_slide_widget];
CREATE TABLE dbo.[mem_display_slide_widget] (
    [id]               BIGINT   NOT NULL IDENTITY(1,1),
    [display_slide_id] BIGINT   NOT NULL,
    [widget_id]        BIGINT            DEFAULT NULL,
    [name]             NVARCHAR(255) NOT NULL,
    [params]           NVARCHAR(MAX)         NOT NULL,
    [type]             SMALLINT  NOT NULL,
    [sub_type]         SMALLINT           DEFAULT NULL,
    [index]            INT      NOT NULL DEFAULT 0,
    [create_by]        BIGINT            DEFAULT NULL,
    [create_time]      DATETIME2              DEFAULT NULL,
    [update_by]        BIGINT            DEFAULT NULL,
    [update_time]      DATETIME2              DEFAULT NULL,
    PRIMARY KEY ([id])
);
GO

IF OBJECT_ID(N'dbo.organization', N'U') IS NOT NULL DROP TABLE dbo.[organization];
CREATE TABLE dbo.[organization] (
    [id]                   BIGINT   NOT NULL IDENTITY(1,1),
    [name]                 NVARCHAR(255) NOT NULL,
    [description]          NVARCHAR(255)          DEFAULT NULL,
    [avatar]               NVARCHAR(255)          DEFAULT NULL,
    [user_id]              BIGINT   NOT NULL,
    [project_num]          INT               DEFAULT 0,
    [member_num]           INT               DEFAULT 0,
    [role_num]             INT               DEFAULT 0,
    [allow_create_project] TINYINT            DEFAULT 1,
    [member_permission]    SMALLINT  NOT NULL DEFAULT 0,
    [create_time]          DATETIME2    NOT NULL DEFAULT GETDATE(),
    [create_by]            BIGINT   NOT NULL DEFAULT 0,
    [update_time]          DATETIME2    NULL,
    [update_by]            BIGINT            DEFAULT NULL,
    PRIMARY KEY ([id])
);
GO

IF OBJECT_ID(N'dbo.platform', N'U') IS NOT NULL DROP TABLE dbo.[platform];
CREATE TABLE dbo.[platform] (
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
    PRIMARY KEY ([id])
);
GO

IF OBJECT_ID(N'dbo.project', N'U') IS NOT NULL DROP TABLE dbo.[project];
CREATE TABLE dbo.[project] (
    [id]             BIGINT   NOT NULL IDENTITY(1,1),
    [name]           NVARCHAR(255) NOT NULL,
    [description]    NVARCHAR(255)          DEFAULT NULL,
    [pic]            NVARCHAR(255)          DEFAULT NULL,
    [org_id]         BIGINT   NOT NULL,
    [user_id]        BIGINT   NOT NULL,
    [visibility]     TINYINT            DEFAULT 1,
    [star_num]       INT               DEFAULT 0,
    [is_transfer]    TINYINT   NOT NULL DEFAULT 0,
    [initial_org_id] BIGINT   NOT NULL,
    [create_by]      BIGINT            DEFAULT NULL,
    [create_time]    DATETIME2              DEFAULT NULL,
    [update_by]      BIGINT            DEFAULT NULL,
    [update_time]    DATETIME2              DEFAULT NULL,
    PRIMARY KEY ([id])
);
GO

IF OBJECT_ID(N'dbo.rel_project_admin', N'U') IS NOT NULL DROP TABLE dbo.[rel_project_admin];
CREATE TABLE dbo.[rel_project_admin] (
    [id]          BIGINT NOT NULL IDENTITY(1,1),
    [project_id]  BIGINT NOT NULL,
    [user_id]     BIGINT NOT NULL,
    [create_by]   BIGINT DEFAULT NULL,
    [create_time] DATETIME2   DEFAULT NULL,
    [update_by]   BIGINT DEFAULT NULL,
    [update_time] DATETIME2   DEFAULT NULL,
    PRIMARY KEY ([id]),
    CONSTRAINT [idx_project_user] UNIQUE ([project_id], [user_id])
);
GO

IF OBJECT_ID(N'dbo.rel_role_dashboard', N'U') IS NOT NULL DROP TABLE dbo.[rel_role_dashboard];
CREATE TABLE dbo.[rel_role_dashboard] (
    [role_id]      BIGINT NOT NULL,
    [dashboard_id] BIGINT NOT NULL,
    [visible]      TINYINT NOT NULL DEFAULT 0,
    [create_by]    BIGINT          DEFAULT NULL,
    [create_time]  DATETIME2            DEFAULT NULL,
    [update_by]    BIGINT          DEFAULT NULL,
    [update_time]  DATETIME2            DEFAULT NULL,
    PRIMARY KEY ([role_id], [dashboard_id])
);
GO

IF OBJECT_ID(N'dbo.rel_role_display', N'U') IS NOT NULL DROP TABLE dbo.[rel_role_display];
CREATE TABLE dbo.[rel_role_display] (
    [role_id]     BIGINT NOT NULL,
    [display_id]  BIGINT NOT NULL,
    [visible]     TINYINT NOT NULL DEFAULT 0,
    [create_by]   BIGINT          DEFAULT NULL,
    [create_time] DATETIME2            DEFAULT NULL,
    [update_by]   BIGINT          DEFAULT NULL,
    [update_time] DATETIME2            DEFAULT NULL,
    PRIMARY KEY ([role_id], [display_id])
);
GO

IF OBJECT_ID(N'dbo.rel_role_portal', N'U') IS NOT NULL DROP TABLE dbo.[rel_role_portal];
CREATE TABLE dbo.[rel_role_portal] (
    [role_id]     BIGINT NOT NULL,
    [portal_id]   BIGINT NOT NULL,
    [visible]     TINYINT NOT NULL DEFAULT 0,
    [create_by]   BIGINT          DEFAULT NULL,
    [create_time] DATETIME2            DEFAULT NULL,
    [update_by]   BIGINT          DEFAULT NULL,
    [update_time] DATETIME2            DEFAULT NULL,
    PRIMARY KEY ([role_id], [portal_id])
);
GO

IF OBJECT_ID(N'dbo.rel_role_project', N'U') IS NOT NULL DROP TABLE dbo.[rel_role_project];
CREATE TABLE dbo.[rel_role_project] (
    [id]                  BIGINT  NOT NULL IDENTITY(1,1),
    [project_id]          BIGINT  NOT NULL,
    [role_id]             BIGINT  NOT NULL,
    [source_permission]   SMALLINT NOT NULL DEFAULT 1,
    [view_permission]     SMALLINT NOT NULL DEFAULT 1,
    [widget_permission]   SMALLINT NOT NULL DEFAULT 1,
    [viz_permission]      SMALLINT NOT NULL DEFAULT 1,
    [schedule_permission] SMALLINT NOT NULL DEFAULT 1,
    [share_permission]    TINYINT  NOT NULL DEFAULT 0,
    [download_permission] TINYINT  NOT NULL DEFAULT 0,
    [create_by]           BIGINT           DEFAULT NULL,
    [create_time]         DATETIME2             DEFAULT NULL,
    [update_by]           BIGINT           DEFAULT NULL,
    [update_time]         DATETIME2             DEFAULT NULL,
    PRIMARY KEY ([id]),
    CONSTRAINT [idx_role_project] UNIQUE ([project_id], [role_id])
);
GO

IF OBJECT_ID(N'dbo.rel_role_slide', N'U') IS NOT NULL DROP TABLE dbo.[rel_role_slide];
CREATE TABLE dbo.[rel_role_slide] (
    [role_id]     BIGINT NOT NULL,
    [slide_id]    BIGINT NOT NULL,
    [visible]     TINYINT NOT NULL DEFAULT 0,
    [create_by]   BIGINT          DEFAULT NULL,
    [create_time] DATETIME2            DEFAULT NULL,
    [update_by]   BIGINT          DEFAULT NULL,
    [update_time] DATETIME2            DEFAULT NULL,
    PRIMARY KEY ([role_id], [slide_id])
);
GO

IF OBJECT_ID(N'dbo.rel_role_user', N'U') IS NOT NULL DROP TABLE dbo.[rel_role_user];
CREATE TABLE dbo.[rel_role_user] (
    [id]          BIGINT NOT NULL IDENTITY(1,1),
    [user_id]     BIGINT NOT NULL,
    [role_id]     BIGINT NOT NULL,
    [create_by]   BIGINT DEFAULT NULL,
    [create_time] DATETIME2   DEFAULT NULL,
    [update_by]   BIGINT DEFAULT NULL,
    [update_time] DATETIME2   DEFAULT NULL,
    PRIMARY KEY ([id]),
    CONSTRAINT [idx_role_user] UNIQUE ([user_id], [role_id])
);
GO

IF OBJECT_ID(N'dbo.rel_role_view', N'U') IS NOT NULL DROP TABLE dbo.[rel_role_view];
CREATE TABLE dbo.[rel_role_view] (
    [view_id]     BIGINT NOT NULL,
    [role_id]     BIGINT NOT NULL,
    [row_auth]    NVARCHAR(MAX),
    [column_auth] NVARCHAR(MAX),
    [create_by]   BIGINT DEFAULT NULL,
    [create_time] DATETIME2   DEFAULT NULL,
    [update_by]   BIGINT DEFAULT NULL,
    [update_time] DATETIME2   DEFAULT NULL,
    PRIMARY KEY ([view_id], [role_id])
);
GO

IF OBJECT_ID(N'dbo.rel_user_organization', N'U') IS NOT NULL DROP TABLE dbo.[rel_user_organization];
CREATE TABLE dbo.[rel_user_organization] (
    [id]      BIGINT  NOT NULL IDENTITY(1,1),
    [org_id]  BIGINT  NOT NULL,
    [user_id] BIGINT  NOT NULL,
    [role]    SMALLINT NOT NULL DEFAULT 0,
    [create_by]   BIGINT   DEFAULT NULL,
    [create_time] DATETIME2     DEFAULT NULL,
    [update_by]   BIGINT   DEFAULT NULL,
    [update_time] DATETIME2     DEFAULT NULL,
    PRIMARY KEY ([id]),
    CONSTRAINT [idx_org_user] UNIQUE ([org_id], [user_id])
);
GO

IF OBJECT_ID(N'dbo.role', N'U') IS NOT NULL DROP TABLE dbo.[role];
CREATE TABLE dbo.[role] (
    [id]          BIGINT   NOT NULL IDENTITY(1,1),
    [org_id]      BIGINT   NOT NULL,
    [name]        NVARCHAR(100) NOT NULL,
    [description] NVARCHAR(255) DEFAULT NULL,
    [create_by]   BIGINT   DEFAULT NULL,
    [create_time] DATETIME2     DEFAULT NULL,
    [update_by]   BIGINT   DEFAULT NULL,
    [update_time] DATETIME2     DEFAULT NULL,
    [avatar]      NVARCHAR(255) DEFAULT NULL,
    PRIMARY KEY ([id])
);
GO

IF OBJECT_ID(N'dbo.source', N'U') IS NOT NULL DROP TABLE dbo.[source];
CREATE TABLE dbo.[source] (
    [id]             BIGINT   NOT NULL IDENTITY(1,1),
    [name]           NVARCHAR(255) NOT NULL,
    [description]    NVARCHAR(255) DEFAULT NULL,
    [config]         NVARCHAR(MAX)         NOT NULL,
    [type]           NVARCHAR(10)  NOT NULL,
    [project_id]     BIGINT   NOT NULL,
    [create_by]      BIGINT   DEFAULT NULL,
    [create_time]    DATETIME2     DEFAULT NULL,
    [update_by]      BIGINT   DEFAULT NULL,
    [update_time]    DATETIME2     DEFAULT NULL,
    [parent_id]      BIGINT   DEFAULT NULL,
    [full_parent_id] NVARCHAR(255) DEFAULT NULL,
    [is_folder]      TINYINT   DEFAULT NULL,
    [index]          INT       DEFAULT NULL,
    PRIMARY KEY ([id])
);
GO

IF OBJECT_ID(N'dbo.star', N'U') IS NOT NULL DROP TABLE dbo.[star];
CREATE TABLE dbo.[star] (
    [id]        BIGINT  NOT NULL IDENTITY(1,1),
    [target]    NVARCHAR(20) NOT NULL,
    [target_id] BIGINT  NOT NULL,
    [user_id]   BIGINT  NOT NULL,
    [star_time] DATETIME2    NOT NULL ,
    PRIMARY KEY ([id])
);
GO

IF OBJECT_ID(N'dbo.user', N'U') IS NOT NULL DROP TABLE dbo.[user];
CREATE TABLE dbo.[user] (
    [id]          BIGINT   NOT NULL IDENTITY(1,1),
    [email]       NVARCHAR(255) NOT NULL,
    [username]    NVARCHAR(255) NOT NULL,
    [password]    NVARCHAR(255) NOT NULL,
    [admin]       TINYINT   NOT NULL,
    [active]      TINYINT            DEFAULT NULL,
    [name]        NVARCHAR(255)          DEFAULT NULL,
    [description] NVARCHAR(255)          DEFAULT NULL,
    [department]  NVARCHAR(255)          DEFAULT NULL,
    [avatar]      NVARCHAR(255)          DEFAULT NULL,
    [create_time] DATETIME2    NOT NULL DEFAULT GETDATE(),
    [create_by]   BIGINT   NOT NULL DEFAULT 0,
    [update_time] DATETIME2    NULL,
    [update_by]   BIGINT            DEFAULT NULL,
    PRIMARY KEY ([id])
);
GO

IF OBJECT_ID(N'dbo.view', N'U') IS NOT NULL DROP TABLE dbo.[view];
CREATE TABLE dbo.[view] (
    [id]             BIGINT   NOT NULL IDENTITY(1,1),
    [name]           NVARCHAR(255) NOT NULL,
    [description]    NVARCHAR(255) DEFAULT NULL,
    [project_id]     BIGINT   NOT NULL,
    [source_id]      BIGINT   NOT NULL,
    [sql]            NVARCHAR(MAX),
    [model]          NVARCHAR(MAX),
    [variable]       NVARCHAR(MAX),
    [config]         NVARCHAR(MAX),
    [create_by]      BIGINT   DEFAULT NULL,
    [create_time]    DATETIME2     DEFAULT NULL,
    [update_by]      BIGINT   DEFAULT NULL,
    [update_time]    DATETIME2     DEFAULT NULL,
    [parent_id]      BIGINT   DEFAULT NULL,
    [full_parent_id] NVARCHAR(255) DEFAULT NULL,
    [is_folder]      TINYINT   DEFAULT NULL,
    [index]          INT       DEFAULT NULL,
    PRIMARY KEY ([id])
);
GO

IF OBJECT_ID(N'dbo.widget', N'U') IS NOT NULL DROP TABLE dbo.[widget];
CREATE TABLE dbo.[widget] (
    [id]             BIGINT   NOT NULL IDENTITY(1,1),
    [name]           NVARCHAR(255) NOT NULL,
    [description]    NVARCHAR(255) DEFAULT NULL,
    [view_id]        BIGINT   NOT NULL,
    [project_id]     BIGINT   NOT NULL,
    [type]           BIGINT   NOT NULL,
    [publish]        TINYINT   NOT NULL,
    [config]         NVARCHAR(MAX)     NOT NULL,
    [create_by]      BIGINT   DEFAULT NULL,
    [create_time]    DATETIME2     DEFAULT NULL,
    [update_by]      BIGINT   DEFAULT NULL,
    [update_time]    DATETIME2     DEFAULT NULL,
    [parent_id]      BIGINT   DEFAULT NULL,
    [full_parent_id] NVARCHAR(255) DEFAULT NULL,
    [is_folder]      TINYINT   DEFAULT NULL,
    [index]          INT       DEFAULT NULL,
    PRIMARY KEY ([id])
);
GO

IF OBJECT_ID(N'dbo.rel_role_display_slide_widget', N'U') IS NOT NULL DROP TABLE dbo.[rel_role_display_slide_widget];
CREATE TABLE dbo.[rel_role_display_slide_widget] (
    [role_id]                     BIGINT NOT NULL,
    [mem_display_slide_widget_id] BIGINT NOT NULL,
    [visible]                     TINYINT NOT NULL DEFAULT 0,
    [create_by]                   BIGINT          DEFAULT NULL,
    [create_time]                 DATETIME2            DEFAULT NULL,
    [update_by]                   BIGINT          DEFAULT NULL,
    [update_time]                 DATETIME2            DEFAULT NULL,
    PRIMARY KEY ([role_id], [mem_display_slide_widget_id])
);
GO

IF OBJECT_ID(N'dbo.rel_role_dashboard_widget', N'U') IS NOT NULL DROP TABLE dbo.[rel_role_dashboard_widget];
CREATE TABLE dbo.[rel_role_dashboard_widget] (
    [role_id]                 BIGINT NOT NULL,
    [mem_dashboard_widget_id] BIGINT NOT NULL,
    [visible]                 TINYINT NOT NULL DEFAULT 0,
    [create_by]               BIGINT          DEFAULT NULL,
    [create_time]             DATETIME2            DEFAULT NULL,
    [update_by]               BIGINT          DEFAULT NULL,
    [update_time]             DATETIME2            DEFAULT NULL,
    PRIMARY KEY ([role_id], [mem_dashboard_widget_id])
);
GO

IF OBJECT_ID(N'dbo.davinci_statistic_visitor_operation', N'U') IS NOT NULL DROP TABLE dbo.[davinci_statistic_visitor_operation];
CREATE TABLE dbo.[davinci_statistic_visitor_operation] (
  [id] BIGINT NOT NULL IDENTITY(1,1),
  [user_id] BIGINT DEFAULT NULL,
  [email] NVARCHAR(255) DEFAULT NULL,
  [action] NVARCHAR(255) DEFAULT NULL,
  [org_id] BIGINT DEFAULT NULL,
  [project_id] BIGINT DEFAULT NULL,
  [project_name] NVARCHAR(255) DEFAULT NULL,
  [viz_type] NVARCHAR(255) DEFAULT NULL,
  [viz_id] BIGINT DEFAULT NULL,
  [viz_name] NVARCHAR(255) DEFAULT NULL,
  [sub_viz_id] BIGINT DEFAULT NULL,
  [sub_viz_name] NVARCHAR(255) DEFAULT NULL,
  [widget_id] BIGINT DEFAULT NULL,
  [widget_name] NVARCHAR(255) DEFAULT NULL,
  [variables] NVARCHAR(500) DEFAULT NULL,
  [filters] NVARCHAR(500) DEFAULT NULL,
  [groups] NVARCHAR(500) DEFAULT NULL,
  [create_time] DATETIME2 NULL DEFAULT NULL,
  PRIMARY KEY ([id])
);
GO

IF OBJECT_ID(N'dbo.davinci_statistic_terminal', N'U') IS NOT NULL DROP TABLE dbo.[davinci_statistic_terminal];
CREATE TABLE dbo.[davinci_statistic_terminal] (
  [id] BIGINT NOT NULL IDENTITY(1,1),
  [user_id] BIGINT DEFAULT NULL,
  [email] NVARCHAR(255) DEFAULT NULL,
  [browser_name] NVARCHAR(255) DEFAULT NULL,
  [browser_version] NVARCHAR(255) DEFAULT NULL,
  [engine_name] NVARCHAR(255) DEFAULT NULL,
  [engine_version] NVARCHAR(255) DEFAULT NULL,
  [os_name] NVARCHAR(255) DEFAULT NULL,
  [os_version] NVARCHAR(255) DEFAULT NULL,
  [device_model] NVARCHAR(255) DEFAULT NULL,
  [device_type] NVARCHAR(255) DEFAULT NULL,
  [device_vendor] NVARCHAR(255) DEFAULT NULL,
  [cpu_architecture] NVARCHAR(255) DEFAULT NULL,
  [create_time] DATETIME2 NULL DEFAULT NULL,
  PRIMARY KEY ([id])
);
GO

IF OBJECT_ID(N'dbo.davinci_statistic_duration', N'U') IS NOT NULL DROP TABLE dbo.[davinci_statistic_duration];
CREATE TABLE dbo.[davinci_statistic_duration] (
    [id]         BIGINT NOT NULL IDENTITY(1,1),
    [user_id]    BIGINT      DEFAULT NULL,
    [email]      NVARCHAR(255)    DEFAULT NULL,
    [org_id] BIGINT DEFAULT NULL,
    [project_id] BIGINT DEFAULT NULL,
    [project_name] NVARCHAR(255) DEFAULT NULL,
    [viz_type] NVARCHAR(10) DEFAULT NULL,
    [viz_id] BIGINT DEFAULT NULL,
    [viz_name] NVARCHAR(255) DEFAULT NULL,
    [sub_viz_id] BIGINT DEFAULT NULL,
    [sub_viz_name] NVARCHAR(255) DEFAULT NULL,
    [start_time] DATETIME2  NULL DEFAULT NULL,
    [end_time]   DATETIME2  NULL DEFAULT NULL,
    PRIMARY KEY ([id])
);
GO

IF OBJECT_ID(N'dbo.share_download_record', N'U') IS NOT NULL DROP TABLE dbo.[share_download_record];
CREATE TABLE dbo.[share_download_record] (
  [id] BIGINT NOT NULL IDENTITY(1,1),
  [uuid] NVARCHAR(50) DEFAULT NULL,
  [name] NVARCHAR(255) NOT NULL,
  [path] NVARCHAR(255) DEFAULT NULL,
  [status] SMALLINT NOT NULL,
  [create_time] DATETIME2 NOT NULL,
  [last_download_time] DATETIME2 DEFAULT NULL,
  PRIMARY KEY ([id])
);


SET FOREIGN_KEY_CHECKS = 1;


INSERT INTO [user] ([id], [email], [username], [password], [admin], [active], [name], [description], [department], [avatar], [create_time], [create_by], [update_by], [update_time])
VALUES (1, 'guest@davinci.cn', 'guest', '$2a$10$RJKb4jhMgRYnGPlVRV036erxQ3oGZ8NnxZrlrrBJJha9376cAuTRO', 1, 1, NULL, NULL, NULL, NULL, '2020-01-01 00:00:00', 0, NULL, NULL);

INSERT INTO [organization] ([id], [name], [description], [avatar], [user_id], [project_num], [member_num], [role_num], [allow_create_project], [member_permission], [create_time], [create_by], [update_time], [update_by])
VALUES (1, 'guest\'s Organization', NULL, NULL, 1, 0, 1, 0, 1, 1, '2020-01-01 00:00:00', 1, NULL, NULL);

INSERT INTO [rel_user_organization] ([id], [org_id], [user_id], [role], [create_by], [create_time], [update_by], [update_time])
VALUES (1, 1, 1, 1, 1, '2020-01-01 00:00:00', NULL, NULL);
GO

INSERT INTO dbo.[user] ([id], [email], [username], [password], [admin], [active], [name], [description], [department], [avatar], [create_time], [create_by], [update_by], [update_time])
VALUES (1, 'guest@davinci.cn', 'guest', '$2a$10$RJKb4jhMgRYnGPlVRV036erxQ3oGZ8NnxZrlrrBJJha9376cAuTRO', 1, 1, NULL, NULL, NULL, NULL, '2020-01-01 00:00:00', 0, NULL, NULL);

INSERT INTO dbo.[organization] ([id], [name], [description], [avatar], [user_id], [project_num], [member_num], [role_num], [allow_create_project], [member_permission], [create_time], [create_by], [update_time], [update_by])
VALUES (1, 'guest\'s Organization', NULL, NULL, 1, 0, 1, 0, 1, 1, '2020-01-01 00:00:00', 1, NULL, NULL);

INSERT INTO dbo.[rel_user_organization] ([id], [org_id], [user_id], [role], [create_by], [create_time], [update_by], [update_time])
VALUES (1, 1, 1, 1, 1, '2020-01-01 00:00:00', NULL, NULL);
GO