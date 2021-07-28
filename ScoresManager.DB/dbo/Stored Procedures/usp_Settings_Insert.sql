
-- =============================================
-- Author:			Sergei Boikov
-- Create Date:		2021-07-21
-- Description: Load information about Settings from JSON
-- Format JSON: N'[{"UserEmail":"sergei_boikov@epam.com", "CurrentCourseName":"BI.Lab.Cross.2021"}, {"UserEmail":"ivan_ivanov@epam.com", "CurrentCourseName":"BI.Lab.Cross.2021"}]' 

--	Example. EXEC [dbo].[usp_Settings_Insert] @json = N'{"UserEmail":"sergei_boikov@epam.com", "CurrentCourseName":"BI.Lab.Cross.2021"}' 

-- =============================================
CREATE PROCEDURE [dbo].[usp_Settings_Insert]
(
     @json			NVARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE		@NoMatchedUserFromJson			NVARCHAR(100),
				@NoMatchedCourseNameFromJson	NVARCHAR(250)
				
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
				
				-- Check if User with UserEmail exists
				SELECT TOP 1 @NoMatchedUserFromJson = tmp.[UserEmail]
				FROM #TEMP_SOURCE AS tmp
				LEFT JOIN [dbo].[User] AS u ON TRIM(UPPER(u.[Email])) = TRIM(UPPER(tmp.[UserEmail]))
				WHERE tmp.[UserEmail] IS NOT NULL
					AND u.[UserId] IS NULL

				IF (@NoMatchedUserFromJson IS NOT NULL)
                BEGIN
					RAISERROR (N'User with email: ''%s'' isn''t found', 16, 1, @NoMatchedUserFromJson);
                END

				-- Check if Course with CurrentCourseName exists
				SELECT TOP 1 @NoMatchedCourseNameFromJson = tmp.[CurrentCourseName]
				FROM #TEMP_SOURCE AS tmp
				LEFT JOIN [dbo].[Course] AS c ON TRIM(UPPER(c.[Name])) = TRIM(UPPER(tmp.[CurrentCourseName]))
				WHERE tmp.[CurrentCourseName] IS NOT NULL
					AND c.[CourseId] IS NULL

				IF (@NoMatchedCourseNameFromJson IS NOT NULL)
                BEGIN
					RAISERROR (N'Course with name: ''%s'' isn''t found', 16, 1, @NoMatchedCourseNameFromJson);
                END

				-- Settings
				MERGE INTO [dbo].[Settings] tgt
				USING (
					SELECT DISTINCT 
						 u.[UserId]
						,N'CurrentCourseName' AS [SettingName]
						,tmp.[CurrentCourseName] AS [SettingValue]
					FROM #TEMP_SOURCE AS tmp
					INNER JOIN [dbo].[User] AS u ON TRIM(UPPER(u.[Email])) = TRIM(UPPER(tmp.[UserEmail]))) src ON src.[SettingName] = tgt.[SettingName]
						AND src.[UserId] = tgt.[UserId]
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