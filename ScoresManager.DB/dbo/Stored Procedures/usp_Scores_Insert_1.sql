

-- =============================================
-- Author:      Boykov_Sergey
-- Create Date: 2020-12-29
-- Description: Update the table dbo.SubTaskLog. Load Scores from JSON to the table.
/* Format JSON: N'{"CourseName": "MSBI.DEV.S21", "ReviewerName": "Sergei Boikov", "StudentName": "Anna Sedina", "TaskName": "MSBI.DEV.Task.05", 
                    "Subtasks": [ 
                                    {"SubTaskName": "Subtask.05.08", "Mark": 5, "NameConv": 0, "Redability": 1, "Sarg": 0, "SchemaName": 1, "Aliases": 1, "DetermSorting": 0, "OnTime": 1, "Extra": 1, "Comment": ""}
                                   ,{"SubTaskName": "Subtask.05.09", "Mark": 5, "NameConv": 0, "Redability": 1, "Sarg": 0, "SchemaName": 1, "Aliases": 1, "DetermSorting": 0, "OnTime": 1, "Extra": 1, "Comment": ""}
                                ]
                  }' */
/* Example: EXEC [mentor].[usp_Scores_Insert] N'{"CourseName": "MSBI.DEV.S19", "ReviewerName": "Sergei Boikov", "StudentName": "Anna Sedina", "TaskName": "MSBI.DEV.Task.05", 
                                             "Subtasks": [ 
                                                             {"SubTaskName": "Subtask.05.08", "Mark": 5, "NameConv": 0, "Redability": 1, "Sarg": 0, "SchemaName": 1, "Aliases": 1, "DetermSorting": 0, "OnTime": 1, "Extra": 1, "Comment": ""}
                                                            ,{"SubTaskName": "Subtask.05.09", "Mark": 5, "NameConv": 0, "Redability": 1, "Sarg": 0, "SchemaName": 1, "Aliases": 1, "DetermSorting": 0, "OnTime": 1, "Extra": 1, "Comment": ""}
                                                         ]
                                             }' */
-- =============================================
CREATE PROCEDURE [dbo].[usp_Scores_Insert]
(
    @json NVARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
    DECLARE @ReviewerNameFromJson   NVARCHAR(100),
            @StudentNameFromJson    NVARCHAR(100),
            @CourseNameFromJson     NVARCHAR(250),
            @ReviewerID             INT,
            @StudentID              INT,
            @CourseID               INT

IF ISJSON(@json) > 0
	BEGIN
        BEGIN TRY
	        BEGIN TRANSACTION
                DROP TABLE IF EXISTS #TEMP_SOURCE;
                DROP TABLE IF EXISTS #TEMP_RESULT;
                CREATE TABLE #TEMP_RESULT (SubTaskLogId INT, [Action] nvarchar(10));
                
                --=============================
                --Read data from JSON
                --=============================
			    SELECT *
			    INTO #TEMP_SOURCE
				    FROM OPENJSON(@json)
                    WITH (
                             CourseName     NVARCHAR(250)   '$.CourseName'
                            ,ReviewerName   NVARCHAR(100)   '$.ReviewerName'
                            ,StudentName    NVARCHAR(100)   '$.StudentName'
                            ,TaskName       NVARCHAR(250)   '$.TaskName'
                    )
                    CROSS APPLY OPENJSON(@json, N'$.Subtasks')
                    WITH (
                             SubTaskName    NVARCHAR(250)   '$.SubTaskName'
                            ,Score          NUMERIC(8,2)    '$.Mark'
                            ,NameConv       NUMERIC(8,2)    '$.NameConv'
                            ,Redability     NUMERIC(8,2)    '$.Redability'
                            ,Sarg           NUMERIC(8,2)    '$.Sarg'
                            ,SchemaName     NUMERIC(8,2)    '$.SchemaName'
                            ,Aliases        NUMERIC(8,2)    '$.Aliases'
                            ,DetermSorting  NUMERIC(8,2)    '$.DetermSorting'
                            ,OnTime         NUMERIC(8,2)    '$.OnTime'
                            ,Extra          NUMERIC(8,2)    '$.Extra'
                            ,Comment        NVARCHAR(250)   '$.Comment'
                    );

				--=============================
                --Get Course info
                --=============================
				SELECT TOP 1 @CourseNameFromJson = t.CourseName 
                FROM [#TEMP_SOURCE] AS t;

                SELECT TOP 1 @CourseID = c.[CourseId]
                FROM [dbo].[Course] AS c
                WHERE [c].[Name] = @CourseNameFromJson
                
				--=============================
                --Check ReviewerName
                --=============================
                SELECT TOP 1 @ReviewerNameFromJson = t.ReviewerName 
                FROM [#TEMP_SOURCE] AS t;
                
                SELECT TOP 1 @ReviewerID = u.[UserId] 
                FROM [dbo].[User] AS u 
				INNER JOIN [dbo].[CourseStaff] sc ON sc.[UserId] = u.[UserId]
				INNER JOIN [dbo].[UserType] ut ON ut.[UserTypeId] = sc.[UserTypeId]
                WHERE ut.[Name] = 'Mentor'
					AND sc.[CourseId] = @CourseID
                    AND u.[Name] = @ReviewerNameFromJson;  

                IF (@ReviewerID IS NULL)
                BEGIN
                    RAISERROR (N'Reviewer isn''t found', 16, 1);
                END

                --=============================
                --Check StudentName
                --=============================
                SELECT TOP 1 @StudentNameFromJson = t.StudentName 
                FROM [#TEMP_SOURCE] AS t;

                SELECT TOP 1 @StudentID = u.[UserId] 
                FROM [dbo].[User] AS u 
				INNER JOIN [dbo].[CourseStaff] sc ON sc.[UserId] = u.[UserId]
				INNER JOIN [dbo].[UserType] ut ON ut.[UserTypeId] = sc.[UserTypeId]
                WHERE ut.[Name] = 'Student'
					AND sc.[CourseId] = @CourseID
                    AND u.[Name] = @StudentNameFromJson;

                IF (@StudentID IS NULL)
                BEGIN
                    RAISERROR (N'Student isn''t found', 16, 1);
                END

                --=============================
                --Check SubTask
                --=============================
                

                IF EXISTS (
                    SELECT t.TaskName, t.SubTaskName 
                    FROM #TEMP_SOURCE AS t
                    EXCEPT 
                    SELECT t.[Name], st.[Name]
                    FROM [dbo].[SubTask] AS st
                        INNER JOIN [dbo].[Task] AS t
                            ON t.[TaskId] = [st].[TaskId]
                    WHERE t.[CourseId] = @CourseID
                )
                BEGIN
                    RAISERROR (N'Some SubTasks aren''t found', 16, 1);
                END
                
                --=============================
                --Merge data
                --=============================
                MERGE [dbo].[SubTaskLog] AS tgt
                USING (SELECT stl.SubTaskLogId
                            , st.SubTaskId
                            , tmp.Score
                            , isnull(tmp.NameConv,0) + isnull(tmp.Redability,0) + isnull(tmp.Sarg,0) + isnull(tmp.SchemaName,0) + isnull(tmp.Aliases,0) + isnull(tmp.DetermSorting,0) AS Accuracy
                            , isnull(tmp.OnTime,0) AS OnTime
                            , isnull(tmp.Extra,0) AS Extra
                            , tmp.Comment
                        FROM #TEMP_SOURCE AS tmp 
                            INNER JOIN [dbo].[Task] AS t
                                ON t.[Name] = tmp.TaskName
                                    AND t.[CourseId] = @CourseID                                   
                            INNER JOIN [dbo].[SubTask] AS st
                                ON st.[TaskId] = [t].[TaskId]
                                    AND st.[Name] = tmp.SubTaskName 
                            LEFT JOIN [dbo].[SubTaskLog] AS stl
                                ON stl.[SubTaskId] = [st].[SubTaskId]
                                    AND stl.[StudentId] = @StudentID
                      ) as src
                ON tgt.SubTaskLogId = src.SubTaskLogId
                WHEN MATCHED 
                    THEN UPDATE SET tgt.ReviewerId      = @ReviewerID
                                  , tgt.Score           = src.Score
                                  , tgt.Accuracy        = src.Accuracy
                                  , tgt.OnTime          = src.OnTime
                                  , tgt.Extra           = src.Extra
                                  , tgt.Comment         = src.Comment
                                  , tgt.[sysChangedAt]  = GETUTCDATE()
                    
                WHEN NOT MATCHED 
                    THEN INSERT (     
                                      SubTaskId
                                    , StudentId
                                    , ReviewerId
                                    , Score
                                    , OnTime
                                    , Accuracy
                                    , Extra
                                    , Comment
                                ) 
                    VALUES (
                                     src.SubTaskId
                                    , @StudentId
                                    , @ReviewerId
                                    , src.Score
                                    , src.OnTime
                                    , src.Accuracy
                                    , src.Extra
                                    , src.Comment
                           )                
                OUTPUT Inserted.SubTaskLogId, $ACTION
                INTO #TEMP_RESULT;
               
               --=============================
               --Output
               --=============================
               SELECT tr.[SubTaskLogId]
                    , tr.[Action]
                    , @ReviewerNameFromJson     AS [ReviewerName]
                    , @StudentNameFromJson      AS [StudentName]
                    , t.[Name]                  AS [TaskName]
                    , st.[NAME]					AS [SubTaskName]
                    , stl.[Score]
                    , stl.[OnTime]
                    , stl.[Accuracy]
                    , stl.[Extra]
                    , stl.[TotalScore]
                    , stl.[Comment]
               FROM #TEMP_RESULT tr
                   INNER JOIN [dbo].[SubTaskLog] AS stl
                        ON stl.SubTaskLogId = tr.SubTaskLogId
                   INNER JOIN [dbo].[SubTask] AS st
                        ON st.[SubTaskId] = stl.[SubTaskId]
                   INNER JOIN [dbo].[Task] AS t
                        ON t.[TaskId] = st.[TaskId]
               ORDER BY [SubTaskName];

               DROP TABLE #TEMP_SOURCE;
               DROP TABLE #TEMP_RESULT;
            COMMIT TRANSACTION
        END TRY
        BEGIN CATCH
	            IF @@TRANCOUNT > 0 
		            ROLLBACK TRANSACTION;
	            THROW;
        END CATCH;
    END
ELSE 
	BEGIN
		RAISERROR (N'Invalid JSON', 16, 1);
	END
END