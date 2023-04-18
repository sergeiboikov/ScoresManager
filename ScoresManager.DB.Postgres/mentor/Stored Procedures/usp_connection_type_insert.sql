-- =============================================
-- Author:      Sergei Boikov
-- Create Date: 2023-04-14
-- Description: Load information for check_script_type from JSON
-- Example:     CALL mentor.usp_connection_type_insert('[{"connection_type_name":"ODBC", "connection_type_description":"Open Database Connectivity"}]');
-- =============================================

CREATE OR REPLACE PROCEDURE mentor.usp_connection_type_insert(jsn JSON)
LANGUAGE plpgsql
AS $$
BEGIN
    DROP TABLE IF EXISTS temp_source;
    CREATE TEMPORARY TABLE temp_source (
        connection_type_name          VARCHAR(250),
        connection_type_description   VARCHAR(250)
    ) ON COMMIT DROP;

    INSERT INTO temp_source(connection_type_name, connection_type_description)
    SELECT 
        connection_type_name, 
        connection_type_description
    FROM json_to_recordset(jsn) AS j(connection_type_name VARCHAR(250), connection_type_description VARCHAR(250));
   
    MERGE INTO lab.connection_type AS tgt
    USING (
        SELECT DISTINCT 
            tmp.connection_type_name,
            tmp.connection_type_description
        FROM temp_source AS tmp
    ) src 
        ON (TRIM(UPPER(src.connection_type_name)) = TRIM(UPPER(tgt."name")))
    WHEN MATCHED THEN
        UPDATE SET
            description     = src.connection_type_description,
            sys_changed_at  = CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE
    WHEN NOT MATCHED THEN
        INSERT (
            connection_type_id,
            name,
            description
        ) 
        VALUES (
            nextval('lab.sq_dbo_connection_type_connection_type_id'),
            src.connection_type_name,
            src.connection_type_description
        );
END; $$
