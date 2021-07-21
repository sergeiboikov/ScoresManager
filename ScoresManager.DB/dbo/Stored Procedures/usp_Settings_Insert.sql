-- =============================================
-- Author:			Sergei Boikov
-- Create Date:		2021-07-21
-- Description: Load information about Settings from JSON
-- Format JSON: N'{"UserEmail":"sergei_boikov@epam.com", "CurrentCourseName":"BI.Lab.Cross.2021"}' 

--	Example. EXEC [dbo].[usp_Settings_Insert] @json = N'{"UserEmail":"sergei_boikov@epam.com", "CurrentCourseName":"BI.Lab.Cross.2021"}' 

-- =============================================
CREATE PROCEDURE [dbo].[usp_Settings_Insert]
(
     @json			NVARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE		@UserId					INT,
				@CourseId				INT
				
IF ISJSON(@json) > 0
	BEGIN
        BEGIN TRY
	        BEGIN TRANSACTION
                SELECT *
				INTO #TEMP_SOURCE
				FROM OPENJSON(@json)
				WITH (
						 UserEmail			NVARCHAR(100)	'$.UserEmail'
						,CurrentCourseName	NVARCHAR(100)   '$.CurrentCourseName'
				) AS rootL
				

				/*Check that User with UserId exists*/
				SELECT TOP 1 @UserId = u.UserId 
				FROM #TEMP_SOURCE tmp
				INNER JOIN [dbo].[User] u ON LOWER(u.Email) = LOWER(tmp.UserEmail)

				IF (@UserId IS NULL)
					THROW 50000, N'User isn''t found', 0;

				/*Check that Course with CourseName exists*/
				SELECT TOP 1 @CourseId = c.CourseId 
				FROM #TEMP_SOURCE tmp
				INNER JOIN [dbo].[Course] c ON c.[Name] = tmp.CurrentCourseName

				IF (@CourseId IS NULL)
					THROW 50000, N'Course isn''t found', 0;

				-- Settings
				MERGE INTO [dbo].[Settings] tgt
				USING (
					SELECT DISTINCT 
						 @UserId AS [UserId]
						,N'CurrentCourseName' AS [SettingName]
						,tmp.[CurrentCourseName] AS [SettingValue]
					FROM #TEMP_SOURCE AS tmp) src ON (src.[SettingName] = tgt.[SettingName]
						AND src.[UserId] = tgt.[UserId])
				WHEN MATCHED THEN
				UPDATE SET
					 tgt.[SettingValue] = src.[SettingValue]
					,tgt.[sysChangedAt] = getutcdate()
				WHEN NOT MATCHED THEN
				INSERT (
					 [UserId]
					,[SettingName]
					,[SettingValue]
				) VALUES
				(
					 src.[UserId]
					,src.[SettingName]
					,src.[SettingValue]
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
	ELSE
		THROW 50000, N'JSON isn''t correct', 0;
		
END