CREATE OR REPLACE VIEW mentor.vw_subtask AS
SELECT DISTINCT    
    t.task_id,
    t."name"            AS task_name,
    st.subtask_id,
    st."name"           AS subtask_name,     
    st.description      AS subtask_desc,
    st.max_score        AS max_score,
    stt.topic_id        AS subtask_topic_id,
    stt."name"          AS subtask_topic_name
FROM lab.subtask AS st
INNER JOIN lab.task AS t 
    ON t.task_id = st.task_id
INNER JOIN lab.topic AS stt 
    ON stt.topic_id = st.topic_id;
