CREATE OR REPLACE VIEW lab.vw_task AS
SELECT        
    c.course_id,
    c."name"             AS course_name,
    t.task_id,
    t."name"             AS task_name,
    t.description        AS task_desc,
    tt."name"            AS topic
FROM lab.task AS t
INNER JOIN lab.course AS c
    ON c.course_id = t.course_id
INNER JOIN lab.topic AS tt 
    ON tt.topic_id = t.topic_id;
