-- =============================================
-- Author:      Sergei Boikov
-- Create Date: 2023-04-16
-- Description: Load information for course from JSON
-- Example:     CALL mentor.usp_course_insert('[{"course_name":"BI.RD.LAB.2023.1", "course_datestart":"2023-04-24", "course_datefinish": "2023-08-31"}]');
-- =============================================

CREATE OR REPLACE PROCEDURE mentor.usp_course_insert(jsn JSON)
LANGUAGE plpgsql
AS $$
BEGIN
/*========================================================================================================================
 * Insert temp data from JSON
========================================================================================================================*/
    DROP TABLE IF EXISTS temp_source;
    CREATE TEMPORARY TABLE temp_source (
        course_name         VARCHAR(250),
        course_datestart    DATE,
        course_datefinish   DATE
    ) ON COMMIT DROP;

    INSERT INTO temp_source(course_name, course_datestart, course_datefinish)
    SELECT 
        course_name, 
        course_datestart, 
        course_datefinish
    FROM json_to_recordset(jsn) AS j(course_name VARCHAR(250), course_datestart DATE, course_datefinish DATE);

/*========================================================================================================================
 * Merge data to target table
========================================================================================================================*/
    MERGE INTO lab.course AS tgt
    USING (
        SELECT DISTINCT 
            tmp.course_name,
            tmp.course_datestart, 
            tmp.course_datefinish
        FROM temp_source AS tmp
    ) src 
        ON (TRIM(UPPER(src.course_name)) = TRIM(UPPER(tgt."name")))
    WHEN MATCHED THEN
        UPDATE SET
            datestart       = src.course_datestart,
            datefinish      = src.course_datefinish,
            sys_changed_at  = CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE
    WHEN NOT MATCHED THEN
        INSERT (
            course_id,
            name,
            datestart,
            datefinish
        ) 
        VALUES (
            nextval('lab.sq_lab_course_course_id'),
            src.course_name,
            src.course_datestart,
            src.course_datefinish
        );
END; $$
