-- =============================================
-- Author:      Sergei Boikov
-- Create Date: 2023-04-14
-- Description: Load information for user_type from JSON
-- Example:     CALL lab.usp_user_type_insert('[{"user_type_name":"mentor", "user_type_description":"Mentor"}]');
-- =============================================

CREATE OR REPLACE PROCEDURE lab.usp_user_type_insert(jsn JSON)
LANGUAGE plpgsql
AS $$
BEGIN
    DROP TABLE IF EXISTS temp_source;
    CREATE TEMPORARY TABLE temp_source (
        user_type_name          VARCHAR(250),
        user_type_description   VARCHAR(250)
    ) ON COMMIT DROP;

    INSERT INTO temp_source(user_type_name, user_type_description)
    SELECT 
        user_type_name, 
        user_type_description
    FROM json_to_recordset(jsn) AS j(user_type_name VARCHAR(250), user_type_description VARCHAR(250));
   
    MERGE INTO lab.user_type AS tgt
    USING (
        SELECT DISTINCT 
            tmp.user_type_name,
            tmp.user_type_description
        FROM temp_source AS tmp
    ) src 
        ON (TRIM(UPPER(src.user_type_name)) = TRIM(UPPER(tgt."name")))
    WHEN MATCHED THEN
        UPDATE SET
            description     = src.user_type_description,
            sys_changed_at  = CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE
    WHEN NOT MATCHED THEN
        INSERT (
            user_type_id,
            name,
            description
        ) 
        VALUES (
            nextval('lab.sq_dbo_user_type_user_type_id'),
            src.user_type_name,
            src.user_type_description
        );
END; $$
