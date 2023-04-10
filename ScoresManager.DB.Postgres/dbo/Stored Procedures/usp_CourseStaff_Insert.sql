
-- =============================================
-- Author:            Sergei Boikov
-- Create Date:        2021-07-26
-- Description: Load information about CourseStaff from JSON
-- Format JSON: N'{"UserName": "Denis Vasilevskii", "CourseName": "BI.Lab.SPb.July2021", "UserEmail": "Denis_Vasilevskii@epam.com", "UserType": "Student"}' --    Example. EXEC dbo.usp_CourseStaff_Insert jsn = N'{"UserName": "Denis Vasilevskii", "CourseName": "BI.Lab.SPb.July2021", "UserEmail": "Denis_Vasilevskii@epam.com", "UserType": "Student"}' -- =============================================

CREATE OR REPLACE PROCEDURE dbo.usp_CourseStaff_Insert
(
     jsn            TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    DECLARE @NoMatchedCourseNameFromJson            VARCHAR(250),
            @NoMatchedUserTypeFromJson                VARCHAR(100)
                    BEGIN
        BEGIN
            BEGIN                CREATE TEMPORARY TABLE TEMP_SOURCE (
        --TODO: FILL
    ) ON COMMIT DROP;
                SELECT *
                INTO TEMP_SOURCE
                FROM OPENJSON(jsn)
                WITH (
                         UserName            VARCHAR(100)    '$.UserName'
                        ,CourseName            VARCHAR(250)   '$.CourseName'
                        ,UserEmail            VARCHAR(100)   '$.UserEmail'
                        ,UserType            VARCHAR(100)   '$.UserType'
                ) AS rootL
                
                -- Check Course names
                SELECT TOP 1 @NoMatchedCourseNameFromJson = tmp.CourseName
                FROM TEMP_SOURCE AS tmp
                LEFT JOIN dbo.Course AS c ON TRIM(UPPER(c.Name)) = TRIM(UPPER(tmp.CourseName))
                WHERE tmp.CourseName IS NOT NULL
                    AND c.CourseId IS NULL                IF (@NoMatchedCourseNameFromJson IS NOT NULL)
                BEGIN
                    RAISERROR (N'Course with name: ''%s'' isn''t found', 16, 1, @NoMatchedCourseNameFromJson);
                END                -- Check User type
                SELECT TOP 1 @NoMatchedUserTypeFromJson = tmp.UserType
                FROM TEMP_SOURCE AS tmp
                LEFT JOIN dbo.UserType AS ut ON TRIM(UPPER(ut.Name)) = TRIM(UPPER(tmp.UserType))
                WHERE tmp.UserType IS NOT NULL
                    AND ut.UserTypeId IS NULL                IF (@NoMatchedUserTypeFromJson IS NOT NULL)
                BEGIN
                    RAISERROR (N'User type: ''%s'' isn''t found', 16, 1, @NoMatchedUserTypeFromJson);
                END                -- User
                MERGE INTO dbo.User tgt
                USING (    SELECT DISTINCT  tmp.UserName
                                        ,tmp.UserEmail
                        FROM TEMP_SOURCE AS tmp) src
                    ON (TRIM(UPPER(tgt.Email)) = TRIM(UPPER(src.UserEmail)))
                WHEN MATCHED THEN
                UPDATE SET
                     tgt.Name = src.UserName
                    ,tgt.sysChangedAt = CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE
                WHEN NOT MATCHED THEN
                INSERT (
                     Name
                    ,Email
                ) VALUES
                (
                     src.UserName
                    ,src.UserEmail
                );
                
                -- CourseStaff
                MERGE INTO dbo.CourseStaff tgt
                USING (
                    SELECT DISTINCT 
                         u.UserId
                        ,c.CourseId
                        ,ut.UserTypeId
                    FROM TEMP_SOURCE AS tmp
                    INNER JOIN dbo.User AS u ON TRIM(UPPER(u.Email)) = TRIM(UPPER(tmp.UserEmail))
                    INNER JOIN dbo.Course AS c ON TRIM(UPPER(c.Name)) = TRIM(UPPER(tmp.CourseName))
                    INNER JOIN dbo.UserType AS ut ON TRIM(UPPER(ut.Name)) = TRIM(UPPER(tmp.UserType))
                ) src ON (src.UserId = tgt.UserId 
                        AND src.CourseId = tgt.CourseId)
                WHEN MATCHED THEN
                UPDATE SET
                     tgt.UserTypeId = src.UserTypeId
                    ,tgt.sysChangedAt = CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE
                WHEN NOT MATCHED THEN
                INSERT (
                     UserId
                    ,CourseId
                    ,UserTypeId
                ) VALUES
                (
                     src.UserId
                    ,src.CourseId
                    ,src.UserTypeId
                );                            COMMIT;        END TRY
        BEGIN CATCH
                IF @@TRANCOUNT > 0 
                    ROLLBACK TRANSACTION;
                THROW;
                
        END CATCH;
    END
    ELSE
        THROW 50000, N'JSON isn''t correct', 0;
        
END