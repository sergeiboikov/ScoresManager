CREATE OR REPLACE VIEW lab.vw_user_type AS
SELECT    
    ut.user_type_id,
    ut."name"       AS user_type_name,
    ut.description  AS user_typeDesc
FROM lab.user_type AS ut;
