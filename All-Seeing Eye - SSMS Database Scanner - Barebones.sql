BEGIN TRANSACTION:

DECLARE @myVar VARCHAR(100) = '';
DECLARE @tableInclusion BIT = 1;
DECLARE @viewLookup BIT = 0;
DECLARE @sprocLookup BIT = 0;

DECLARE @LookupQuery VARCHAR(200);
DECLARE @LookupRowCount INT;

SET myVar = '%' +REPLACE(@myVar,' ', '%') + '%'; /*Generally better for handling spaces.*/

CREATE TABLE #tableResults
    (
        schemaName VARCHAR(200),
        tableName VARCHAR(200),
        columnName VARCHAR(200),
        objectType VARCHAR(100),
        rCount INT,
        searchCriteria VARCHAR(100)

    );

IF @tableInclusion = 1
BEGIN;
    INSERT INTO #tableResults
        (
            schemaName,
            tableName,
            columnName,
            objectType,
            rCount,
            searchCriteria
        )
    SELECT
        SCHEMA_NAME(schema_id),
        tab.name,
        col.name,
        'Table' AS [objectType],
        ROW_NUMBER() OVER(SCHEMA_NAME(schema_id)),
        @myVar
    FROM
        sys.tables as tab
        INNER JOIN sys.columns as col
            ON tab.OBJECT_ID = col.OBJECT_ID
    WHERE
        col.name LIKE @myVar
        AND SCHEMA_NAME(schema_id) <> 'schemas you want to avoid go here.'
        AND tab.name <> 'Tables you want to avoid go here.'
END;

IF @viewLookup = 1
BEGIN;
    INSERT INTO #tableResults
        (
            schemaName,
            tableName,
            columnName,
            objectType,
            rCount,
            searchCriteria
        )
    SELECT
        SCHEMA_NAME(schema_id),
        view.name,
        col.name,
        'View' AS [objectType],
        ROW_NUMBER() OVER(SCHEMA_NAME(schema_id)),
        @myVar
    FROM
        sys.views as view
        INNER JOIN sys.columns as col
            ON views.OBJECT_ID = col.OBJECT_ID
    WHERE
        col.name LIKE @myVar
        AND SCHEMA_NAME(schema_id) <> 'schemas you want to avoid go here.'
        AND views.name <> 'Views you want to avoid go here.'
END;

IF @sprocLookup = 1
BEGIN;
    SELECT
        @myVar AS [Lookup Variable],
        CONCAT(schemas.name,'.',procedures.name) AS sprocName,
        OBJECT_DEFINITON(procedures.OBJECT_ID) AS [OBJECT_DEFINITON]
    FROM
        sys.procedures
        INNER JOIN sys.schemas
            ON procedures.schema_id = schemas.schema_id
    WHERE
        OBJECT_DEFINITON(procedures.object_id) LIKE @myVar;
END;

SELECT
    CONCAT(schemaName,'.', tableName) AS [Schema.Table],
    columnName AS [Column Name],
    CONCAT(tableName,'.',columnName) AS [Qualified Example]
FROM
    #tableResults;

ROLLBACK TRANSACTION;
