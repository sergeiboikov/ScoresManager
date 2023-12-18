CREATE OR REPLACE VIEW mentor.vw_subtask_log AS
SELECT      
    stl.subtask_log_id,
    c.course_id,
    c."name"                 AS course_name,
    t.task_id,
    t."name"                 AS task_name,
    st.subtask_id,
    st."name"                AS subtask_name,
    cs1.course_staff_id      AS student_id,
    u1."name"                AS student_name,
    cs2.course_staff_id      AS reviewer_id,
    u2."name"                AS reviewer_name,
    stl.score,
    stl.ontime,
    stl.accuracy,
    stl.extra,
    stl.total_score,
    stl.comment     
FROM lab.subtask_log AS stl
INNER JOIN lab.subtask AS st 
    ON st.subtask_id = stl.subtask_id
INNER JOIN lab.task AS t 
    ON t.task_id = st.task_id
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
