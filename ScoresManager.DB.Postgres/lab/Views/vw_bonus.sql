CREATE OR REPLACE VIEW lab.vw_bonus AS
SELECT
	b.bonus_id,
	b."name"			AS bonus_name,
    b.description		AS bonus_desc,
    b.code			    AS bonus_code
FROM lab.bonus AS b;
