CREATE OR REPLACE VIEW mentor.vw_check_script AS 
SELECT  
    st.subtask_id,
    st."name"                 AS subtask_name,
    t.task_id,
    t."name"                  AS task_name,
    c.course_id,
    c."name"                  AS course_name,
    cs.check_script_id,
    cs."text"                 AS check_script_text,
    cs.description            AS check_script_desc,
    cst."name"                AS check_script_type_name,
    cn.connection_string,
    ct."name"                 AS connection_type_name
FROM lab.subtask AS st    
INNER JOIN lab.task AS t
    ON t.task_id = st.task_id
INNER JOIN lab.course AS c
    ON c.course_id = t.course_id
INNER JOIN lab.check_script AS cs
    ON cs.check_script_id = st.check_script_id
INNER JOIN lab.check_script_type AS cst 
    ON cst.check_script_type_id = cs.check_script_type_id
INNER JOIN lab."connection" AS cn
    ON cn.connection_id = cs.connection_id
INNER JOIN lab.connection_type AS ct
    ON ct.connection_type_id = cn.connection_type_id;
