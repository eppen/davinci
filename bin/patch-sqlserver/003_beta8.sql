ALTER TABLE dbo.[dbo].[cron_job]
ALTER COLUMN [create_time] DATETIME2 NOT NULL DEFAULT GETDATE() AFTER [create_by];


ALTER TABLE dbo.[dbo].[organization]
ALTER COLUMN [create_time] DATETIME2 NOT NULL DEFAULT GETDATE() AFTER [member_permission];


ALTER TABLE dbo.[dbo].[user]
ALTER COLUMN [create_time] DATETIME2 NOT NULL DEFAULT GETDATE() AFTER [avatar];