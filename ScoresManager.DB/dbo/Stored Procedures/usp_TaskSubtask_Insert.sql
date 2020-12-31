

-- =============================================
-- Author:			Sergei Boikov
-- Create Date:		2020-12-28
-- Description: Load information about Task and Subtasks from JSON
/* Format JSON: N'{"CourseName": "MSBI.DEV.S20", "TaskName": "MSBI.DEV.Task.164", "TaskDescription": "SSIS.Part.5", "TaskTopic": "SSIS.Part.5", 
				  "Subtasks": [ 
								 {"SubTaskName": "Subtask.164.01", "SubTaskDescription": "SSIS project development", "SubTaskTopic": "SSIS"} 
								,{"SubTaskName": "Subtask.164.02", "SubTaskDescription": "SSIS project deployment", "SubTaskTopic": "SSIS"}			
							  ]
				  }' 
*/
/*	Example 1. Add Task and Subtasks: EXEC [mentor].[usp_TaskSubtask_Insert] @json = N'{"CourseName": "MSBI.DEV.S20", "TaskName": "MSBI.DEV.Task.164", "TaskDescription": "SSIS.Part.5", "TaskTopic": "SSIS.Part.5", 
														  "Subtasks": [ 
																		 {"SubTaskName": "Subtask.164.01", "SubTaskDescription": "SSIS project development", "SubTaskTopic": "SSIS"} 
																		,{"SubTaskName": "Subtask.164.02", "SubTaskDescription": "SSIS project deployment", "SubTaskTopic": "SSIS"}			
																	  ]
														  }' 
														  
	Example 2. Add Task without Subtasks: EXEC [mentor].[usp_TaskSubtask_Insert] @json = N'{"CourseName": "MSBI.DEV.S20", "TaskName": "MSBI.DEV.Task.164", "TaskDescription": "SSIS.Part.5", "TaskTopic": "SSIS.Part.5"}'
*/

-- =============================================
CREATE PROCEDURE [dbo].[usp_TaskSubtask_Insert]
(
    @json NVARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;

IF ISJSON(@json) > 0
	BEGIN
        BEGIN TRY
	        BEGIN TRANSACTION
                DROP TABLE IF EXISTS #TEMP_SOURCE;
                DROP TABLE IF EXISTS #TEMP_RESULT;
                CREATE TABLE #TEMP_RESULT (TaskId INT, [Action] nvarchar(10));

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
                    ) AS liefL ON 1 = 1;

--Task
MERGE INTO [dbo].[Task] tgt
USING (SELECT DISTINCT CourseId, ts.TaskName, ts.TaskDescription, ts.TaskTopic 
	   FROM #temp_source AS ts
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
INTO #TEMP_RESULT;

-- SubTask
MERGE INTO [dbo].[SubTask] tgt
USING (
    SELECT (SELECT [TaskId] FROM #TEMP_RESULT) AS [TaskId],
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
);
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
END