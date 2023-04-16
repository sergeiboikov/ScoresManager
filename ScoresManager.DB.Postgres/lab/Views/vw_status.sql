CREATE OR REPLACE VIEW lab.vw_status AS
SELECT    
    s.status_id,
    s."name"         AS status_name,
    s.description    AS status_desc
FROM lab.status AS s;
