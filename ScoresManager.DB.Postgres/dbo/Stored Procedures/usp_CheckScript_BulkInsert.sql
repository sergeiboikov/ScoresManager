
-- =============================================
-- Author:            Sergei Boikov
-- Create Date:        2023-04-08
-- Description: Load information for CheckScript from JSON
-- CALL dbo.usp_CheckScript_BulkInsert('{"CourseName": "BI.Lab.Cross.2021","TaskName": "ASQL.Homework_02","SubTaskName": "Subtask.01","CheckScriptText": "SELECT 1","CheckScriptDesc": "Check script for Subtask.01","CheckScriptTypeName": "SQL","ConnectionString": "Connection string","ConnectionTypeName": "ODBC"}');
-- =============================================
CREATE OR REPLACE PROCEDURE dbo.usp_CheckScript_BulkInsert(jsn JSON)
LANGUAGE plpgsql
AS $$
DECLARE     
    NoMatchedCourseNameFromJson             VARCHAR(250) := '';
    NoMatchedTaskNameFromJson               VARCHAR(250) := '';
    NoMatchedSubTaskNameFromJson            VARCHAR(250) := '';
    NoMatchedCheckScriptTypeNameFromJson    VARCHAR(250) := '';
    NoMatchedConnectionStringFromJson       VARCHAR(250) := '';
    NoMatchedConnectionTypeNameFromJson     VARCHAR(250) := '';
BEGIN
    CREATE TEMPORARY TABLE TEMP_SOURCE (
        CourseName          VARCHAR(250),
        TaskName            VARCHAR(100),
        SubTaskName         VARCHAR(250),
        CheckScriptText     TEXT,
        CheckScriptDesc     TEXT,
        CheckScriptTypeName VARCHAR(250),
        ConnectionString    VARCHAR(250),
        ConnectionTypeName  VARCHAR(250)
    ) ON COMMIT DROP;
    
    SELECT 
        j->> 'CourseName'           AS CourseName,
        j->> 'TaskName'             AS TaskName,
        j->> 'SubTaskName'          AS SubTaskName,
        j->> 'CheckScriptText'      AS CheckScriptText,
        j->> 'CheckScriptDesc'      AS CheckScriptDesc,
        j->> 'CheckScriptTypeName'  AS CheckScriptTypeName,
        j->> 'ConnectionString'     AS ConnectionString,
        j->> 'ConnectionTypeName'   AS ConnectionTypeName
    FROM json_array_elements(jsn) AS j;
    
    -- Check Course names
    SELECT NoMatchedCourseNameFromJson = tmp.CourseName
    FROM TEMP_SOURCE AS tmp
        LEFT JOIN dbo.Course AS c 
            ON TRIM(UPPER(c.Name)) = TRIM(UPPER(tmp.CourseName))
    WHERE tmp.CourseName IS NOT NULL
        AND c.CourseId IS NULL
    LIMIT 1;
    IF NoMatchedCourseNameFromJson IS NOT NULL
    THEN 
        BEGIN
            RAISE EXCEPTION 'Course with name: ''%s'' isn''t found', NoMatchedCourseNameFromJson;
        END;
    END IF;
    
    -- Check TaskName
    SELECT NoMatchedTaskNameFromJson = tmp.TaskName
    FROM TEMP_SOURCE AS tmp
        LEFT JOIN dbo.Task AS t 
            ON TRIM(UPPER(t.Name)) = TRIM(UPPER(tmp.TaskName))
    WHERE tmp.TaskName IS NOT NULL
        AND t.TaskId IS NULL
    LIMIT 1;
    IF NoMatchedTaskNameFromJson IS NOT NULL
    THEN 
        BEGIN
            RAISE EXCEPTION 'Task with name: ''%s'' isn''t found', NoMatchedTaskNameFromJson;
        END;
    END IF;
    
    -- Check SubTaskName
    SELECT NoMatchedSubTaskNameFromJson = tmp.SubTaskName
    FROM TEMP_SOURCE AS tmp
        LEFT JOIN dbo.SubTask AS t 
            ON TRIM(UPPER(t.Name)) = TRIM(UPPER(tmp.SubTaskName))
    WHERE tmp.SubTaskName IS NOT NULL
        AND t.SubTaskId IS NULL
    LIMIT 1;
    IF NoMatchedSubTaskNameFromJson IS NOT NULL
    THEN 
        BEGIN
            RAISE EXCEPTION 'SubTask with name: ''%s'' isn''t found', NoMatchedSubTaskNameFromJson;
        END;
    END IF;
    
    -- Check CheckScriptTypeName
    SELECT NoMatchedCheckScriptTypeNameFromJson = tmp.CheckScriptTypeName
    FROM TEMP_SOURCE AS tmp
        LEFT JOIN dbo.CheckScriptType AS t 
            ON TRIM(UPPER(t.Name)) = TRIM(UPPER(tmp.CheckScriptTypeName))
    WHERE tmp.CheckScriptTypeName IS NOT NULL
        AND t.CheckScriptTypeId IS NULL
    LIMIT 1;
    IF NoMatchedCheckScriptTypeNameFromJson IS NOT NULL
    THEN 
        BEGIN
            RAISE EXCEPTION 'SubTask with name: ''%s'' isn''t found', NoMatchedCheckScriptTypeNameFromJson;
        END;
    END IF;
    
    -- Check ConnectionTypeName
    SELECT NoMatchedConnectionTypeNameFromJson = tmp.ConnectionTypeName
    FROM TEMP_SOURCE AS tmp
        LEFT JOIN dbo.ConnectionType AS t 
            ON TRIM(UPPER(t.Name)) = TRIM(UPPER(tmp.ConnectionTypeName))
    WHERE tmp.ConnectionTypeName IS NOT NULL
        AND t.ConnectionTypeId IS NULL
    LIMIT 1;
    IF NoMatchedConnectionTypeNameFromJson IS NOT NULL
    THEN 
        BEGIN
            RAISE EXCEPTION 'ConnectionType with name: ''%s'' isn''t found', NoMatchedConnectionTypeNameFromJson;
        END;
    END IF;
    
    -- Check ConnectionString
    MERGE INTO dbo.Connection tgt
    USING (
            SELECT DISTINCT tmp.ConnectionString
                            ,CT.ConnectionTypeId
            FROM TEMP_SOURCE AS tmp
                LEFT  JOIN  dbo.Connection AS C 
                    ON TRIM(UPPER(C.ConnectionString)) = TRIM(UPPER(tmp.ConnectionString))
                INNER JOIN dbo.ConnectionType AS CT 
                    ON TRIM(UPPER(CT.Name)) = TRIM(UPPER(tmp.ConnectionTypeName))
            WHERE tmp.ConnectionString IS NOT NULL
                AND C.ConnectionId IS NULL
    ) src 
        ON TRIM(UPPER(src.ConnectionString)) = TRIM(UPPER(tgt.ConnectionString))
    WHEN NOT MATCHED 
    THEN INSERT (ConnectionString, ConnectionTypeId)
         VALUES (src.ConnectionString, src.ConnectionTypeId);
    
    -- CheckScript insert 
    MERGE INTO dbo.CheckScript tgt
    USING (
        SELECT DISTINCT  tmp.CheckScriptText
                        ,tmp.CheckScriptDesc
                        ,  C.ConnectionId
                        ,CST.CheckScriptTypeId
        FROM TEMP_SOURCE AS tmp
        INNER JOIN dbo.Connection AS C 
            ON TRIM(UPPER(C.ConnectionString)) = TRIM(UPPER(tmp.ConnectionString))
        INNER JOIN dbo.CheckScriptType AS CST 
            ON TRIM(UPPER(CST.Name)) = TRIM(UPPER(tmp.CheckScriptTypeName))
        INNER JOIN dbo.ConnectionType AS CT 
            ON TRIM(UPPER(CT.Name)) = TRIM(UPPER(tmp.ConnectionTypeName))
            AND CT.ConnectionTypeId = C.ConnectionTypeId) src 
                ON (TRIM(UPPER(src.CheckScriptText)) = TRIM(UPPER(tgt.Text)))
    WHEN MATCHED THEN
    UPDATE SET
         tgt.Description        = src.CheckScriptDesc
        ,tgt.ConnectionId       = src.ConnectionId
        ,tgt.CheckScriptTypeId= src.CheckScriptTypeId
        ,tgt.sysChangedAt       = CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE
    WHEN NOT MATCHED THEN
    INSERT (
         Text
        ,Description
        ,ConnectionId
        ,CheckScriptTypeId
    ) VALUES
    (
         src.CheckScriptText
        ,src.CheckScriptDesc
        ,src.ConnectionId
        ,src.CheckScriptTypeId
    );
    
    -- SubTask checkScriptId update
    UPDATE ST
    SET  ST.CheckScriptId = CS.CheckScriptId
        ,ST.sysChangedAt = CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE
    FROM dbo.SubTask ST
        INNER JOIN TEMP_SOURCE tmp 
            ON TRIM(UPPER(ST.Name)) = TRIM(UPPER(tmp.SubTaskName)) 
        INNER JOIN dbo.CheckScript CS 
            ON TRIM(UPPER(CS.Text)) = TRIM(UPPER(tmp.CheckScriptText))
        INNER JOIN dbo.Task T 
            ON TRIM(UPPER(T.Name)) = TRIM(UPPER(tmp.TaskName))
                AND T.TaskId = ST.TaskId
        INNER JOIN dbo.Course C 
            ON TRIM(UPPER(C.Name)) = TRIM(UPPER(tmp.CourseName))
                AND C.CourseId= T.CourseId;
    COMMIT;
    EXCEPTION WHEN OTHERS
        THEN ROLLBACK;
END; $$