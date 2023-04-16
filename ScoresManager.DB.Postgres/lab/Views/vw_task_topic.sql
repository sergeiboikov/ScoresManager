CREATE OR REPLACE VIEW lab.vw_task_topic AS
SELECT      
    t.topic_id,
    t."name"    AS task_topic_name
FROM lab.topic AS t
WHERE is_topic_for_tasks = CAST(1 AS BIT);
