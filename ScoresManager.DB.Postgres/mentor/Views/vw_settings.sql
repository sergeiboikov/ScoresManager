CREATE OR REPLACE VIEW mentor.vw_settings AS
SELECT     
    s.settings_id,
    s.setting_name,
    s.setting_value,
    u.user_id,
    u.email AS user_email
FROM lab.settings AS s
INNER JOIN lab.user AS u 
    ON u.user_id = s.user_id;
