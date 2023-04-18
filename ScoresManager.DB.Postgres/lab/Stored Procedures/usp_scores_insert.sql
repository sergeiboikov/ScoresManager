-- =============================================
-- Author:      Boykov_Sergey
-- Create Date: 2023-04-17
-- Description: Update the table lab.subtask_log. Load scores from JSON to the table.
/* Example: CALL mentor.usp_scores_insert ('{"course_name": "BI.RD.LAB.2023.1", "reviewer_name": "Sergei Boikov", "student_name": "Anna Sedina", "task_name": "MSBI.DEV.task.05", 
                                             "subtasks":  
                                                             [{"subtask_name": "subtask.05.08", "score": 5, "name_conv": 0, "readability": 1, "sarg": 0, "schema_name": 1, "aliases": 1, "determ_sorting": 0, "ontime": 1, "extra": 1, "comment": ""}
                                                            ,{"subtask_name": "subtask.05.09", "score": 5, "name_conv": 0, "readability": 1, "sarg": 0, "schema_name": 1, "aliases": 1, "determ_sorting": 0, "ontime": 1, "extra": 1, "comment": ""}]
                                                         
                                             }); */
-- =============================================

CREATE OR REPLACE PROCEDURE mentor.usp_scores_insert(jsn JSON)
LANGUAGE plpgsql
AS $$
DECLARE 
    reviewer_name_from_json VARCHAR(100) := '';
    student_name_from_json  VARCHAR(100) := '';
    course_name_from_json   VARCHAR(250) := '';
    tmp_reviewer_id         INT := -1;
    tmp_student_id          INT := -1;
    tmp_course_id           INT := -1;
BEGIN
/*========================================================================================================================
 * Insert temp data from JSON
========================================================================================================================*/
    CREATE TEMPORARY TABLE temp_source (
        course_name     VARCHAR(250),
        reviewer_name   VARCHAR(100),
        student_name    VARCHAR(100),
        task_name       VARCHAR(250),
        subtask_name    VARCHAR(250),
        score           NUMERIC(8,2),
        name_conv       NUMERIC(8,2),
        readability     NUMERIC(8,2),
        sarg            NUMERIC(8,2),
        schema_name     NUMERIC(8,2),
        aliases         NUMERIC(8,2),
        determ_sorting  NUMERIC(8,2),
        ontime          NUMERIC(8,2),
        extra           NUMERIC(8,2),
        comment         VARCHAR(500)
    ) ON COMMIT DROP;

    INSERT INTO temp_source(
        course_name,
        reviewer_name,
        student_name,
        task_name,
        subtask_name,
        score,
        name_conv,
        readability,
        sarg,
        schema_name,
        aliases,
        determ_sorting,
        ontime,
        extra,
        comment      
    )
    SELECT 
        j.course_name,
        j.reviewer_name,
        j.student_name,
        j.task_name,
        t.subtask_name,
        t.score,
        t.name_conv,
        t.readability,
        t.sarg,
        t.schema_name,
        t.aliases,
        t.determ_sorting,
        t.ontime,
        t.extra,
        t."comment"
    FROM json_to_record(jsn) AS j(
        course_name     VARCHAR(250),
        reviewer_name   VARCHAR(100),
        student_name    VARCHAR(100),
        task_name       VARCHAR(250)
    )
    CROSS JOIN LATERAL(
        SELECT *
        FROM json_to_recordset(
                json_extract_path(jsn, 'subtasks')
                ) AS j(
                    subtask_name    VARCHAR(250),
                    score           NUMERIC(8,2),
                    name_conv       NUMERIC(8,2),
                    readability     NUMERIC(8,2),
                    sarg            NUMERIC(8,2),
                    schema_name     NUMERIC(8,2),
                    aliases         NUMERIC(8,2),
                    determ_sorting  NUMERIC(8,2),
                    ontime          NUMERIC(8,2),
                    extra           NUMERIC(8,2),
                    "comment"       VARCHAR(250)
        )
    ) AS t;

/*========================================================================================================================
 * Get course info
========================================================================================================================*/
    SELECT t.course_name 
    INTO course_name_from_json
    FROM temp_source AS t
    LIMIT 1;                
    
    SELECT c.course_id
    INTO tmp_course_id
    FROM lab.course AS c
    WHERE c."name" = course_name_from_json
    LIMIT 1;

/*========================================================================================================================
 * Check reviewer_name
========================================================================================================================*/
    SELECT t.reviewer_name 
    INTO reviewer_name_from_json
    FROM temp_source AS t
    LIMIT 1;
    
    SELECT u.user_id 
    INTO tmp_reviewer_id
    FROM lab.user AS u 
    INNER JOIN lab.course_staff AS sc 
        ON sc.user_id = u.user_id
    INNER JOIN lab.user_type AS ut 
        ON ut.user_type_id = sc.user_type_id
    WHERE ut."name" = 'mentor'
        AND sc.course_id = tmp_course_id
        AND u."name" = reviewer_name_from_json
    LIMIT 1;
    
    IF (tmp_reviewer_id IS NULL)
    THEN
        RAISE EXCEPTION 'Reviewer: ''%'' isn''t found', reviewer_name_from_json;
    END IF;

/*========================================================================================================================
 * Check student_name
========================================================================================================================*/
    SELECT t.student_name 
    INTO student_name_from_json
    FROM temp_source AS t
    LIMIT 1;                
    
    SELECT u.user_id
    INTO tmp_student_id
    FROM lab."user" AS u 
    INNER JOIN lab.course_staff AS sc 
        ON sc.user_id = u.user_id
    INNER JOIN lab.user_type AS ut 
        ON ut.user_type_id = sc.user_type_id
    WHERE ut."name" = 'student'
        AND sc.course_id = tmp_course_id
        AND u."name" = student_name_from_json;                
        
    IF (tmp_student_id IS NULL)
    THEN
        RAISE EXCEPTION 'Student: ''%'' isn''t found', student_name_from_json;
    END IF;

/*========================================================================================================================
 * Check subtask
========================================================================================================================*/
    IF EXISTS (
        SELECT t.task_name, t.subtask_name 
        FROM temp_source AS t
        EXCEPT 
        SELECT t."name", st."name"
        FROM lab.subtask AS st
        INNER JOIN lab.task AS t
            ON t.task_id = st.task_id
        WHERE t.course_id = tmp_course_id
    )
    THEN
        RAISE EXCEPTION 'Some subtasks aren''t found';
    END IF;
    
/*========================================================================================================================
 * Merge data
========================================================================================================================*/
    MERGE INTO lab.subtask_log AS tgt
    USING (
        SELECT 
            stl.subtask_log_id,
            st.subtask_id,
            tmp.score,
            isnull(tmp.name_conv,0) + isnull(tmp.readability,0) + isnull(tmp.sarg,0) + isnull(tmp.schema_name,0) + isnull(tmp.aliases,0) + isnull(tmp.determ_sorting,0) AS accuracy,
            tmp.ontime,
            tmp.extra,
            tmp.comment
        FROM temp_source AS tmp 
                INNER JOIN lab.task AS t
                    ON t."name" = tmp.task_name
                        AND t.course_id = tmp_course_id                                   
                INNER JOIN lab.subtask AS st
                    ON st.task_id = t.task_id
                        AND st."name" = tmp.subtask_name 
                LEFT JOIN lab.subtask_log AS stl
                    ON stl.subtask_id = st.subtask_id
                        AND stl.student_id = tmp_student_id
    ) as src
        ON tgt.subtask_log_id = src.subtask_log_id
    WHEN MATCHED THEN 
        UPDATE SET 
            reviewer_id     = tmp_reviewer_id,
            score           = src.score,
            accuracy        = src.accuracy,
            ontime          = src.ontime,
            extra           = src.extra,
            "comment"       = src."comment",
            sys_changed_at  = CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE
    WHEN NOT MATCHED THEN 
        INSERT (
            subtask_log_id,
            subtask_id,
            student_id,
            reviewer_id,
            score,
            ontime,
            accuracy,
            extra,
            "comment"
        ) 
    VALUES (
        nextval('lab.sq_dbo_subtask_log_subtask_log_id'),
        rc.subtask_id,
        tmp_student_id,
        tmp_reviewer_id,
        src.score,
        src.ontime,
        src.accuracy,
        src.extra,
        src."comment"
    );
END; $$