
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
GO
EXEC dbo.sp_add_job @job_name = N'DatabaseNightlyBackup';
GO
DECLARE @database NVARCHAR(255) = 'QDB';
DECLARE @backupPath NVARCHAR(255) = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup\QDB.bak';
DECLARE @command NVARCHAR(MAX) = CONCAT('BACKUP DATABASE ', @database, ' TO DISK = ', @backupPath, ';');

EXEC dbo.sp_add_jobstep
	@job_name = N'DatabaseNightlyBackup',
	@step_name = N'Backup',
	@subsystem = N'TSQL',
	@database_name = @database,
	@command = @command,
	@retry_attempts = 2,
	@retry_interval = 5 /*Measured in Minutes*/,
	@on_success_action = 1 /*Quit with success*/,
	@on_fail_action = 2 /*Quit with report, change later in query to send a failure alert*/;
GO
EXEC dbo.sp_attach_schedule
	@job_name = N'DatabaseNightlyBackup',
	@schedule_name = N'NightlyMaintenanceCycle-00:00';
GO
EXEC dbo.sp_add_jobserver
	@job_name = N'DatabaseNightlyBackup',
	@server_name = @@servername;
GO
EXEC dbo.sp_add_alert
	@name = N'DatabaseNightlyBackupFailure',
	@message_id = 0,
	@severity = 0,
	@enabled = 1,
	@delay_between_responses = 0,
	@include_event_description_in = 1,
	@notification_message = N'Nightly Backup Job Failed. Check Job History for details.',
	@job_name = N'DatabaseNightlyBackup';
GO
PRINT CONCAT(CHAR(10), 'TRANSACTION IN ROLLBACK'); ROLLBACK TRANSACTION;
--PRINT CONCAT(CHAR(10), 'TRANSACTION COMMITTED'); COMMIT TRANSACTION;