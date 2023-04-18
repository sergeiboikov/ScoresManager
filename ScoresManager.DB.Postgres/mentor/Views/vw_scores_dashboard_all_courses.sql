CREATE OR REPLACE VIEW mentor.vw_scores_dashboard_all_courses AS
SELECT 
     c."name"                 AS course_name,
     t."name"                 AS task_name,
     t.description            AS task_desc,
     tt."name"                AS task_topic_name,
     st.subtask_id            AS subtask_id,
     st."name"                AS subtask_name,
     st.description           AS subtask_desc,
     stt."name"               AS subtask_topic_name,
     cs1.course_staff_id      AS student_id,
     u1."name"                AS student_name,
     cs2.course_staff_id      AS reviewer_id,
     u2."name"                AS reviewer_name,
     stl.score                AS score,
     stl.ontime               AS ontime,
     stl.accuracy             AS accuracy,
     stl.extra                AS extra,
     stl.total_score          AS total_score,
     stl.comment              AS comment
FROM lab.subtask_log AS stl
INNER JOIN lab.subtask AS st 
     ON st.subtask_id = stl.subtask_id
INNER JOIN lab.topic AS stt 
     ON stt.topic_id = st.topic_id
INNER JOIN lab.task AS t 
     ON t.task_id = st.task_id
INNER JOIN lab.topic AS tt 
     ON tt.topic_id = t.topic_id
INNER JOIN lab.course AS c 
     ON c.course_id = t.course_id
INNER JOIN lab.course_staff AS cs1 
     ON cs1.course_staff_id = stl.student_id
INNER JOIN lab.user AS u1 
     ON u1.user_id = cs1.user_id
INNER JOIN lab.course_staff AS cs2 
     ON cs2.course_staff_id = stl.reviewer_id
INNER JOIN lab.user AS u2 
     ON u2.user_id = cs2.user_id;
