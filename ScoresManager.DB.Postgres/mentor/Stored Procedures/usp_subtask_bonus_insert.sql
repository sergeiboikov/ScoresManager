
-- =============================================
-- Author:      Sergei Boikov
-- Create Date:        2021-01-27
-- Description: Load information about bonuses for subtask from JSON
-- Format JSON: '{"bonuses":{"Value":"read"},{"Value":"aliases"},"subtask_id":1}' --    Example. EXEC lab.usp_subtask_bonus_insert jsn = '{"bonuses":{"Value":"read"},{"Value":"aliases"},"subtask_id":1}' -- =============================================

CREATE OR REPLACE PROCEDURE mentor.usp_subtask_bonus_insert(jsn JSON)
LANGUAGE plpgsql
AS $$
BEGIN

    DECLARE        NoMatchedbonusFromJson                VARCHAR(250)
    BEGIN
        BEGIN
            BEGIN
                CREATE TEMPORARY TABLE temp_source (
        --TODO: FILL
    ) ON COMMIT DROP;
                SELECT DISTINCT *
                INTO temp_source
                FROM OPENJSON(jsn)
                WITH (
                         subtask_id            INT                '$.subtask_id'
                        ,bonuses            TEXT    '$.bonuses'                AS JSON
               ) AS rootL
                OUTER APPLY OPENJSON(bonuses)
                    WITH (bonus_code VARCHAR(30) '$.Value');                                -- Check bonus names
                SELECT TOP 1 NoMatchedbonusFromJson = tmp.bonus_code
                FROM temp_source AS tmp
                LEFT JOIN lab.bonus AS b ON b.code = tmp.bonus_code
                WHERE tmp.bonus_code IS NOT NULL
                    AND b.bonus_id IS NULL                IF (NoMatchedbonusFromJson IS NOT NULL)
                BEGIN
                    RAISERROR ('bonus code: ''%s'' isn''t found', 16, 1, NoMatchedbonusFromJson);
                END                -- subtask_bonus
                MERGE INTO lab.subtask_bonus tgt
                USING (
                    SELECT     tmp.subtask_id
                            ,b.bonus_id
                    FROM temp_source AS tmp
                    LEFT JOIN lab.bonus AS b ON b.code = tmp.bonus_code
                    WHERE tmp.bonus_code IS NOT NULL) src ON (src.subtask_id = tgt.subtask_id 
                        AND src.bonus_id = tgt.bonus_id)
                WHEN NOT MATCHED THEN
                INSERT (
                     subtask_id
                    ,bonus_id 
                ) VALUES
                (
                     src.subtask_id
                    ,src.bonus_id
                );
                
                --Delete not matched bonuses from lab.subtask_bonus
                DELETE FROM lab.subtask_bonus
                WHERE subtask_bonus_id IN ( SELECT stb.subtask_bonus_id
                                            FROM lab.subtask_bonus stb
                                            INNER JOIN lab.bonus b ON b.bonus_id = stb.bonus_id
                                            LEFT JOIN temp_source AS tmp ON tmp.subtask_id = stb.subtask_id
                                                AND tmp.bonus_code = b.code
                                            WHERE tmp.bonus_code IS NULL);                

    END
END