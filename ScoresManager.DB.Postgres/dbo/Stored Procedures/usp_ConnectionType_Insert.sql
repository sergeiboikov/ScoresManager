-- =============================================
-- Author:            Elyana Pogosyan
-- Create Date:        2021-10-26
-- Description: Load information for CheckScriptType from JSON
-- Format JSON: N'{"ConnectionTypeName":"ODBC", "ConnectionTypeDescription":"Open Database Connectivity"}' 
--  Example: EXEC dbo.usp_ConnectionType_Insert jsn = N'{"ConnectionTypeName":"ODBC", "ConnectionTypeDescription":"Open Database Connectivity"}'  -- =============================================

CREATE OR REPLACE PROCEDURE dbo.usp_ConnectionType_Insert(jsn JSON)
LANGUAGE plpgsql
AS $$
BEGIN

    BEGIN
        BEGIN
            BEGIN
                CREATE TEMPORARY TABLE TEMP_SOURCE (
        --TODO: FILL
    ) ON COMMIT DROP;
                SELECT *
                INTO TEMP_SOURCE
                FROM OPENJSON(jsn)
                WITH (
                         ConnectionTypeName             VARCHAR(250)     '$.ConnectionTypeName'
                        ,ConnectionTypeDescription     VARCHAR(250)     '$.ConnectionTypeDescription'
               ) AS RootL;                -- ConnectionType insert                MERGE INTO dbo.ConnectionType tgt
                USING (
                        SELECT DISTINCT  tmp.ConnectionTypeName
                                        ,tmp.ConnectionTypeDescription
                        FROM TEMP_SOURCE AS tmp
                    ) src ON (TRIM(UPPER(src.ConnectionTypeName)) = TRIM(UPPER(tgt.Name)))
                WHEN MATCHED THEN
                UPDATE SET
                     tgt.Description    = src.ConnectionTypeDescription
                    ,tgt.sysChangedAt    = CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE
                WHEN NOT MATCHED THEN
                INSERT (
                     Name
                    ,Description
                ) VALUES
                (
                     src.ConnectionTypeName
                    ,src.ConnectionTypeDescription
                );
                
            COMMIT;
        EXCEPTION WHEN OTHERS
        THEN ROLLBACK;
    END
END