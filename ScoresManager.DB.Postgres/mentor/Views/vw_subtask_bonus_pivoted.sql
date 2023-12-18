CREATE OR REPLACE VIEW mentor.vw_subtask_bonus_pivoted AS
SELECT DISTINCT    
    t.course_id                 AS course_id,
    t.task_id,
    t."name"                    AS task_name,
    st.subtask_id,
    st."name"                   AS subtask_name,
    st.description              AS subtask_desc,
    st.topic_id                 AS subtask_topic_id,
    stt."name"                  AS subtask_topic_name,
    (SELECT CAST(1 AS BIT)      AS is_name_conv      FROM mentor.vw_subtask_bonus stb WHERE stb.subtask_id = st.subtask_id AND stb.bonus_code = 'name_conv')      AS is_name_conv,
    (SELECT CAST(1 AS BIT)      AS is_read           FROM mentor.vw_subtask_bonus stb WHERE stb.subtask_id = st.subtask_id AND stb.bonus_code = 'read')           AS is_read,
    (SELECT CAST(1 AS BIT)      AS is_sarg           FROM mentor.vw_subtask_bonus stb WHERE stb.subtask_id = st.subtask_id AND stb.bonus_code = 'sarg')           AS is_sarg,
    (SELECT CAST(1 AS BIT)      AS is_schema_name    FROM mentor.vw_subtask_bonus stb WHERE stb.subtask_id = st.subtask_id AND stb.bonus_code = 'schema_name')    AS is_schema_name,
    (SELECT CAST(1 AS BIT)      AS is_aliases        FROM mentor.vw_subtask_bonus stb WHERE stb.subtask_id = st.subtask_id AND stb.bonus_code = 'aliases')        AS is_aliases,
    (SELECT CAST(1 AS BIT)      AS is_determ_sort    FROM mentor.vw_subtask_bonus stb WHERE stb.subtask_id = st.subtask_id AND stb.bonus_code = 'determ_sort')    AS is_determ_sort
FROM lab.subtask AS st
INNER JOIN lab.task AS t 
    ON t.task_id = st.task_id
INNER JOIN lab.topic AS stt 
    ON stt.topic_id = st.topic_id;
