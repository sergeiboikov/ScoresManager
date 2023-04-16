
-- =============================================
-- Author:      Sergei Boikov
-- Create Date:        2021-07-21
-- Description: Load information about settings from JSON
-- Format JSON: '{"user_email":"sergei_boikovepam.com", "Currentcourse_name":"BI.Lab.Cross.2021"}, {"user_email":"ivan_ivanovepam.com", "Currentcourse_name":"BI.Lab.Cross.2021"}' --    Example. EXEC lab.usp_settings_insert jsn = '{"user_email":"sergei_boikovepam.com", "Currentcourse_name":"BI.Lab.Cross.2021"}' -- =============================================

CREATE OR REPLACE PROCEDURE lab.usp_settings_insert
(
     jsn            TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    DECLARE        NoMatcheduserFromJson            VARCHAR(100),
                no_matched_course_name_from_json    VARCHAR(250)
                    BEGIN
        BEGIN
            BEGIN
                SELECT *
                INTO temp_source
                FROM OPENJSON(jsn)
                WITH (
                         user_email            VARCHAR(100)    '$.user_email'
                        ,Currentcourse_name    VARCHAR(100)   '$.Currentcourse_name'
                ) AS rootL
                
                -- Check if user with user_email exists
                SELECT TOP 1 NoMatcheduserFromJson = tmp.user_email
                FROM temp_source AS tmp
                LEFT JOIN lab.user AS u ON TRIM(UPPER(u.email)) = TRIM(UPPER(tmp.user_email))
                WHERE tmp.user_email IS NOT NULL
                    AND u.user_id IS NULL                IF (NoMatcheduserFromJson IS NOT NULL)
                BEGIN
                    RAISERROR ('user with email: ''%s'' isn''t found', 16, 1, NoMatcheduserFromJson);
                END                -- Check if course with Currentcourse_name exists
                SELECT TOP 1 no_matched_course_name_from_json = tmp.Currentcourse_name
                FROM temp_source AS tmp
                LEFT JOIN lab.course AS c ON TRIM(UPPER(c."name")) = TRIM(UPPER(tmp.Currentcourse_name))
                WHERE tmp.Currentcourse_name IS NOT NULL
                    AND c.course_id IS NULL                IF (no_matched_course_name_from_json IS NOT NULL)
                BEGIN
                    RAISERROR ('course with name: ''%s'' isn''t found', 16, 1, no_matched_course_name_from_json);
                END                -- settings
                MERGE INTO lab.settings tgt
                USING (
                    SELECT DISTINCT 
                         u.user_id
                        ,'Currentcourse_name' AS setting_name
                        ,tmp.Currentcourse_name AS setting_value
                    FROM temp_source AS tmp
                    INNER JOIN lab.user AS u ON TRIM(UPPER(u.email)) = TRIM(UPPER(tmp.user_email))) src ON src.setting_name = tgt.setting_name
                        AND src.user_id = tgt.user_id
                WHEN MATCHED THEN
                UPDATE SET
                     tgt.setting_value = src.setting_value
                    ,tgt.sys_changed_at = CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE
                WHEN NOT MATCHED THEN
                INSERT (
                     user_id
                    ,setting_name
                    ,setting_value
                ) VALUES
                (
                     src.user_id
                    ,src.setting_name
                    ,src.setting_value
                );                            COMMIT;        END TRY
        BEGIN CATCH
                IF TRANCOUNT > 0 
                    ROLLBACK TRANSACTION;
                THROW;
                
        END CATCH;
    END
    ELSE
        THROW 50000, 'JSON isn''t correct', 0;
END