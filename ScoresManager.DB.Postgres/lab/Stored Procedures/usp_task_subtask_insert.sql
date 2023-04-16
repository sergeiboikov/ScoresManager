-- =============================================
-- Author:      Sergei Boikov
-- Create Date:        2020-12-28
-- Modify Date:        2021-07-29
-- Description: Load information about task and subtasks from JSON
/* Format JSON: '{"course_name": "MSBI.DEV.S20", "task_name": "MSBI.DEV.task.164", "taskdescription": "SSIS.Part.5", "task_topic": "SSIS.Part.5", 
                  "subtasks":  
                                 {"subtask_name": "subtask.164.01", "subtaskdescription": "SSIS project development", "subtask_topic": "SSIS", "subtaskmax_score": 12.5, "bonuses":"readability", "sarg"} 
                                ,{"subtask_name": "subtask.164.02", "subtaskdescription": "SSIS project deployment", "subtask_topic": "SSIS", "subtaskmax_score": 12.5, "bonuses":"readability", "sarg"}            
                              
                  }' 
*/
/*    Example 1. Add task and subtasks: EXEC lab.usp_tasksubtask_insert jsn = '{"course_name": "MSBI.DEV.S20", "task_name": "MSBI.DEV.task.164", "taskdescription": "SSIS.Part.5", "task_topic": "SSIS.Part.5", 
                                                          "subtasks":  
                                                                         {"subtask_name": "subtask.164.01", "subtaskdescription": "SSIS project development", "subtask_topic": "SSIS", "subtaskmax_score": 12.5, "bonuses":"readability", "sarg"} 
                                                                        ,{"subtask_name": "subtask.164.02", "subtaskdescription": "SSIS project deployment", "subtask_topic": "SSIS", "subtaskmax_score": 12.5, "bonuses":"readability", "sarg"}            
                                                                      
                                                          }' 
                                                          
    Example 2. Add task without subtasks: EXEC lab.usp_tasksubtask_insert jsn = '{"course_name": "MSBI.DEV.S20", "task_name": "MSBI.DEV.task.164", "taskdescription": "SSIS.Part.5", "task_topic": "SSIS.Part.5"}'
*/-- =============================================

CREATE OR REPLACE PROCEDURE lab.usp_tasksubtask_insert(jsn JSON)
LANGUAGE plpgsql
AS $$
BEGIN

    DECLARE        NoMatchedbonusFromJson                VARCHAR(250),
                NoMatchedtask_topicFromJson            VARCHAR(250),
                NoMatchedcourseFromJson            VARCHAR(250),
                NoMatchedsubtask_topicFromJson        VARCHAR(250)
    BEGIN
        BEGIN
            BEGIN
                CREATE TEMPORARY TABLE temp_source (
        --TODO: FILL
    ) ON COMMIT DROP;

                DROP TABLE IF EXISTS #TEMP_task_RESULT;
                DROP TABLE IF EXISTS #TEMP_subtask_RESULT;                CREATE TABLE #TEMP_task_RESULT (task_id INT, Action VARCHAR(10));
                CREATE TABLE #TEMP_subtask_RESULT (subtask_id INT, subtask_name VARCHAR(250), Action VARCHAR(10));                SELECT *
                INTO temp_source
                FROM OPENJSON(jsn)
                WITH (
                         course_name            VARCHAR(250)   '$.course_name'
                        ,task_name            VARCHAR(100)   '$.task_name'
                        ,taskdescription    VARCHAR(100)   '$.taskdescription'
                        ,task_topic            VARCHAR(250)   '$.task_topic'
               ) AS rootL
                LEFT JOIN OPENJSON(jsn, '$.subtasks')
                WITH (
                         subtask_name        VARCHAR(250)   '$.subtask_name'
                        ,subtaskdescription TEXT   '$.subtaskdescription'
                        ,subtask_topic       VARCHAR(250)   '$.subtask_topic'
                        ,subtaskmax_score    VARCHAR(250)   '$.subtaskmax_score'
                        ,bonuses            TEXT    '$.bonuses'                AS JSON
               ) AS liefL ON 1 = 1
                OUTER APPLY OPENJSON(bonuses)
                    WITH (bonus VARCHAR(30) '$');                -- Check task_topic names
                SELECT TOP 1 NoMatchedtask_topicFromJson = tmp.task_topic
                FROM temp_source AS tmp
                LEFT JOIN lab.topic AS tt ON TRIM(UPPER(tt."name")) = TRIM(UPPER(tmp.task_topic))
                WHERE tmp.task_topic IS NOT NULL
                    AND tt.topic_id IS NULL                IF (NoMatchedtask_topicFromJson IS NOT NULL)
                BEGIN
                    RAISERROR ('task_topic: ''%s'' isn''t found', 16, 1, NoMatchedtask_topicFromJson);
                END                -- Check subtask_topic names
                SELECT TOP 1 NoMatchedsubtask_topicFromJson = tmp.subtask_topic
                FROM temp_source AS tmp
                LEFT JOIN lab.topic AS stt ON TRIM(UPPER(stt."name")) = TRIM(UPPER(tmp.subtask_topic))
                WHERE tmp.subtask_topic IS NOT NULL
                    AND stt.topic_id IS NULL                IF (NoMatchedsubtask_topicFromJson IS NOT NULL)
                BEGIN
                    RAISERROR ('subtask_topic: ''%s'' isn''t found', 16, 1, NoMatchedsubtask_topicFromJson);
                END                -- Check course
                SELECT TOP 1 NoMatchedcourseFromJson = tmp.course_name
                FROM temp_source AS tmp
                LEFT JOIN lab.course AS c ON TRIM(UPPER(c."name")) = TRIM(UPPER(tmp.course_name))
                WHERE tmp.course_name IS NOT NULL
                    AND c."name" IS NULL                IF (NoMatchedcourseFromJson IS NOT NULL)
                BEGIN
                    RAISERROR ('course: ''%s'' isn''t found', 16, 1, NoMatchedcourseFromJson);
                END                --task
                MERGE INTO lab.task tgt
                USING (    SELECT DISTINCT  course_id
                                        ,tmp.task_name
                                        ,tmp.taskdescription
                                        ,tt.topic_id
                        FROM temp_source AS tmp
                        INNER JOIN lab.course AS c ON c."name" = tmp.course_name
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
                )
                OUTPUT inserted.task_id, $ACTION
                INTO #TEMP_task_RESULT;                -- subtask
                MERGE INTO lab.subtask tgt
                USING (
                    SELECT DISTINCT 
                        (SELECT task_id FROM #TEMP_task_RESULT) AS task_id
                        ,tmp.subtask_name
                        ,tmp.subtaskdescription
                        ,stt.topic_id 
                        ,tmp.subtaskmax_score
                    FROM temp_source AS tmp
                    INNER JOIN lab.topic AS stt ON TRIM(UPPER(stt."name")) = TRIM(UPPER(tmp.subtask_topic))
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
                )
                OUTPUT inserted.subtask_id, inserted."name", $ACTION
                INTO #TEMP_subtask_RESULT;                -- Check bonus names
                SELECT TOP 1 NoMatchedbonusFromJson = tmp.bonus
                FROM temp_source AS tmp
                LEFT JOIN lab.bonus AS b ON TRIM(UPPER(b."name")) = TRIM(UPPER(tmp.bonus))
                WHERE tmp.bonus IS NOT NULL
                    AND b.bonus_id IS NULL                IF (NoMatchedbonusFromJson IS NOT NULL)
                BEGIN
                    RAISERROR ('bonus: ''%s'' isn''t found', 16, 1, NoMatchedbonusFromJson);
                END                -- subtask_bonus
                MERGE INTO lab.subtask_bonus tgt
                USING (
                    SELECT     tsr.subtask_id
                            ,b.bonus_id
                    FROM #TEMP_subtask_RESULT tsr
                    INNER JOIN temp_source AS tmp ON tmp.subtask_name = tsr.subtask_name
                    LEFT JOIN lab.bonus AS b ON b."name" = tmp.bonus
                    WHERE tmp.bonus IS NOT NULL) src ON (src.subtask_id = tgt.subtask_id 
                        AND src.bonus_id = tgt.bonus_id)
                WHEN NOT MATCHED THEN
                INSERT (
                     subtask_id
                    ,bonus_id 
                ) VALUES
                (
                     src.subtask_id
                    ,src.bonus_id
                );
                
                --Delete not matched bonuses from lab.subtask_bonus
                DELETE FROM lab.subtask_bonus
                WHERE subtask_bonus_id IN ( SELECT stb.subtask_bonus_id
                                            FROM lab.subtask_bonus stb
                                            INNER JOIN lab.bonus b ON b.bonus_id = stb.bonus_id
                                            INNER JOIN #TEMP_subtask_RESULT tsr ON tsr.subtask_id = stb.subtask_id
                                            LEFT JOIN temp_source AS tmp ON tmp.subtask_name = tsr.subtask_name
                                                AND TRIM(UPPER(tmp.bonus)) = TRIM(UPPER(b."name"))
                                            WHERE tmp.bonus IS NULL);                
                DROP TABLE #TEMP_task_RESULT;
                DROP TABLE #TEMP_subtask_RESULT;

    END
END