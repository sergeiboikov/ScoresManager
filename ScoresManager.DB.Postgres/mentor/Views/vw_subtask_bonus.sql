CREATE OR REPLACE VIEW mentor.vw_subtask_bonus AS
SELECT    
    stb.subtask_bonus_id,
    stb.subtask_id,
    st."name"               AS subtask_name,
    stb.bonus_id,
    b."name"                AS bonus_name,
    b.code                  AS bonus_code
FROM lab.subtask_bonus AS stb
INNER JOIN lab.subtask AS st 
    ON st.subtask_id = stb.subtask_id
INNER JOIN lab.bonus AS b 
    ON b.bonus_id = stb.bonus_id;
