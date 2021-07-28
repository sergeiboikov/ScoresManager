
-- =============================================
-- Author:			Sergei Boikov
-- Create Date:		2021-07-26
-- Description: Load information about CourseStaff from JSON
-- Format JSON: N'[{"UserName": "Denis Vasilevskii", "CourseName": "BI.Lab.SPb.July2021", "UserEmail": "Denis_Vasilevskii@epam.com", "UserType": "Student"}]' 

--	Example. EXEC [dbo].[usp_CourseStaff_Insert] @json = N'[{"UserName": "Denis Vasilevskii", "CourseName": "BI.Lab.SPb.July2021", "UserEmail": "Denis_Vasilevskii@epam.com", "UserType": "Student"}]' 

-- =============================================
CREATE PROCEDURE [dbo].[usp_CourseStaff_Insert]
(
     @json			NVARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @NoMatchedCourseNameFromJson			NVARCHAR(250),
			@NoMatchedUserTypeFromJson				NVARCHAR(100)
				
IF ISJSON(@json) > 0
	BEGIN
        BEGIN TRY
	        BEGIN TRANSACTION

				DROP TABLE IF EXISTS #TEMP_SOURCE;

                SELECT *
				INTO #TEMP_SOURCE
				FROM OPENJSON(@json)
				WITH (
						 UserName			NVARCHAR(100)	'$.UserName'
						,CourseName			NVARCHAR(250)   '$.CourseName'
						,UserEmail			NVARCHAR(100)   '$.UserEmail'
						,UserType			NVARCHAR(100)   '$.UserType'
				) AS rootL
				
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

				-- Check User type
				SELECT TOP 1 @NoMatchedUserTypeFromJson = tmp.[UserType]
				FROM #TEMP_SOURCE AS tmp
				LEFT JOIN [dbo].[UserType] AS ut ON TRIM(UPPER(ut.[Name])) = TRIM(UPPER(tmp.UserType))
				WHERE tmp.[UserType] IS NOT NULL
					AND ut.[UserTypeId] IS NULL

				IF (@NoMatchedUserTypeFromJson IS NOT NULL)
                BEGIN
					RAISERROR (N'User type: ''%s'' isn''t found', 16, 1, @NoMatchedUserTypeFromJson);
                END

				-- User
				MERGE INTO [dbo].[User] tgt
				USING (	SELECT DISTINCT  tmp.UserName
										,tmp.UserEmail
						FROM #TEMP_SOURCE AS tmp) src
					ON (TRIM(UPPER(tgt.[Email])) = TRIM(UPPER(src.[UserEmail])))
				WHEN MATCHED THEN
				UPDATE SET
					 tgt.[Name] = src.[UserName]
					,tgt.[sysChangedAt] = getutcdate()
				WHEN NOT MATCHED THEN
				INSERT (
					 [Name]
					,[Email]
				) VALUES
				(
					 src.[UserName]
					,src.[UserEmail]
				);
				
				-- CourseStaff
				MERGE INTO [dbo].[CourseStaff] tgt
				USING (
					SELECT DISTINCT 
						 u.[UserId]
						,c.[CourseId]
						,ut.[UserTypeId]
					FROM #TEMP_SOURCE AS tmp
					INNER JOIN [dbo].[User] AS u ON TRIM(UPPER(u.[Email])) = TRIM(UPPER(tmp.[UserEmail]))
					INNER JOIN [dbo].[Course] AS c ON TRIM(UPPER(c.[Name])) = TRIM(UPPER(tmp.[CourseName]))
					INNER JOIN [dbo].[UserType] AS ut ON TRIM(UPPER(ut.[Name])) = TRIM(UPPER(tmp.UserType))
				) src ON (src.[UserId] = tgt.[UserId] 
						AND src.[CourseId] = tgt.[CourseId])
				WHEN MATCHED THEN
				UPDATE SET
					 tgt.[UserTypeId] = src.[UserTypeId]
					,tgt.[sysChangedAt] = getutcdate()
				WHEN NOT MATCHED THEN
				INSERT (
					 [UserId]
					,[CourseId]
					,[UserTypeId]
				) VALUES
				(
					 src.[UserId]
					,src.[CourseId]
					,src.[UserTypeId]
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