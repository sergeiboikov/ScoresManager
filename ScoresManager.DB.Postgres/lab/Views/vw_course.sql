CREATE OR REPLACE VIEW lab.vw_course AS
SELECT        
    c.course_id,
    c."name"            AS course_name,
    c.datestart,
    c.datefinish
FROM lab.course AS c;
