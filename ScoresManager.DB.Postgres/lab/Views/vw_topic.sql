CREATE OR REPLACE VIEW lab.vw_topic AS
SELECT
    tt.topic_id,
    tt."name"                    AS topic_name,
    tt.is_topic_for_tasks,
    tt.is_topic_for_subtasks
FROM lab.topic AS tt;
