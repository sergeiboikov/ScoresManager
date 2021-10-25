
-- =============================================
-- Author:			Elyana Pogosyan
-- Create Date:		2021-10-22
-- Description: Load information for CheckScript from JSON
-- Format JSON: N'[
--					{"CourseName": "BI.Lab.Cross.2021","TaskName": "ASQL.Homework_02","SubTaskName": "Subtask.01","CheckScriptText": "SELECT 1","CheckScriptDesc": "Check script for Subtask.01","CheckScriptTypeName": "SQL","ConnectionString": "Connection string","ConnectionTypeName": "ODBC"}
--					{"CourseName": "BI.Lab.Cross.2021","TaskName": "GIT.Homework_01","SubTaskName": "Subtask.01","CheckScriptText": "SELECT 1","CheckScriptDesc": "Check script for Subtask.01","CheckScriptTypeName": "SQL","ConnectionString": "Connection string","ConnectionTypeName": "ODBC"}
--				  ]' 
--  Example: EXEC [dbo].[usp_CheckScript_BulkInsert] @json =  N'[
--					{"CourseName": "BI.Lab.Cross.2021","TaskName": "ASQL.Homework_02","SubTaskName": "Subtask.01","CheckScriptText": "SELECT 1","CheckScriptDesc": "Check script for Subtask.01","CheckScriptTypeName": "SQL","ConnectionString": "Connection string","ConnectionTypeName": "ODBC"}
--					{"CourseName": "BI.Lab.Cross.2021","TaskName": "GIT.Homework_01","SubTaskName": "Subtask.01","CheckScriptText": "SELECT 1","CheckScriptDesc": "Check script for Subtask.01","CheckScriptTypeName": "SQL","ConnectionString": "Connection string","ConnectionTypeName": "ODBC"}
--				  ]' 

-- =============================================

CREATE PROCEDURE [dbo].[usp_CheckScript_BulkInsert]
(
    @json NVARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE		@NoMatchedCourseNameFromJson			NVARCHAR(250),
				@NoMatchedTaskNameFromJson				NVARCHAR(250),
				@NoMatchedSubTaskNameFromJson			NVARCHAR(250),
				@NoMatchedCheckScriptTypeNameFromJson	NVARCHAR(250),
				@NoMatchedConnectionStringFromJson		NVARCHAR(250),
				@NoMatchedConnectionTypeNameFromJson	NVARCHAR(250)

IF ISJSON(@json) > 0
	BEGIN
        BEGIN TRY
	        BEGIN TRANSACTION
                DROP TABLE IF EXISTS #TEMP_SOURCE;

			    SELECT *
			    INTO #TEMP_SOURCE
				FROM OPENJSON(@json)
                WITH (
                         CourseName			 NVARCHAR(250)   '$.CourseName'
                        ,TaskName			 NVARCHAR(100)   '$.TaskName'
						,SubTaskName		 NVARCHAR(250)   '$.SubTaskName'
						,CheckScriptText	 NVARCHAR(250)	 '$.CheckScriptText'
						,CheckScriptDesc	 NVARCHAR(250)	 '$.CheckScriptDesc'
						,CheckScriptTypeName NVARCHAR(250)	 '$.CheckScriptTypeName'
						,ConnectionString	 NVARCHAR(250)	 '$.ConnectionString'
						,ConnectionTypeName  NVARCHAR(250)	 '$.ConnectionTypeName'
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

				-- Check TaskName
				SELECT TOP 1 @NoMatchedTaskNameFromJson = tmp.[TaskName]
				FROM #TEMP_SOURCE AS tmp
					LEFT JOIN [dbo].[Task] AS T ON TRIM(UPPER(T.[Name])) = TRIM(UPPER(tmp.[TaskName]))
				WHERE tmp.[TaskName] IS NOT NULL
					AND T.[TaskId] IS NULL
				
				IF (@NoMatchedTaskNameFromJson IS NOT NULL)
                BEGIN
					RAISERROR (N'Task with name: ''%s'' isn''t found', 16, 1, @NoMatchedTaskNameFromJson);
                END
				
				-- Check SubTaskName
				SELECT TOP 1 @NoMatchedSubTaskNameFromJson = tmp.[SubTaskName]
				FROM #TEMP_SOURCE AS tmp
					LEFT JOIN [dbo].[SubTask] AS ST ON TRIM(UPPER(ST.[Name])) = TRIM(UPPER(tmp.[SubTaskName]))
				WHERE tmp.[SubTaskName] IS NOT NULL
					AND ST.[SubTaskId] IS NULL
				
				IF (@NoMatchedSubTaskNameFromJson IS NOT NULL)
                BEGIN
					RAISERROR (N'SubTask with name: ''%s'' isn''t found', 16, 1, @NoMatchedSubTaskNameFromJson);
                END

				-- Check ConnectionString
				SELECT TOP 1 @NoMatchedConnectionStringFromJson = tmp.[ConnectionString]
				FROM #TEMP_SOURCE AS tmp
					LEFT JOIN [dbo].[Connection] AS C ON TRIM(UPPER(C.[ConnectionString])) = TRIM(UPPER(tmp.[ConnectionString]))
				WHERE tmp.[ConnectionString] IS NOT NULL
					AND C.[ConnectionId] IS NULL
				
				IF (@NoMatchedConnectionStringFromJson IS NOT NULL)
                BEGIN
					RAISERROR (N'Connection String with name: ''%s'' isn''t found', 16, 1, @NoMatchedConnectionStringFromJson);
                END

				-- Check CheckScriptTypeName
				SELECT TOP 1 @NoMatchedCheckScriptTypeNameFromJson = tmp.[CheckScriptTypeName]
				FROM #TEMP_SOURCE AS tmp
					LEFT JOIN [dbo].[CheckScriptType] AS CST ON TRIM(UPPER(CST.[Name])) = TRIM(UPPER(tmp.[CheckScriptTypeName]))
				WHERE tmp.[CheckScriptTypeName] IS NOT NULL
					AND CST.[CheckScriptTypeId] IS NULL
				
				IF (@NoMatchedCheckScriptTypeNameFromJson IS NOT NULL)
                BEGIN
					RAISERROR (N'CheckScriptType with name: ''%s'' isn''t found', 16, 1, @NoMatchedCheckScriptTypeNameFromJson);
                END

				-- Check ConnectionTypeName
				SELECT TOP 1 @NoMatchedConnectionTypeNameFromJson = tmp.[ConnectionTypeName]
				FROM #TEMP_SOURCE AS tmp
					LEFT JOIN [dbo].[ConnectionType] AS CT ON TRIM(UPPER(CT.[Name])) = TRIM(UPPER(tmp.[ConnectionTypeName]))
				WHERE tmp.[ConnectionTypeName] IS NOT NULL
					AND CT.[ConnectionTypeId] IS NULL
				
				IF (@NoMatchedConnectionTypeNameFromJson IS NOT NULL)
                BEGIN
					RAISERROR (N'ConnectionType with name: ''%s'' isn''t found', 16, 1, @NoMatchedConnectionTypeNameFromJson);
                END

				-- CheckScript insert
				MERGE INTO [dbo].[CheckScript] tgt
				USING (
					SELECT DISTINCT  tmp.[CheckScriptText]
									,tmp.[CheckScriptDesc]
									,  C.[ConnectionId]
									,CST.[CheckScriptTypeId]
					FROM #TEMP_SOURCE AS tmp
						INNER JOIN [dbo].[Connection]		AS C	ON TRIM(UPPER(C.[ConnectionString]))	= TRIM(UPPER(tmp.[ConnectionString]))
						INNER JOIN [dbo].[CheckScriptType]	AS CST	ON TRIM(UPPER(CST.[Name]))				= TRIM(UPPER(tmp.[CheckScriptTypeName]))
						INNER JOIN [dbo].[ConnectionType]	AS CT	ON TRIM(UPPER(CT.[Name]))				= TRIM(UPPER(tmp.[ConnectionTypeName]))
					 ) src ON (TRIM(UPPER(src.[CheckScriptText])) = TRIM(UPPER(tgt.[Text])))
				WHEN MATCHED THEN
				UPDATE SET
					 tgt.[Description]		= src.[CheckScriptDesc]
					,tgt.[ConnectionId]		= src.[ConnectionId]
					,tgt.[CheckScriptTypeId]= src.[CheckScriptTypeId]
					,tgt.[sysChangedAt]		= getutcdate()
				WHEN NOT MATCHED THEN
				INSERT (
					 [Text]
					,[Description]
					,[ConnectionId]
					,[CheckScriptTypeId]
				) VALUES
				(
					 src.[CheckScriptText]
					,src.[CheckScriptDesc]
					,src.[ConnectionId]
					,src.[CheckScriptTypeId]
				);

				-- SubTask checkScriptId update
				UPDATE ST
				SET  ST.[CheckScriptId] = CS.[CheckScriptId]
					,ST.[sysChangedAt]  = getutcdate()
				FROM [dbo].[SubTask] ST
					INNER JOIN #TEMP_SOURCE			tmp ON TRIM(UPPER(ST.[Name])) = TRIM(UPPER(tmp.[SubTaskName])) 
					INNER JOIN [dbo].[CheckScript]   CS ON TRIM(UPPER(CS.[Text])) = TRIM(UPPER(tmp.[CheckScriptText]))
					INNER JOIN [dbo].[Task]			  T ON TRIM(UPPER(T.[Name]))  = TRIM(UPPER(tmp.[TaskName]))
													              AND T.[TaskId]  = ST.[TaskId]
					INNER JOIN [dbo].[Course]		  C ON TRIM(UPPER(C.[Name]))  = TRIM(UPPER(tmp.[CourseName]))
																  AND C.[CourseId]= T.[CourseId];


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