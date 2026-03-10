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

DECLARE @maxIteration INT = 93;

IF (@maxIteration > 93)
BEGIN;
	PRINT CONCAT(CHAR(10), 'TRANSACTION ROLLED BACK'); ROLLBACK TRANSACTION;
	THROW 51727, 'Cannot select a number greater than 93 due to an arithmetic overflow.', 1;
END;

WITH fibbonacciRoot AS
	(
		SELECT
			0 AS number,
			0 as previous,
			0 AS iteration

		UNION ALL
		
		SELECT
			1,
			0,
			1 AS iteration

		UNION ALL

		SELECT
			1,
			1 AS previous,
			2 AS iteration
	),
	recursiveFibbonacci AS
	(

		SELECT
			TRY_CAST(fibbonacciRoot.number AS BIGINT) AS number,
			TRY_CAST(fibbonacciRoot.previous AS BIGINT) AS previous,
			fibbonacciRoot.iteration
		FROM
			fibbonacciRoot

		UNION ALL

		SELECT
			(recursiveFibbonacci.number + recursiveFibbonacci.previous) AS number,
			(recursiveFibbonacci.number) AS previous,
			(recursiveFibbonacci.iteration + 1) AS iteration
		FROM
			recursiveFibbonacci
		WHERE
			recursiveFibbonacci.iteration <= (@maxIteration-2)
			AND recursiveFibbonacci.iteration > 1
	)
SELECT
	CONCAT('Fibbonacci sequence element {',recursiveFibbonacci.iteration,'}') AS [Output Description],
	recursiveFibbonacci.number
FROM
	recursiveFibbonacci
WHERE
	1=1
ORDER BY
	recursiveFibbonacci.iteration;

PRINT CONCAT(CHAR(10), 'TRANSACTION IN ROLLBACK'); ROLLBACK TRANSACTION;
--PRINT CONCAT(CHAR(10), 'TRANSACTION COMMITTED'); COMMIT TRANSACTION;