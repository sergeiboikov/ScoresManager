CREATE OR REPLACE VIEW lab.vw_student AS
SELECT 
    u.user_id   AS user_id,
    u."name"    AS username,
    s."name"    AS status_name
FROM lab.course_staff AS cs
INNER JOIN lab.user_type AS ut 
    ON ut.user_type_id = cs.user_type_id
        AND ut."name" = 'student'
INNER JOIN lab.user AS u 
    ON u.user_id = cs.user_id
LEFT JOIN lab.status AS s 
    ON s.status_id = cs.status_id;
