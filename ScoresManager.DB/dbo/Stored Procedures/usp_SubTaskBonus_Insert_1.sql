






-- =============================================
-- Author:			Sergei Boikov
-- Create Date:		2021-01-27
-- Description: Load information about bonuses for Subtask from JSON
-- Format JSON: N'{"Bonuses":[{"Value":"Read"},{"Value":"Aliases"}],"SubTaskId":1}' 

--	Example. EXEC [dbo].[usp_SubtaskBonus_Insert] @json = N'{"Bonuses":[{"Value":"Read"},{"Value":"Aliases"}],"SubTaskId":1}' 

-- =============================================
CREATE PROCEDURE [dbo].[usp_SubTaskBonus_Insert]
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

			    SELECT DISTINCT *
			    INTO #TEMP_SOURCE
				FROM OPENJSON(@json)
                WITH (
                         SubTaskId			INT				'$.SubTaskId'
						,Bonuses			NVARCHAR(MAX)	'$.Bonuses'				AS JSON
                ) AS rootL
				OUTER APPLY OPENJSON(Bonuses)
					WITH (BonusCode NVARCHAR(30) '$.Value');				

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
					SELECT	 tmp.[SubTaskId]
							,b.[BonusId]
					FROM #TEMP_SOURCE AS tmp
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
											LEFT JOIN #TEMP_SOURCE AS tmp ON tmp.[SubTaskId] = stb.[SubTaskId]
												AND tmp.[BonusCode] = b.[Code]
											WHERE tmp.[BonusCode] IS NULL);

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