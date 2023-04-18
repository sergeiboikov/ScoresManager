-- =============================================
-- Author:      Sergei Boikov
-- Create Date: 2023-04-16
-- Description: Load information about course_staff from JSON
-- Example:     CALL lab.usp_course_staff_insert('[{"username": "Sergei Boikov", "course_name": "BI.RD.LAB.2023.1", "user_email": "Sergei_Boikov@rntgroup.com", "user_type": "mentor"}, {"username": "Anna Sedina", "course_name": "BI.RD.LAB.2023.1", "user_email": "Anna_Sedina@rntgroup.com", "user_type": "student"}]');
-- =============================================
CREATE OR REPLACE PROCEDURE lab.usp_course_staff_insert(jsn JSON)
LANGUAGE plpgsql
AS $$
DECLARE no_matched_course_name_from_json    VARCHAR(250) := '';
        no_matched_user_type_from_json      VARCHAR(100) := '';
BEGIN
/*========================================================================================================================
 * Insert temp data from JSON
========================================================================================================================*/
    CREATE TEMPORARY TABLE temp_source (
        username        VARCHAR(100),
        course_name     VARCHAR(250),
        user_email      VARCHAR(100),
        user_type       VARCHAR(100)
    ) ON COMMIT DROP;

    INSERT INTO temp_source(username, course_name, user_email, user_type)
    SELECT 
        username, 
        course_name,
        user_email, 
        user_type
    FROM json_to_recordset(jsn) AS j(
        username VARCHAR(100), 
        course_name VARCHAR(250), 
        user_email VARCHAR(100),    
        user_type VARCHAR(100)
    );

/*========================================================================================================================
 * Check course names
========================================================================================================================*/
    SELECT tmp.course_name
    INTO no_matched_course_name_from_json
    FROM temp_source AS tmp
    LEFT JOIN lab.course AS c ON TRIM(UPPER(c."name")) = TRIM(UPPER(tmp.course_name))
    WHERE tmp.course_name IS NOT NULL
        AND c.course_id IS NULL
    LIMIT 1;

    IF (no_matched_course_name_from_json IS NOT NULL)
    THEN
        RAISE EXCEPTION 'Course: ''%'' isn''t found', no_matched_course_name_from_json;
    END IF;

/*========================================================================================================================
 * Check user type
========================================================================================================================*/
    SELECT tmp.user_type
    INTO no_matched_user_type_from_json
    FROM temp_source AS tmp
    LEFT JOIN lab.user_type AS ut ON TRIM(UPPER(ut."name")) = TRIM(UPPER(tmp.user_type))
    WHERE tmp.user_type IS NOT NULL
        AND ut.user_type_id IS NULL
    LIMIT 1;

    IF (no_matched_user_type_from_json IS NOT NULL)
    THEN
        RAISE EXCEPTION 'User type:: ''%'' isn''t found', no_matched_user_type_from_json;
    END IF;

/*========================================================================================================================
 * Merge data to target tables
========================================================================================================================*/
    --Merge user
    MERGE INTO lab."user" AS tgt
    USING (
        SELECT DISTINCT 
            tmp.username,
            tmp.user_email
        FROM temp_source AS tmp
    ) src 
        ON (TRIM(UPPER(src.user_email)) = TRIM(UPPER(tgt.email)))
    WHEN MATCHED THEN
        UPDATE SET
            "name" = src.username,
            sys_changed_at = CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE
    WHEN NOT MATCHED THEN
        INSERT (
            user_id,
            "name",
            email
        ) 
        VALUES (
            nextval('lab.sq_dbo_user_user_id'),
            src.username,
            src.user_email
        );
    
    -- Merge course_staff
    MERGE INTO lab.course_staff tgt
    USING (
        SELECT DISTINCT 
             u.user_id
            ,c.course_id
            ,ut.user_type_id
        FROM temp_source AS tmp
        INNER JOIN lab."user" AS u 
            ON TRIM(UPPER(u.email)) = TRIM(UPPER(tmp.user_email))
        INNER JOIN lab.course AS c 
            ON TRIM(UPPER(c."name")) = TRIM(UPPER(tmp.course_name))
        INNER JOIN lab.user_type AS ut 
            ON TRIM(UPPER(ut."name")) = TRIM(UPPER(tmp.user_type))
    ) src ON (src.user_id = tgt.user_id 
            AND src.course_id = tgt.course_id)
    WHEN MATCHED THEN
        UPDATE SET
            user_type_id = src.user_type_id,
            sys_changed_at = CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE
    WHEN NOT MATCHED THEN
    INSERT (
        course_staff_id,
        user_id,
        course_id,
        user_type_id
    ) VALUES
    (
        nextval('lab.sq_dbo_course_staff_course_staff_id'),
        src.user_id,
        src.course_id,
        src.user_type_id
    );
END; $$
