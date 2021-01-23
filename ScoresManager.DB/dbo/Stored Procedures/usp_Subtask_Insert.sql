



-- =============================================
-- Author:			Sergei Boikov
-- Create Date:		2021-01-21
-- Description: Load information about Subtask from JSON
-- Format JSON: N'{"Bonuses":[{"Value":"Readability"},{"Value":"Aliases"}],"SubTaskDescription":"Create T-SQL script1","SubTaskName":"Subtask.03.06","SubTaskTopicId":12,"TaskId":1}' 

--	Example. Add Task and Subtasks: EXEC [dbo].[usp_Subtask_Insert] @json = N'{"Bonuses":[{"Value":"Readability"},{"Value":"Aliases"}],"SubTaskDescription":"Create T-SQL script1","SubTaskName":"Subtask.03.06","SubTaskTopicId":12,"TaskId":1}' 

-- =============================================
CREATE PROCEDURE [dbo].[usp_Subtask_Insert]
(
    @json NVARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE		@NoMatchedBonusFromJson				NVARCHAR(250)

IF ISJSON(@json) > 0
	BEGIN
        BEGIN TRY
	        BEGIN TRANSACTION
                DROP TABLE IF EXISTS #TEMP_SOURCE;
				DROP TABLE IF EXISTS #TEMP_SUBTASK_RESULT;

				CREATE TABLE #TEMP_SUBTASK_RESULT (SubTaskId INT, SubTaskName NVARCHAR(250), [Action] nvarchar(10));

			    SELECT DISTINCT *
			    INTO #TEMP_SOURCE
				FROM OPENJSON(@json)
                WITH (
                         TaskId				INT				'$.TaskId'
                        ,SubTaskName		NVARCHAR(250)   '$.SubTaskName'
                        ,SubTaskDescription NVARCHAR(250)   '$.SubTaskDescription'
                        ,SubTaskTopicId     SMALLINT		'$.SubTaskTopicId'
						,Bonuses			NVARCHAR(MAX)	'$.Bonuses'				AS JSON
                ) AS rootL
				OUTER APPLY OPENJSON(Bonuses)
					WITH (BonusCode NVARCHAR(30) '$.Value');				


				-- SubTask
				MERGE INTO [dbo].[SubTask] tgt
				USING (
					SELECT DISTINCT 
						 tmp.[TaskId]
						,tmp.[SubTaskName]
						,tmp.[SubTaskDescription]
						,tmp.[SubTaskTopicId] 
					FROM #TEMP_SOURCE AS tmp
					WHERE tmp.[SubTaskName] IS NOT NULL) src ON (src.[SubTaskName] = tgt.[Name] 
						AND src.[TaskId] = tgt.[TaskId])
				WHEN MATCHED THEN
				UPDATE SET
					 tgt.[Description] = src.[SubTaskDescription]
					,tgt.[SubTaskTopicId] = src.[SubTaskTopicId]
					,tgt.[sysChangedAt] = getutcdate()
				WHEN NOT MATCHED THEN
				INSERT (
					 [TaskId]
					,[Name]
					,[Description]
					,[SubTaskTopicId]
				) VALUES
				(
					 src.[TaskId]
					,src.[SubTaskName]
					,src.[SubTaskDescription]
					,src.[SubTaskTopicId]
				)
				OUTPUT Inserted.SubTaskId, Inserted.[Name], $ACTION
				INTO #TEMP_SUBTASK_RESULT;

				-- Check Bonus names
				SELECT TOP 1 @NoMatchedBonusFromJson = tmp.[BonusCode]
				FROM #TEMP_SOURCE AS tmp
				LEFT JOIN [dbo].[Bonus] AS b ON b.[Code] = tmp.[BonusCode]
				WHERE tmp.[BonusCode] IS NOT NULL
					AND b.[BonusId] IS NULL

				IF (@NoMatchedBonusFromJson IS NOT NULL)
                BEGIN
					RAISERROR (N'Bonus code: ''%s'' isn''t found', 16, 1, @NoMatchedBonusFromJson);
                END

				-- SubTaskBonus
				MERGE INTO [dbo].[SubTaskBonus] tgt
				USING (
					SELECT	 tsr.[SubTaskId]
							,b.[BonusId]
					FROM #TEMP_SUBTASK_RESULT tsr
					INNER JOIN #TEMP_SOURCE AS tmp ON tmp.SubTaskName = tsr.[SubTaskName]
					LEFT JOIN [dbo].[Bonus] AS b ON b.[Code] = tmp.[BonusCode]
					WHERE tmp.[BonusCode] IS NOT NULL) src ON (src.[SubTaskId] = tgt.[SubTaskId] 
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
				
				--Delete not matched Bonuses from [dbo].[SubTaskBonus]
				DELETE FROM [dbo].[SubTaskBonus]
				WHERE [SubTaskBonusId] IN ( SELECT stb.[SubTaskBonusId]
											FROM [dbo].[SubTaskBonus] stb
											INNER JOIN [dbo].[Bonus] b ON b.[BonusId] = stb.[BonusId]
											INNER JOIN #TEMP_SUBTASK_RESULT tsr ON tsr.[SubTaskId] = stb.[SubTaskId]
											LEFT JOIN #TEMP_SOURCE AS tmp ON tmp.SubTaskName = tsr.[SubTaskName]
												AND tmp.[BonusCode] = b.[Code]
											WHERE tmp.[BonusCode] IS NULL);

				DROP TABLE #TEMP_SOURCE;
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