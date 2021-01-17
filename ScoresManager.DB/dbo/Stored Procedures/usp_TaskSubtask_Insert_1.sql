



-- =============================================
-- Author:			Sergei Boikov
-- Create Date:		2020-12-28
-- Description: Load information about Task and Subtasks from JSON
/* Format JSON: N'{"CourseName": "MSBI.DEV.S20", "TaskName": "MSBI.DEV.Task.164", "TaskDescription": "SSIS.Part.5", "TaskTopic": "SSIS.Part.5", 
				  "Subtasks": [ 
								 {"SubTaskName": "Subtask.164.01", "SubTaskDescription": "SSIS project development", "SubTaskTopic": "SSIS", "Bonuses":["Readability", "SARG"]} 
								,{"SubTaskName": "Subtask.164.02", "SubTaskDescription": "SSIS project deployment", "SubTaskTopic": "SSIS", "Bonuses":["Readability", "SARG"]}			
							  ]
				  }' 
*/
/*	Example 1. Add Task and Subtasks: EXEC [dbo].[usp_TaskSubtask_Insert] @json = N'{"CourseName": "MSBI.DEV.S20", "TaskName": "MSBI.DEV.Task.164", "TaskDescription": "SSIS.Part.5", "TaskTopic": "SSIS.Part.5", 
														  "Subtasks": [ 
																		 {"SubTaskName": "Subtask.164.01", "SubTaskDescription": "SSIS project development", "SubTaskTopic": "SSIS", "Bonuses":["Readability", "SARG"]} 
																		,{"SubTaskName": "Subtask.164.02", "SubTaskDescription": "SSIS project deployment", "SubTaskTopic": "SSIS", "Bonuses":["Readability", "SARG"]}			
																	  ]
														  }' 
														  
	Example 2. Add Task without Subtasks: EXEC [dbo].[usp_TaskSubtask_Insert] @json = N'{"CourseName": "MSBI.DEV.S20", "TaskName": "MSBI.DEV.Task.164", "TaskDescription": "SSIS.Part.5", "TaskTopic": "SSIS.Part.5"}'
*/

-- =============================================
CREATE PROCEDURE [dbo].[usp_TaskSubtask_Insert]
(
    @json NVARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE		@NoMatchedBonusFromJson		NVARCHAR(250)

IF ISJSON(@json) > 0
	BEGIN
        BEGIN TRY
	        BEGIN TRANSACTION
                DROP TABLE IF EXISTS #TEMP_SOURCE;
                DROP TABLE IF EXISTS #TEMP_TASK_RESULT;
				DROP TABLE IF EXISTS #TEMP_SUBTASK_RESULT;

                CREATE TABLE #TEMP_TASK_RESULT (TaskId INT, [Action] nvarchar(10));
				CREATE TABLE #TEMP_SUBTASK_RESULT (SubTaskId INT, SubTaskName NVARCHAR(250), [Action] nvarchar(10));

			    SELECT *
			    INTO #TEMP_SOURCE
				FROM OPENJSON(@json)
                WITH (
                         CourseName			NVARCHAR(250)   '$.CourseName'
                        ,TaskName			NVARCHAR(100)   '$.TaskName'
                        ,TaskDescription    NVARCHAR(100)   '$.TaskDescription'
                        ,TaskTopic			NVARCHAR(250)   '$.TaskTopic'
                ) AS rootL
                LEFT JOIN OPENJSON(@json, N'$.Subtasks')
                WITH (
                            SubTaskName		NVARCHAR(250)   '$.SubTaskName'
                        ,SubTaskDescription NVARCHAR(250)   '$.SubTaskDescription'
                        ,SubTaskTopic       NVARCHAR(250)   '$.SubTaskTopic'
						,Bonuses			NVARCHAR(MAX)	'$.Bonuses'				AS JSON
                ) AS liefL ON 1 = 1
				OUTER APPLY OPENJSON(Bonuses)
					WITH (Bonus NVARCHAR(30) '$');

				--Task
				MERGE INTO [dbo].[Task] tgt
				USING (SELECT DISTINCT CourseId, ts.TaskName, ts.TaskDescription, ts.TaskTopic 
						FROM #TEMP_SOURCE AS ts
						INNER JOIN [dbo].[Course] AS c 
							ON c.[Name] = ts.[CourseName]) src
					ON (tgt.[Name] = src.[TaskName]
						AND tgt.[CourseId] = src.[CourseId])
				WHEN MATCHED THEN
				UPDATE SET
					tgt.[Description] = src.[TaskDescription]
					,tgt.[Topic] = src.[TaskTopic]
					,tgt.[sysChangedAt] = getutcdate()
				WHEN NOT MATCHED THEN
				INSERT (
					[Name]
					,[Description]
					,[Topic]
					,[CourseId]
				) VALUES
				(
					src.[TaskName]
					,src.[TaskDescription]
					,src.[TaskTopic]
					,src.[CourseId]
				)
				OUTPUT Inserted.TaskId, $ACTION
				INTO #TEMP_TASK_RESULT;

				-- SubTask
				MERGE INTO [dbo].[SubTask] tgt
				USING (
					SELECT DISTINCT (SELECT [TaskId] FROM #TEMP_TASK_RESULT) AS [TaskId],
					tmp.[SubTaskName], tmp.[SubTaskDescription], tmp.[SubTaskTopic] FROM #TEMP_SOURCE AS tmp
					WHERE tmp.[SubTaskName] IS NOT NULL) src
						ON (src.[SubTaskName] = tgt.[Name] 
							AND src.[TaskId] = tgt.[TaskId])
				WHEN MATCHED THEN
				UPDATE SET
					tgt.[Description] = src.[SubTaskDescription]
					,tgt.[Topic] = src.[SubTaskTopic]
					,tgt.[sysChangedAt] = getutcdate()
				WHEN NOT MATCHED THEN
				INSERT (
					[TaskId]
					,[Name]
					,[Description]
					,[Topic]
				) VALUES
				(
					src.[TaskId]
					,src.[SubTaskName]
					,src.[SubTaskDescription]
					,src.[SubTaskTopic]
				)
				OUTPUT Inserted.SubTaskId, Inserted.[Name], $ACTION
				INTO #TEMP_SUBTASK_RESULT;

				-- Check Bonus names
				SELECT TOP 1 @NoMatchedBonusFromJson = tmp.[Bonus]
				FROM #TEMP_SOURCE AS tmp
				LEFT JOIN [dbo].[Bonus] AS b ON TRIM(UPPER(b.[Name])) = TRIM(UPPER(tmp.[Bonus]))
				WHERE tmp.[Bonus] IS NOT NULL
					AND b.[BonusId] IS NULL

				IF (@NoMatchedBonusFromJson IS NOT NULL)
                BEGIN
					RAISERROR (N'Bonus: ''%s'' isn''t found', 16, 1, @NoMatchedBonusFromJson);
                END

				-- SubTaskBonus
				MERGE INTO [dbo].[SubTaskBonus] tgt
				USING (
					SELECT tsr.[SubTaskId], b.[BonusId]
					FROM #TEMP_SUBTASK_RESULT tsr
					INNER JOIN #TEMP_SOURCE AS tmp ON tmp.SubTaskName = tsr.[SubTaskName]
					LEFT JOIN [dbo].[Bonus] AS b ON b.[Name] = tmp.[Bonus]
					WHERE tmp.[Bonus] IS NOT NULL) src
						ON (src.[SubTaskId] = tgt.[SubTaskId] 
							AND src.[BonusId] = tgt.[BonusId])
				WHEN NOT MATCHED BY TARGET THEN
				INSERT (
					 [SubTaskId]
					,[BonusId] 
				) VALUES
				(
					 src.[SubTaskId]
					,src.[BonusId]
				);
				--WHEN NOT MATCHED BY SOURCE THEN
				--DELETE;

				DROP TABLE #TEMP_SOURCE;
				DROP TABLE #TEMP_TASK_RESULT;
				DROP TABLE #TEMP_SUBTASK_RESULT;
            COMMIT TRANSACTION
        END TRY
        BEGIN CATCH
	            IF @@TRANCOUNT > 0 
		            ROLLBACK TRANSACTION;
	            THROW;
        END CATCH;
    END
END