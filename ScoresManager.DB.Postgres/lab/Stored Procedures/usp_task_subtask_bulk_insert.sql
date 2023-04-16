-- =============================================
-- Author:      Sergei Boikov
-- Create Date: 2023-04-16
-- Modify Date:        2021-07-29
-- Description: Load information about task and subtasks from JSON
-- Format JSON: '{"course_name": "BI.Lab.Cross.2021", "task_name": "Intro.Test", "taskdescription": "Initial test for mentees", "task_topic": "Module #1: Intro", "subtask_name": "Test", "subtaskdescription": "Test", "subtask_topic": "DB Basics", "subtaskmax_score": 12.5}' 
-- Example: EXEC lab.usp_tasksubtask_bulk_insert jsn = '{"course_name": "BI.Lab.Cross.2021", "task_name": "Intro.Test", "taskdescription": "Initial test for mentees", "task_topic": "Module #1: Intro", "subtask_name": "Test", "subtaskdescription": "Test", "subtask_topic": "DB Basics", "subtaskmax_score": 12.5}' 
-- =============================================

CREATE OR REPLACE PROCEDURE lab.usp_tasksubtask_bulk_insert(jsn JSON)
LANGUAGE plpgsql
AS $$
BEGIN

    DECLARE        NoMatchedtask_topicFromJson            VARCHAR(250),
                no_matched_course_name_from_json        VARCHAR(250),
                NoMatchedsubtask_topicFromJson        VARCHAR(250)
    BEGIN
        BEGIN
            BEGIN
                CREATE TEMPORARY TABLE temp_source (
        --TODO: FILL
    ) ON COMMIT DROP;
                SELECT *
                INTO temp_source
                FROM OPENJSON(jsn)
                WITH (
                         course_name            VARCHAR(250)   '$.course_name'
                        ,task_name            VARCHAR(100)   '$.task_name'
                        ,taskdescription    VARCHAR(100)   '$.taskdescription'
                        ,task_topic            VARCHAR(250)   '$.task_topic'
                        ,subtask_name        VARCHAR(250)   '$.subtask_name'
                        ,subtaskdescription TEXT   '$.subtaskdescription'
                        ,subtask_topic       VARCHAR(250)   '$.subtask_topic'
                        ,subtaskmax_score    VARCHAR(250)   '$.subtaskmax_score'
               ) AS RootL;                -- Check course names
                SELECT TOP 1 no_matched_course_name_from_json = tmp.course_name
                FROM temp_source AS tmp
                LEFT JOIN lab.course AS c ON TRIM(UPPER(c."name")) = TRIM(UPPER(tmp.course_name))
                WHERE tmp.course_name IS NOT NULL
                    AND c.course_id IS NULL                IF (no_matched_course_name_from_json IS NOT NULL)
                BEGIN
                    RAISERROR ('course with name: ''%s'' isn''t found', 16, 1, no_matched_course_name_from_json);
                END                -- task_topic
                MERGE INTO lab.topic tgt
                USING (SELECT DISTINCT task_topic AS topic, 1 AS is_topic_for_tasks
                       FROM temp_source) src
                    ON TRIM(UPPER(tgt."name")) = TRIM(UPPER(src.topic))
                WHEN MATCHED THEN
                UPDATE SET
                     tgt.is_topic_for_tasks = src.is_topic_for_tasks
                    ,tgt.sys_changed_at = CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE
                WHEN NOT MATCHED THEN
                INSERT (
                     name
                    ,is_topic_for_tasks
                ) VALUES
                (
                     src.topic
                    ,src.is_topic_for_tasks
                );                -- subtask_topic
                MERGE INTO lab.topic tgt
                USING (SELECT DISTINCT subtask_topic AS topic, 1 AS is_topic_for_subtasks 
                       FROM temp_source) src
                    ON TRIM(UPPER(tgt."name")) = TRIM(UPPER(src.topic))
                WHEN MATCHED THEN
                UPDATE SET
                     tgt.is_topic_for_subtasks = src.is_topic_for_subtasks
                    ,tgt.sys_changed_at = CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE
                WHEN NOT MATCHED THEN
                INSERT (
                     name
                    ,is_topic_for_subtasks
                ) VALUES
                (
                     src.topic
                    ,src.is_topic_for_subtasks
                );                --task
                MERGE INTO lab.task tgt
                USING (    SELECT DISTINCT  course_id
                                        ,tmp.task_name
                                        ,tmp.taskdescription
                                        ,tt.topic_id
                        FROM temp_source AS tmp
                        INNER JOIN lab.course AS c ON TRIM(UPPER(c."name")) = TRIM(UPPER(tmp.course_name))
                        INNER JOIN lab.topic AS tt ON TRIM(UPPER(tt."name")) = TRIM(UPPER(tmp.task_topic))) src
                    ON (tgt."name" = src.task_name
                        AND tgt.course_id = src.course_id)
                WHEN MATCHED THEN
                UPDATE SET
                     tgt.description = src.taskdescription
                    ,tgt.topic_id = src.topic_id
                    ,tgt.sys_changed_at = CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE
                WHEN NOT MATCHED THEN
                INSERT (
                     name
                    ,description
                    ,topic_id
                    ,course_id
                ) VALUES
                (
                     src.task_name
                    ,src.taskdescription
                    ,src.topic_id
                    ,src.course_id
                );                -- subtask
                MERGE INTO lab.subtask tgt
                USING (
                    SELECT t.task_id
                          ,tmp.subtask_name
                          ,tmp.subtaskdescription
                          ,stt.topic_id 
                          ,tmp.subtaskmax_score
                    FROM temp_source AS tmp
                    INNER JOIN lab.topic AS stt ON TRIM(UPPER(stt."name")) = TRIM(UPPER(tmp.subtask_topic))
                    INNER JOIN lab.task AS t ON TRIM(UPPER(t."name")) = TRIM(UPPER(tmp.task_name))
                    WHERE tmp.subtask_name IS NOT NULL) src ON (src.subtask_name = tgt."name" 
                        AND src.task_id = tgt.task_id)
                WHEN MATCHED THEN
                UPDATE SET
                     tgt.description = src.subtaskdescription
                    ,tgt.topic_id = src.topic_id
                    ,tgt.max_score = src.subtaskmax_score
                    ,tgt.sys_changed_at = CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE
                WHEN NOT MATCHED THEN
                INSERT (
                     task_id
                    ,name
                    ,description
                    ,topic_id
                    ,max_score
                ) VALUES
                (
                     src.task_id
                    ,src.subtask_name
                    ,src.subtaskdescription
                    ,src.topic_id
                    ,src.subtaskmax_score
                );
                
                

    END
END