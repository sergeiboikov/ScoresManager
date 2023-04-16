CREATE OR REPLACE VIEW lab.vw_course_staff AS
SELECT     
    cs.course_staff_id,
    c.course_id,
    c."name"                    AS course_name, 
    u.user_id,
    u."name"                    AS username,  
    u.email                     AS user_email,
    ut."name"                   AS user_type,
    s."name"                    AS status_name
FROM lab.course_staff AS cs
INNER JOIN lab.course AS c 
    ON c.course_id = cs.course_id
INNER JOIN lab.user AS u 
    ON u.user_id = cs.user_id
INNER JOIN lab.user_type AS ut 
    ON ut.user_type_id = cs.user_type_id
LEFT JOIN lab.status AS s 
    ON s.status_id = cs.status_id;
