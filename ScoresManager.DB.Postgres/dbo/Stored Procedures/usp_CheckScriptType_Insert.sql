-- =============================================
-- Author:      Sergei Boikov
-- Create Date: 2023-04-08
-- Description: Load information for CheckScriptType from JSON
-- Format JSON: '["SQL", "MDX"]'
-- Example: 	CALL dbo.usp_CheckScriptType_Insert('["SQL", "MDX"]');
-- =============================================
CREATE OR REPLACE PROCEDURE dbo.usp_CheckScriptType_Insert(jsn JSON)
LANGUAGE plpgsql
AS $$
BEGIN
    DROP TABLE IF EXISTS TEMP_SOURCE;
    CREATE TEMPORARY TABLE TEMP_SOURCE (
        CheckScriptTypeName VARCHAR(250)
    ) ON COMMIT DROP;
    
    INSERT INTO TEMP_SOURCE(CheckScriptTypeName)
    SELECT value AS CheckScriptTypeName
    FROM json_array_elements_text(jsn) AS j;
    
	-- CheckScriptType insert
    MERGE INTO dbo.CheckScriptType tgt
    USING (
        SELECT tmp.CheckScriptTypeName
        FROM TEMP_SOURCE tmp
    ) src 
        ON (TRIM(UPPER(src.CheckScriptTypeName)) = TRIM(UPPER(tgt.Name)))
    WHEN NOT MATCHED THEN
    INSERT (
        CheckScriptTypeId,	   
        Name
    ) VALUES
    (
        nextval('dbo.sq_dbo_CheckScriptType_CheckScriptTypeId'),	   
        src.CheckScriptTypeName
    );
END; $$
