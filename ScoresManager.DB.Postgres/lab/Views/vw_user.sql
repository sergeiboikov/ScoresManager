CREATE OR REPLACE VIEW lab.vw_user AS
SELECT    
    u.user_id,
    u."name"    AS username,
    u.email     AS user_email,
    u.notes     AS user_notes
FROM lab.user AS u;
