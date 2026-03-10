
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET NOCOUNT ON;

DECLARE @msg VARCHAR(255) = CONCAT(CHAR(47),REPLICATE('*',50),CHAR(10));
SET @msg = CONCAT(@msg, 'SERVERNAME: ', @@SERVERNAME, CHAR(10));
SET @msg = CONCAT(@msg, 'DB_NAME: ', REPLICATE(CHAR(32),3), DB_NAME(),CHAR(10));
SET @msg = CONCAT(@msg, 'USERNAME: ', REPLICATE(CHAR(32),2), SYSTEM_USER,CHAR(10));
SET @msg = CONCAT(@msg, 'START TIME: ', SYSDATETIME(), CHAR(10),REPLICATE('*',50),CHAR(47),CHAR(10))
PRINT(@msg);

SET NOCOUNT OFF;

PRINT 'BEGINNING TRANSACTION'; BEGIN TRANSACTION;

DECLARE @endDate DATE = DATEADD(YEAR,1,GETDATE());

WITH recursiveDateExample AS
	(
		SELECT
			TRY_CAST(GETDATE() AS DATE) AS targetDate

		UNION ALL

		SELECT
			DATEADD(MONTH, 1, recursiveDateExample.targetDate)
		FROM
			recursiveDateExample
		WHERE
			recursiveDateExample.targetDate < @endDate

	)
SELECT
	*
FROM
	recursiveDateExample;


DECLARE @stop INT = 100;

WITH recursiveNumberPool AS
    (
        SELECT
            1 AS number

        UNION ALL

        SELECT
            recursiveNumberPool.number + 1
        FROM
            recursiveNumberPool
        WHERE
            recursiveNumberPool.number < @stop
    )
SELECT
    *
FROM
    recursiveNumberPool;

PRINT CONCAT(CHAR(10), 'TRANSACTION IN ROLLBACK'); ROLLBACK TRANSACTION;

--PRINT CONCAT(CHAR(10), 'TRANSACTION COMMITTED'); COMMIT TRANSACTION;