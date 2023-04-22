-- =============================================
-- Author:      Sergei Boikov
-- Create Date: 2023-04-21
-- Description: Load information about task and subtasks from JSON
-- Example: CALL mentor.usp_task_subtask_bulk_insert('[{"course_name": "BI.RD.LAB.2023.1", "task_name": "Intro.Test", "task_description": "Initial test for mentees", "task_topic": "Module #1: Intro", "subtask_name": "Test", "subtask_description": "Test", "subtask_topic": "DB Basics", "subtask_max_score": 12.5}]');
-- =============================================

CREATE OR REPLACE PROCEDURE mentor.usp_task_subtask_bulk_insert(jsn JSON)
LANGUAGE plpgsql
AS $$
DECLARE 
    no_matched_task_topic_from_json     VARCHAR(250) := '';
    no_matched_course_name_from_json    VARCHAR(250) := '';
    no_matched_subtask_topic_from_json  VARCHAR(250) := '';
BEGIN
/*========================================================================================================================
 * Insert temp data from JSON
========================================================================================================================*/

    CREATE TEMPORARY TABLE temp_source (
        course_name             VARCHAR(250),
        task_name               VARCHAR(100),
        task_description        VARCHAR(100),
        task_topic              VARCHAR(250),
        subtask_name            VARCHAR(250),
        subtask_description     TEXT,
        subtask_topic           VARCHAR(250),
        subtask_max_score       NUMERIC(8,2)
    ) ON COMMIT DROP;

    INSERT INTO temp_source(
        course_name,
        task_name,
        task_description,
        task_topic,
        subtask_name,
        subtask_description,
        subtask_topic,
        subtask_max_score
    )
    SELECT
        j.course_name,
        j.task_name,
        j.task_description,
        j.task_topic,
        j.subtask_name,
        j.subtask_description,
        j.subtask_topic,
        j.subtask_max_score
    FROM json_to_recordset(jsn) AS j (
        course_name             VARCHAR(250),
        task_name               VARCHAR(100),
        task_description        VARCHAR(100),
        task_topic              VARCHAR(250),
        subtask_name            VARCHAR(250),
        subtask_description     TEXT,
        subtask_topic           VARCHAR(250),
        subtask_max_score       NUMERIC(8,2)
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
 * Merge task_topic
========================================================================================================================*/
    
    MERGE INTO lab.topic AS tgt
    USING (
        SELECT DISTINCT 
            task_topic  AS topic, 
            1::BIT      AS is_topic_for_tasks
        FROM temp_source
    ) src
        ON TRIM(UPPER(tgt."name")) = TRIM(UPPER(src.topic))
    WHEN MATCHED THEN
    UPDATE SET
        is_topic_for_tasks = src.is_topic_for_tasks,
        sys_changed_at = CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE
    WHEN NOT MATCHED THEN
    INSERT (
        topic_id,
        "name",
        is_topic_for_tasks
    ) VALUES (
        nextval('lab.sq_lab_topic_topic_id'),
        src.topic,
        src.is_topic_for_tasks
    );

/*========================================================================================================================
 * Merge subtask_topic
========================================================================================================================*/

    MERGE INTO lab.topic AS tgt
    USING (
        SELECT DISTINCT 
            subtask_topic   AS topic, 
            1::BIT          AS is_topic_for_subtasks
        FROM temp_source
    ) src
        ON TRIM(UPPER(tgt."name")) = TRIM(UPPER(src.topic))
    WHEN MATCHED THEN
    UPDATE SET
        is_topic_for_subtasks = src.is_topic_for_subtasks,
        sys_changed_at = CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE
    WHEN NOT MATCHED THEN
    INSERT (
        topic_id,
        "name",
        is_topic_for_subtasks
    ) VALUES (
        nextval('lab.sq_lab_topic_topic_id'),
        src.topic,
        src.is_topic_for_subtasks
    );
                
/*========================================================================================================================
 * Merge task
========================================================================================================================*/
              
    MERGE INTO lab.task tgt
    USING (    
        SELECT DISTINCT  
            course_id,
            tmp.task_name,
            tmp.task_description,
            tt.topic_id
        FROM temp_source AS tmp
        INNER JOIN lab.course AS c 
            ON TRIM(UPPER(c."name")) = TRIM(UPPER(tmp.course_name))
        INNER JOIN lab.topic AS tt 
            ON TRIM(UPPER(tt."name")) = TRIM(UPPER(tmp.task_topic))
    ) src
        ON (tgt."name" = src.task_name
            AND tgt.course_id = src.course_id)
    WHEN MATCHED THEN
    UPDATE SET
        description = src.task_description,
        topic_id = src.topic_id,
        sys_changed_at = CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE
    WHEN NOT MATCHED THEN
    INSERT (
        task_id,
        "name",
        description,
        topic_id,
        course_id
    ) VALUES (
        nextval('lab.sq_lab_task_task_id'),
        src.task_name,
        src.task_description,
        src.topic_id,
        src.course_id
    );

/*========================================================================================================================
 * Merge subtask
========================================================================================================================*/

    MERGE INTO lab.subtask tgt
    USING (
        SELECT 
            t.task_id,
            tmp.subtask_name,
            tmp.subtask_description,
            stt.topic_id,
            tmp.subtask_max_score
        FROM temp_source AS tmp
        INNER JOIN lab.topic AS stt 
            ON TRIM(UPPER(stt."name")) = TRIM(UPPER(tmp.subtask_topic))
        INNER JOIN lab.task AS t 
            ON TRIM(UPPER(t."name")) = TRIM(UPPER(tmp.task_name))
        WHERE tmp.subtask_name IS NOT NULL) src 
    ON (src.subtask_name = tgt."name" 
        AND src.task_id = tgt.task_id)
    WHEN MATCHED THEN
    UPDATE SET
        description = src.subtask_description,
        topic_id = src.topic_id,
        max_score = src.subtask_max_score,
        sys_changed_at = CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE
    WHEN NOT MATCHED THEN
    INSERT (
        subtask_id,
        task_id,
        "name",
        description,
        topic_id,
        max_score
    ) VALUES (
        nextval('lab.sq_lab_subtask_subtask_id'),
        src.task_id,
        src.subtask_name,
        src.subtask_description,
        src.topic_id,
        src.subtask_max_score
    );
END; $$