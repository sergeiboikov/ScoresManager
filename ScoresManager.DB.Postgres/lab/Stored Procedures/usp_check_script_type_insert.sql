-- =============================================
-- Author:      Sergei Boikov
-- Create Date: 2023-04-08
-- Description: Load information for check_script_type from JSON
-- Format JSON: '["SQL", "MDX"]'
-- Example:     CALL lab.usp_check_script_type_insert('["SQL", "MDX"]');
-- =============================================
CREATE OR REPLACE PROCEDURE lab.usp_check_script_type_insert(jsn JSON)
LANGUAGE plpgsql
AS $$
BEGIN
    DROP TABLE IF EXISTS temp_source;
    CREATE TEMPORARY TABLE temp_source (
        check_script_type_name VARCHAR(250)
    ) ON COMMIT DROP;
    
    INSERT INTO temp_source(check_script_type_name)
    SELECT value AS check_script_type_name
    FROM json_array_elements_text(jsn) AS j;
    
    -- check_script_type insert
    MERGE INTO lab.check_script_type tgt
    USING (
        SELECT tmp.check_script_type_name
        FROM temp_source tmp
    ) src 
        ON (TRIM(UPPER(src.check_script_type_name)) = TRIM(UPPER(tgt."name")))
    WHEN NOT MATCHED THEN
    INSERT (
        check_script_type_id,       
        "name"
    ) 
    VALUES (
        nextval('lab.sq_dbo_check_script_type_check_script_type_id'),       
        src.check_script_type_name
    );
END; $$
