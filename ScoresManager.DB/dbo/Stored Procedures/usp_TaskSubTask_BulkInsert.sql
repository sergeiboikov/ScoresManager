




-- =============================================
-- Author:			Sergei Boikov
-- Create Date:		2021-07-26
-- Description: Load information about Task and Subtasks from JSON
-- Format JSON: N'[{"CourseName": "BI.Lab.Cross.2021", "TaskName": "Intro.Test", "TaskDescription": "Initial test for mentees", "TaskTopic": "Module #1: Intro", "SubTaskName": "Test", "SubTaskDescription": "Test", "SubTaskTopic": "DB Basics"}]' 
-- Example: EXEC [dbo].[usp_TaskSubTask_BulkInsert] @json = N'[{"CourseName": "BI.Lab.Cross.2021", "TaskName": "Intro.Test", "TaskDescription": "Initial test for mentees", "TaskTopic": "Module #1: Intro", "SubTaskName": "Test", "SubTaskDescription": "Test", "SubTaskTopic": "DB Basics"}]' 
-- =============================================

CREATE PROCEDURE [dbo].[usp_TaskSubTask_BulkInsert]
(
    @json NVARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE		@NoMatchedTaskTopicFromJson			NVARCHAR(250),
				@NoMatchedCourseNameFromJson		NVARCHAR(250),
				@NoMatchedSubTaskTopicFromJson		NVARCHAR(250)

IF ISJSON(@json) > 0
	BEGIN
        BEGIN TRY
	        BEGIN TRANSACTION
                DROP TABLE IF EXISTS #TEMP_SOURCE;

			    SELECT *
			    INTO #TEMP_SOURCE
				FROM OPENJSON(@json)
                WITH (
                         CourseName			NVARCHAR(250)   '$.CourseName'
                        ,TaskName			NVARCHAR(100)   '$.TaskName'
                        ,TaskDescription    NVARCHAR(100)   '$.TaskDescription'
                        ,TaskTopic			NVARCHAR(250)   '$.TaskTopic'
						,SubTaskName		NVARCHAR(250)   '$.SubTaskName'
                        ,SubTaskDescription NVARCHAR(250)   '$.SubTaskDescription'
                        ,SubTaskTopic       NVARCHAR(250)   '$.SubTaskTopic'
                ) AS RootL;

				-- Check Course names
				SELECT TOP 1 @NoMatchedCourseNameFromJson = tmp.[CourseName]
				FROM #TEMP_SOURCE AS tmp
				LEFT JOIN [dbo].[Course] AS c ON TRIM(UPPER(c.[Name])) = TRIM(UPPER(tmp.[CourseName]))
				WHERE tmp.[CourseName] IS NOT NULL
					AND c.[CourseId] IS NULL

				IF (@NoMatchedCourseNameFromJson IS NOT NULL)
                BEGIN
					RAISERROR (N'Course with name: ''%s'' isn''t found', 16, 1, @NoMatchedCourseNameFromJson);
                END

				-- TaskTopic
				MERGE INTO [dbo].[Topic] tgt
				USING (SELECT DISTINCT TaskTopic AS [Topic], 1 AS IsTopicForTasks
					   FROM #TEMP_SOURCE) src
					ON TRIM(UPPER(tgt.[Name])) = TRIM(UPPER(src.[Topic]))
				WHEN MATCHED THEN
				UPDATE SET
					 tgt.[IsTopicForTasks] = src.[IsTopicForTasks]
					,tgt.[sysChangedAt] = getutcdate()
				WHEN NOT MATCHED THEN
				INSERT (
					 [Name]
					,[IsTopicForTasks]
				) VALUES
				(
					 src.[Topic]
					,src.[IsTopicForTasks]
				);

				-- SubTaskTopic
				MERGE INTO [dbo].[Topic] tgt
				USING (SELECT DISTINCT SubTaskTopic AS [Topic], 1 AS IsTopicForSubTasks 
					   FROM #TEMP_SOURCE) src
					ON TRIM(UPPER(tgt.[Name])) = TRIM(UPPER(src.[Topic]))
				WHEN MATCHED THEN
				UPDATE SET
					 tgt.[IsTopicForSubTasks] = src.[IsTopicForSubTasks]
					,tgt.[sysChangedAt] = getutcdate()
				WHEN NOT MATCHED THEN
				INSERT (
					 [Name]
					,[IsTopicForSubTasks]
				) VALUES
				(
					 src.[Topic]
					,src.[IsTopicForSubTasks]
				);

				--Task
				MERGE INTO [dbo].[Task] tgt
				USING (	SELECT DISTINCT  CourseId
										,tmp.TaskName
										,tmp.TaskDescription
										,tt.TopicId
						FROM #TEMP_SOURCE AS tmp
						INNER JOIN [dbo].[Course] AS c ON TRIM(UPPER(c.[Name])) = TRIM(UPPER(tmp.[CourseName]))
						INNER JOIN [dbo].[Topic] AS tt ON TRIM(UPPER(tt.[Name])) = TRIM(UPPER(tmp.[TaskTopic]))) src
					ON (tgt.[Name] = src.[TaskName]
						AND tgt.[CourseId] = src.[CourseId])
				WHEN MATCHED THEN
				UPDATE SET
					 tgt.[Description] = src.[TaskDescription]
					,tgt.[TopicId] = src.[TopicId]
					,tgt.[sysChangedAt] = getutcdate()
				WHEN NOT MATCHED THEN
				INSERT (
					 [Name]
					,[Description]
					,[TopicId]
					,[CourseId]
				) VALUES
				(
					 src.[TaskName]
					,src.[TaskDescription]
					,src.[TopicId]
					,src.[CourseId]
				);

				-- SubTask
				MERGE INTO [dbo].[SubTask] tgt
				USING (
					SELECT t.[TaskId]
						  ,tmp.[SubTaskName]
						  ,tmp.[SubTaskDescription]
						  ,stt.[TopicId] 
					FROM #TEMP_SOURCE AS tmp
					INNER JOIN [dbo].[Topic] AS stt ON TRIM(UPPER(stt.[Name])) = TRIM(UPPER(tmp.[SubTaskTopic]))
					INNER JOIN [dbo].[Task] AS t ON TRIM(UPPER(t.[Name])) = TRIM(UPPER(tmp.[TaskName]))
					WHERE tmp.[SubTaskName] IS NOT NULL) src ON (src.[SubTaskName] = tgt.[Name] 
						AND src.[TaskId] = tgt.[TaskId])
				WHEN MATCHED THEN
				UPDATE SET
					 tgt.[Description] = src.[SubTaskDescription]
					,tgt.[TopicId] = src.[TopicId]
					,tgt.[sysChangedAt] = getutcdate()
				WHEN NOT MATCHED THEN
				INSERT (
					 [TaskId]
					,[Name]
					,[Description]
					,[TopicId]
				) VALUES
				(
					 src.[TaskId]
					,src.[SubTaskName]
					,src.[SubTaskDescription]
					,src.[TopicId]
				);
				
				DROP TABLE #TEMP_SOURCE;
            COMMIT TRANSACTION
        END TRY
        BEGIN CATCH
	            IF @@TRANCOUNT > 0 
		            ROLLBACK TRANSACTION;
	            THROW;
        END CATCH;
    END
END