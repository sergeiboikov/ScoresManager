-- =============================================
-- Author:      Boykov_Sergey
-- Create Date: 2020-12-29
-- Description: Update the table lab.subtask_log. Load scores from JSON to the table.
/* Format JSON: '{"course_name": "MSBI.DEV.S21", "reviewer_name": "Sergei Boikov", "student_name": "Anna Sedina", "task_name": "MSBI.DEV.task.05", 
                    "subtasks":  
                                    {"subtask_name": "subtask.05.08", "Mark": 5, "name_conv": 0, "Redability": 1, "sarg": 0, "schema_name": 1, "aliases": 1, "determ_sorting": 0, "ontime": 1, "extra": 1, "comment": ""}
                                   ,{"subtask_name": "subtask.05.09", "Mark": 5, "name_conv": 0, "Redability": 1, "sarg": 0, "schema_name": 1, "aliases": 1, "determ_sorting": 0, "ontime": 1, "extra": 1, "comment": ""}
                                
                  }' */
/* Example: EXEC mentor.usp_scores_insert '{"course_name": "MSBI.DEV.S19", "reviewer_name": "Sergei Boikov", "student_name": "Anna Sedina", "task_name": "MSBI.DEV.task.05", 
                                             "subtasks":  
                                                             {"subtask_name": "subtask.05.08", "Mark": 5, "name_conv": 0, "Redability": 1, "sarg": 0, "schema_name": 1, "aliases": 1, "determ_sorting": 0, "ontime": 1, "extra": 1, "comment": ""}
                                                            ,{"subtask_name": "subtask.05.09", "Mark": 5, "name_conv": 0, "Redability": 1, "sarg": 0, "schema_name": 1, "aliases": 1, "determ_sorting": 0, "ontime": 1, "extra": 1, "comment": ""}
                                                         
                                             }' */
-- =============================================

CREATE OR REPLACE PROCEDURE lab.usp_scores_insert(jsn JSON)
LANGUAGE plpgsql
AS $$
BEGIN

    DECLARE reviewer_nameFromJson   VARCHAR(100),
            student_nameFromJson    VARCHAR(100),
            course_nameFromJson     VARCHAR(250),
            reviewer_id             INT,
            student_id              INT,
            course_id               INT
    BEGIN
        BEGIN
            BEGIN
                CREATE TEMPORARY TABLE temp_source (
        --TODO: FILL
    ) ON COMMIT DROP;

                DROP TABLE IF EXISTS #TEMP_RESULT;
                CREATE TABLE #TEMP_RESULT (subtask_log_id INT, Action VARCHAR(10));
                
                --=============================
                --read data from JSON
                --=============================
                SELECT *
                INTO temp_source
                    FROM OPENJSON(jsn)
                    WITH (
                             course_name     VARCHAR(250)   '$.course_name'
                            ,reviewer_name   VARCHAR(100)   '$.reviewer_name'
                            ,student_name    VARCHAR(100)   '$.student_name'
                            ,task_name       VARCHAR(250)   '$.task_name'
                   )
                    CROSS APPLY OPENJSON(jsn, '$.subtasks')
                    WITH (
                             subtask_name    VARCHAR(250)   '$.subtask_name'
                            ,score          NUMERIC(8,2)    '$.Mark'
                            ,name_conv       NUMERIC(8,2)    '$."name"_conv'
                            ,Redability     NUMERIC(8,2)    '$.Redability'
                            ,sarg           NUMERIC(8,2)    '$.sarg'
                            ,schema_name     NUMERIC(8,2)    '$.schema_name'
                            ,aliases        NUMERIC(8,2)    '$.aliases'
                            ,determ_sorting  NUMERIC(8,2)    '$.determ_sorting'
                            ,ontime         NUMERIC(8,2)    '$.ontime'
                            ,extra          NUMERIC(8,2)    '$.extra'
                            ,comment        VARCHAR(250)   '$.comment'
                   );                --=============================
                --Get course info
                --=============================
                SELECT TOP 1 course_nameFromJson = t.course_name 
                FROM temp_source AS t;                SELECT TOP 1 course_id = c.course_id
                FROM lab.course AS c
                WHERE c."name" = course_nameFromJson
                
                --=============================
                --Check reviewer_name
                --=============================
                SELECT TOP 1 reviewer_nameFromJson = t.reviewer_name 
                FROM temp_source AS t;
                
                SELECT TOP 1 reviewer_id = u.user_id 
                FROM lab.user AS u 
                INNER JOIN lab.course_staff sc ON sc.user_id = u.user_id
                INNER JOIN lab.user_type ut ON ut.user_type_id = sc.user_type_id
                WHERE ut."name" = 'Mentor'
                    AND sc.course_id = course_id
                    AND u."name" = reviewer_nameFromJson;                  IF (reviewer_id IS NULL)
                BEGIN
                    RAISERROR ('Reviewer isn''t found', 16, 1);
                END                --=============================
                --Check student_name
                --=============================
                SELECT TOP 1 student_nameFromJson = t.student_name 
                FROM temp_source AS t;                SELECT TOP 1 student_id = u.user_id 
                FROM lab.user AS u 
                INNER JOIN lab.course_staff sc ON sc.user_id = u.user_id
                INNER JOIN lab.user_type ut ON ut.user_type_id = sc.user_type_id
                WHERE ut."name" = 'student'
                    AND sc.course_id = course_id
                    AND u."name" = student_nameFromJson;                IF (student_id IS NULL)
                BEGIN
                    RAISERROR ('student isn''t found', 16, 1);
                END                --=============================
                --Check subtask
                --=============================
                                IF EXISTS (
                    SELECT t.task_name, t.subtask_name 
                    FROM temp_source AS t
                    EXCEPT 
                    SELECT t."name", st."name"
                    FROM lab.subtask AS st
                        INNER JOIN lab.task AS t
                            ON t.task_id = st.task_id
                    WHERE t.course_id = course_id
               )
                BEGIN
                    RAISERROR ('Some subtasks aren''t found', 16, 1);
                END
                
                --=============================
                --Merge data
                --=============================
                MERGE lab.subtask_log AS tgt
                USING (SELECT stl.subtask_log_id
                            , st.subtask_id
                            , tmp.score
                            , isnull(tmp."name"_conv,0) + isnull(tmp.Redability,0) + isnull(tmp.sarg,0) + isnull(tmp.schema_name,0) + isnull(tmp.aliases,0) + isnull(tmp.determ_sorting,0) AS accuracy
                            , tmp.ontime
                            , tmp.extra
                            , tmp.comment
                        FROM temp_source AS tmp 
                            INNER JOIN lab.task AS t
                                ON t."name" = tmp.task_name
                                    AND t.course_id = course_id                                   
                            INNER JOIN lab.subtask AS st
                                ON st.task_id = t.task_id
                                    AND st."name" = tmp.subtask_name 
                            LEFT JOIN lab.subtask_log AS stl
                                ON stl.subtask_id = st.subtask_id
                                    AND stl.student_id = student_id
                     ) as src
                ON tgt.subtask_log_id = src.subtask_log_id
                WHEN MATCHED 
                    THEN UPDATE SET tgt.reviewer_id      = reviewer_id
                                  , tgt.score           = src.score
                                  , tgt.accuracy        = src.accuracy
                                  , tgt.ontime          = src.ontime
                                  , tgt.extra           = src.extra
                                  , tgt.comment         = src.comment
                                  , tgt.sys_changed_at  = CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE
                    
                WHEN NOT MATCHED 
                    THEN INSERT (     
                                      subtask_id
                                    , student_id
                                    , reviewer_id
                                    , score
                                    , ontime
                                    , accuracy
                                    , extra
                                    , comment
                               ) 
                    VALUES (
                                     src.subtask_id
                                    , student_id
                                    , reviewer_id
                                    , src.score
                                    , src.ontime
                                    , src.accuracy
                                    , src.extra
                                    , src.comment
                          )                
                OUTPUT inserted.subtask_log_id, $ACTION
                INTO #TEMP_RESULT;
               
               --=============================
               --Output
               --=============================
               SELECT tr.subtask_log_id
                    , tr.Action
                    , reviewer_nameFromJson     AS reviewer_name
                    , student_nameFromJson      AS student_name
                    , t."name"                  AS task_name
                    , st."name"                    AS subtask_name
                    , stl.score
                    , stl.ontime
                    , stl.accuracy
                    , stl.extra
                    , stl.total_score
                    , stl.comment
               FROM #TEMP_RESULT tr
                   INNER JOIN lab.subtask_log AS stl
                        ON stl.subtask_log_id = tr.subtask_log_id
                   INNER JOIN lab.subtask AS st
                        ON st.subtask_id = stl.subtask_id
                   INNER JOIN lab.task AS t
                        ON t.task_id = st.task_id
               ORDER BY subtask_name;               
               DROP TABLE #TEMP_RESULT;

    END
ELSE 
    BEGIN
        RAISERROR ('Invalid JSO', 16, 1);
    END
END