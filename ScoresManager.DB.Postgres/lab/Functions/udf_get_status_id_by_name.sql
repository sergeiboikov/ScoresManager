CREATE FUNCTION lab.udf_get_status_id_by_name(status_name VARCHAR(100))  
RETURNS SMALLINT   
AS   
-- Returns status_id for name
BEGIN  
    DECLARE ret int;  

    SELECT ret = s.status_id
    FROM lab.status s
    WHERE s."name" = status_name;

    RETURN ret;  
END;