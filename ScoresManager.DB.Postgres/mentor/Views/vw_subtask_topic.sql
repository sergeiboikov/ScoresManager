CREATE OR REPLACE VIEW mentor.vw_subtask_topic AS
SELECT      
    stt.topic_id,
    stt."name"    AS subtask_topic_name
FROM lab.topic AS stt
WHERE stt.is_topic_for_subtasks = CAST(1 AS BIT);
