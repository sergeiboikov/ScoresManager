
-- =============================================
-- Author:      Sergei Boikov
-- Create Date:        2021-01-21
-- Modify Date:        2021-07-29
-- Description: Load information about subtask from JSON. Value is bonus_code
-- Format JSON: '{"bonuses":{"Value":"read"},{"Value":"aliases"},"subtaskdescription":"Create T-SQL script1","subtask_name":"subtask.03.06","subtask_topic_id":12,"subtaskmax_score":12.5,"task_id":1}' --    Example. EXEC lab.usp_subtask_insert jsn = '{"bonuses":{"Value":"read"},{"Value":"aliases"},"subtaskdescription":"Create T-SQL script1","subtask_name":"subtask.03.06","subtask_topic_id":12,"subtaskmax_score":12.5,"task_id":1}' -- =============================================

CREATE OR REPLACE PROCEDURE mentor.usp_subtask_insert
(
     jsn            TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    DECLARE         NoMatchedbonusFromJson    VARCHAR(250)
                ,task_id                    INT
                ,topic_id                    INT
                
    BEGIN
        BEGIN
            BEGIN
                CREATE TEMPORARY TABLE temp_source (
        --TODO: FILL
    ) ON COMMIT DROP;

                DROP TABLE IF EXISTS #TEMP_subtask_RESULT;                CREATE TABLE #TEMP_subtask_RESULT (subtask_id INT, subtask_name VARCHAR(250), Action VARCHAR(10));                SELECT DISTINCT *
                INTO temp_source
                FROM OPENJSON(jsn)
                WITH (
                         task_id                INT                '$.task_id'
                        ,subtask_name        VARCHAR(250)   '$.subtask_name'
                        ,subtaskdescription TEXT   '$.subtaskdescription'
                        ,subtask_topic_id     SMALLINT        '$.subtask_topic_id'
                        ,subtaskmax_score    NUMERIC(8,2)    '$.subtaskmax_score'
                        ,bonuses            TEXT    '$.bonuses'                AS JSON
               ) AS rootL
                OUTER APPLY OPENJSON(bonuses)
                    WITH (bonus_code VARCHAR(30) '$.Value');                                /*Check that task with task_id exists*/
                SELECT task_id = tmp.task_id FROM temp_source tmp;
                IF (task_id IS NULL OR NOT EXISTS(  SELECT 1
                                                    FROM lab.task t
                                                    WHERE t.task_id = task_id))
                    THROW 50000, 'Parent task isn''t found', 0;                /*Check that topic with topic_id exists*/
                SELECT topic_id = tmp.subtask_topic_id FROM temp_source tmp;
                IF (topic_id IS NULL OR NOT EXISTS(  SELECT 1
                                                     FROM lab.topic t
                                                     WHERE t.topic_id = topic_id))
                    THROW 50000, 'topic isn''t found', 0;                 -- subtask
                MERGE INTO lab.subtask tgt
                USING (
                    SELECT DISTINCT 
                         tmp.task_id
                        ,tmp.subtask_name
                        ,tmp.subtaskdescription
                        ,tmp.subtask_topic_id 
                        ,tmp.subtaskmax_score
                    FROM temp_source AS tmp
                    WHERE tmp.subtask_name IS NOT NULL) src ON (src.subtask_name = tgt."name" 
                        AND src.task_id = tgt.task_id)
                WHEN MATCHED THEN
                UPDATE SET
                     tgt.description = src.subtaskdescription
                    ,tgt.topic_id = src.subtask_topic_id
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
                    ,src.subtask_topic_id
                    ,src.subtaskmax_score
                )
                OUTPUT inserted.subtask_id, inserted."name", $ACTION
                INTO #TEMP_subtask_RESULT;                -- Check bonus names
                SELECT TOP 1 NoMatchedbonusFromJson = tmp.bonus_code
                FROM temp_source AS tmp
                LEFT JOIN lab.bonus AS b ON b.code = tmp.bonus_code
                WHERE tmp.bonus_code IS NOT NULL
                    AND b.bonus_id IS NULL                IF (NoMatchedbonusFromJson IS NOT NULL)
                    RAISERROR ('bonus code: ''%s'' isn''t found', 16, 1, NoMatchedbonusFromJson);                -- subtask_bonus
                MERGE INTO lab.subtask_bonus tgt
                USING (
                    SELECT     tsr.subtask_id
                            ,b.bonus_id
                    FROM #TEMP_subtask_RESULT tsr
                    INNER JOIN temp_source AS tmp ON tmp.subtask_name = tsr.subtask_name
                    LEFT JOIN lab.bonus AS b ON b.code = tmp.bonus_code
                    WHERE tmp.bonus_code IS NOT NULL) src ON (src.subtask_id = tgt.subtask_id 
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
                                                AND tmp.bonus_code = b.code
                                            WHERE tmp.bonus_code IS NULL);                
                DROP TABLE #TEMP_subtask_RESULT;            COMMIT;        END TRY
        BEGIN CATCH
                IF TRANCOUNT > 0 
                    ROLLBACK TRANSACTION;
                THROW;
                
        END CATCH;
    END
    ELSE
        THROW 50000, 'JSON isn''t correct', 0;
        
END