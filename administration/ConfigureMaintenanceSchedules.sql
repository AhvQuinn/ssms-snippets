
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET XACT_ABORT ON;

USE msdb;

DECLARE @msg VARCHAR(255) = CONCAT(CHAR(47),REPLICATE('*',50),CHAR(10));
SET @msg = CONCAT(@msg, 'SERVERNAME: ', @@SERVERNAME, CHAR(10));
SET @msg = CONCAT(@msg, 'DB_NAME: ', REPLICATE(CHAR(32),3), DB_NAME(),CHAR(10));
SET @msg = CONCAT(@msg, 'USERNAME: ', REPLICATE(CHAR(32),2), SYSTEM_USER,CHAR(10));
SET @msg = CONCAT(@msg, 'START TIME: ', SYSDATETIME(), CHAR(10),REPLICATE('*',50),CHAR(47),CHAR(10))
PRINT(@msg);

PRINT 'BEGINNING TRANSACTION'; BEGIN TRANSACTION;

IF NOT EXISTS
	(
		SELECT
			NULL
		FROM
			dbo.sysschedules
		WHERE
			sysschedules.name = N'NightlyMaintenanceCycle-00:00'
	)
EXEC dbo.sp_add_schedule
		@schedule_name = N'NightlyMaintenanceCycle-00:00',
		@freq_type = 4 /*Daily*/,
		@freq_interval = 1 /*Every 1 day*/,
		@active_start_time = 000000 /*12:00:00 AM, don't forget to adjust for UTC Time Offsets*/;
GO
IF @@TRANCOUNT = 0
BEGIN;
	RAISERROR('This maintenance cycle already exists.', 16, 1) WITH NOWAIT;
	THROW 50000, 'This maintenance cycle already exists. Investigate existing settings.', 1;
END;
GO
IF NOT EXISTS
	(
		SELECT
			NULL
		FROM
			dbo.sysschedules
		WHERE
			sysschedules.name = N'NightlyMaintenanceCycle-02:00'
	)
EXEC dbo.sp_add_schedule
		@schedule_name = N'NightlyMaintenanceCycle-02:00',
		@freq_type = 4 /*Daily*/,
		@freq_interval = 1 /*Every 1 day*/,
		@active_start_time = 020000 /*02:00:00 AM, don't forget to adjust for UTC Time Offsets*/;
GO
IF @@TRANCOUNT = 0
BEGIN;
	RAISERROR('This maintenance cycle already exists.', 16, 1) WITH NOWAIT;
	THROW 50000, 'This maintenance cycle already exists. Investigate existing settings.', 1;
END;
GO
IF NOT EXISTS
	(
		SELECT
			NULL
		FROM
			dbo.sysschedules
		WHERE
			sysschedules.name = N'NightlyMaintenanceCycle-04:00'
	)
EXEC dbo.sp_add_schedule
		@schedule_name = N'NightlyMaintenanceCycle-04:00',
		@freq_type = 4 /*Daily*/,
		@freq_interval = 1 /*Every 1 day*/,
		@active_start_time = 040000 /*04:00:00 AM, don't forget to adjust for UTC Time Offsets*/;
GO
IF @@TRANCOUNT = 0
BEGIN;
	RAISERROR('This maintenance cycle already exists.', 16, 1) WITH NOWAIT;
	THROW 50000, 'This maintenance cycle already exists. Investigate existing settings.', 1;
END;
GO
IF NOT EXISTS
	(
		SELECT
			NULL
		FROM
			dbo.sysschedules
		WHERE
			sysschedules.name = N'WeeklyMaintenanceCycle-Saturday'
	)
EXEC dbo.sp_add_schedule
		@schedule_name = N'WeeklyMaintenanceCycle-Saturday',
		@freq_type = 8 /*Weekly*/,
		@freq_recurrence_factor = 1 /*Every 1 week*/,
		@freq_interval = 64 /*Saturday*/,
		@active_start_time = 223000 /*10:30:00 PM, don't forget to adjust for UTC Time Offsets*/;

GO
IF @@TRANCOUNT = 0
BEGIN;
	RAISERROR('This maintenance cycle already exists.', 16, 1) WITH NOWAIT;
	THROW 50000, 'This maintenance cycle already exists. Investigate existing settings.', 1;
END;
GO
IF NOT EXISTS
	(
		SELECT
			NULL
		FROM
			dbo.sysschedules
		WHERE
			sysschedules.name = N'MonthlyMaintenanceCycle-MonthEnd'
	)
EXEC dbo.sp_add_schedule
		@schedule_name = N'MonthlyMaintenanceCycle-MonthEnd',
		@freq_type = 16 /*Monthly relative*/,
		@freq_recurrence_factor = 1 /*Every 1 month*/,
		@freq_interval = 10 /*Last weekend of the Month*/,
		@active_start_time = 223000 /*10:30:00 PM, don't forget to adjust for UTC Time Offsets*/;
GO
IF @@TRANCOUNT = 0
BEGIN;
	RAISERROR('This maintenance cycle already exists.', 16, 1) WITH NOWAIT;
	THROW 50000, 'This maintenance cycle already exists. Investigate existing settings.', 1;
END;
GO

PRINT CONCAT(CHAR(10), 'TRANSACTION IN ROLLBACK'); ROLLBACK TRANSACTION;
--PRINT CONCAT(CHAR(10), 'TRANSACTION COMMITTED'); COMMIT TRANSACTION;