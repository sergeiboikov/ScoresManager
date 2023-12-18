-- =============================================
-- Author:      Sergei Boikov
-- Create Date: 2023-04-21
-- Description: Load information about task and subtasks from JSON
/* Example 1. Add task and subtasks: CALL mentor.usp_task_subtask_insert ('{"course_name": "MSBI.DEV.S20", "task_name": "MSBI.DEV.task.164", "task_description": "SSIS.Part.5", "task_topic": "SSIS.Part.5", 
                                                          "subtasks":  
                                                                         [{"subtask_name": "subtask.164.01", "subtask_description": "SSIS project development", "subtask_topic": "SSIS", "subtaskmax_score": 12.5, "bonuses":["readability", "sarg"]} 
                                                                        ,{"subtask_name": "subtask.164.02", "subtask_description": "SSIS project deployment", "subtask_topic": "SSIS", "subtaskmax_score": 12.5, "bonuses":["readability", "sarg"]}]
                                                          }');
                                                          
   Example 2. Add task without subtasks: CALL mentor.usp_task_subtask_insert ('{"course_name": "MSBI.DEV.S20", "task_name": "MSBI.DEV.task.164", "task_description": "SSIS.Part.5", "task_topic": "SSIS.Part.5"}');
*/
-- =============================================

CREATE OR REPLACE PROCEDURE mentor.usp_task_subtask_insert(jsn JSON)
LANGUAGE plpgsql
AS $$
    DECLARE     
        no_matched_bonus_from_json          VARCHAR(250) := '';
        no_matched_task_topic_from_json     VARCHAR(250) := '';
        no_matched_course_from_json         VARCHAR(250) := '';
        no_matched_subtask_topic_from_json  VARCHAR(250) := '';
BEGIN
/*========================================================================================================================
 * Insert temp data from JSON
========================================================================================================================*/

    CREATE TEMPORARY TABLE temp_source (
        course_name         VARCHAR(250),
        task_name           VARCHAR(100),
        task_description    VARCHAR(100),
        task_topic          VARCHAR(250),
        subtask_name        VARCHAR(250),
        subtask_description TEXT,
        subtask_topic       VARCHAR(250),
        subtask_max_score   VARCHAR(250),
        bonus               VARCHAR(250)
    ) ON COMMIT DROP;

    INSERT INTO temp_source(
        course_name,
        task_name,
        task_description,
        task_topic,
        subtask_name,
        subtask_description,
        subtask_topic,
        subtask_max_score,
        bonus            
    )
    SELECT
        root_l.course_name,
        root_l.task_name,
        root_l.task_description,
        root_l.task_topic,
        lief_l.subtask_name,
        lief_l.subtask_description,
        lief_l.subtask_topic,
        lief_l.subtask_max_score,
        json_array_elements_text(lief_l.bonuses) AS bonus
    FROM 
        json_to_record(jsn) AS root_l(
            course_name         VARCHAR(250),
            task_name           VARCHAR(100),
            task_description    VARCHAR(100),
            task_topic          VARCHAR(250)
        )
    LEFT JOIN (
        SELECT * 
        FROM json_to_recordset(
                json_extract_path(jsn, 'subtasks')
                ) AS lief_l(
                    subtask_name        VARCHAR(250),
                    subtask_description TEXT,
                    subtask_topic       VARCHAR(250),
                    subtask_max_score   VARCHAR(250),
                    bonuses             JSON)
    ) AS lief_l
        ON 1 = 1;

/*========================================================================================================================
 * Check task_topic names
========================================================================================================================*/
    SELECT tmp.task_topic
    INTO no_matched_task_topic_from_json
    FROM temp_source AS tmp
    LEFT JOIN lab.topic AS tt ON TRIM(UPPER(tt."name")) = TRIM(UPPER(tmp.task_topic))
    WHERE tmp.task_topic IS NOT NULL
        AND tt.topic_id IS NULL
    LIMIT 1;

    IF (no_matched_task_topic_from_json IS NOT NULL)
    THEN
        RAISE EXCEPTION 'Task topic: ''%'' isn''t found', no_matched_task_topic_from_json;
    END IF;    

/*========================================================================================================================
 * Check subtask_topic names
========================================================================================================================*/
    SELECT tmp.subtask_topic
    INTO no_matched_subtask_topic_from_json
    FROM temp_source AS tmp
    LEFT JOIN lab.topic AS stt ON TRIM(UPPER(stt."name")) = TRIM(UPPER(tmp.subtask_topic))
    WHERE tmp.subtask_topic IS NOT NULL
        AND stt.topic_id IS NULL
    LIMIT 1;

    IF (no_matched_subtask_topic_from_json IS NOT NULL)
    THEN
        RAISE EXCEPTION 'Subtask topic: ''%'' isn''t found', no_matched_subtask_topic_from_json;
    END IF;                  

/*========================================================================================================================
 * Check course
========================================================================================================================*/
    SELECT tmp.course_name
    INTO no_matched_course_from_json
    FROM temp_source AS tmp
    LEFT JOIN lab.course AS c ON TRIM(UPPER(c."name")) = TRIM(UPPER(tmp.course_name))
    WHERE tmp.course_name IS NOT NULL
        AND c."name" IS NULL
    LIMIT 1;

    IF (no_matched_course_from_json IS NOT NULL)
    THEN
        RAISE EXCEPTION 'course: ''%'' isn''t found', no_matched_course_from_json;
    END IF;  


    --Create temporary table for Task
    CREATE TEMPORARY TABLE temp_task_result(
        task_id     INTEGER,
        "action"    TEXT
    ) ON COMMIT DROP;
    
    
    WITH inserted AS (
        INSERT INTO lab.task(task_id, course_id, task_name, task_description, topic_id)
        SELECT DISTINCT
            nextval('lab.sq_lab_task_task_id') AS task_id,
            c.course_id,
            tmp.task_name,
            tmp.task_description,
            tt.topic_id
        FROM temp_source AS tmp
        JOIN lab.course AS c ON c.name = tmp.course_name
        JOIN lab.topic AS tt ON TRIM(UPPER(tt.name)) = TRIM(UPPER(tmp.task_topic))
        LEFT JOIN lab.task AS t ON t.course_id = c.course_id
            AND t.task_name = tmp.task_name
        WHERE 1 = 1
            AND t.task_id IS NULL
        ON CONFLICT (course_id, task_name)
            DO UPDATE SET
                description = src.task_description,
                topic_id = src.topic_id,
                sys_changed_at = NOW()
                WHERE course_id = c.course_id
                    AND task_name = tmp.task_name
        RETURNING task_id, action
    )
    INSERT INTO temp_task_result(task_id, action)
    SELECT task_id, action FROM inserted;
   
                
 /*               
                -- subtask
                MERGE INTO lab.subtask tgt
                USING (
                    SELECT DISTINCT 
                        (SELECT task_id FROM #temp_task_result) AS task_id
                        ,tmp.subtask_name
                        ,tmp.subtask_description
                        ,stt.topic_id 
                        ,tmp.subtaskmax_score
                    FROM temp_source AS tmp
                    INNER JOIN lab.topic AS stt ON TRIM(UPPER(stt."name")) = TRIM(UPPER(tmp.subtask_topic))
                    WHERE tmp.subtask_name IS NOT NULL) src ON (src.subtask_name = tgt."name" 
                        AND src.task_id = tgt.task_id)
                WHEN MATCHED THEN
                UPDATE SET
                     tgt.description = src.subtask_description
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
                    ,src.subtask_description
                    ,src.topic_id
                    ,src.subtaskmax_score
                )
                OUTPUT inserted.subtask_id, inserted."name", $action
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
                DROP TABLE #temp_task_result;
                DROP TABLE #TEMP_subtask_RESULT;
*/
END; $$