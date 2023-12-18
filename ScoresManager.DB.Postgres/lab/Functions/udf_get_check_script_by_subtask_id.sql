-- =============================================
-- Author:            Elyana Pogosyan
-- Create Date:        2021-10-30
-- Description:        Get data from check_script table for subtask_id in the JSON format
--                        Input parameter: "subtask_id" (int)
--                        Output: JSON in the following format: {check_script_text: Value, connection_string: Value, check_script_type_name: Value, connection_type_name: Value}
-- =============================================

CREATE FUNCTION lab.udf_get_check_script_by_subtask_id (subtask_id INT)  
RETURNS TEXT   
AS   
BEGIN  
    DECLARE json TEXT;  

    SET json = (
                   SELECT cs.text AS check_script_text
                        ,  c.connection_string
                        ,cst."name" AS check_script_type_name
                        , ct."name" AS connection_type_name
                    FROM lab.subtask st 
                        INNER JOIN lab.check_script        CS ON  cs.check_script_id      = st.check_script_id
                        INNER JOIN lab.connection         C ON   c.connection_id      = cs.connection_id
                        INNER JOIN lab.connection_type    CT ON  ct.connection_type_id  =  c.connection_type_id
                        INNER JOIN lab.check_script_type cst ON cst.check_script_type_id = cs.check_script_type_id
                    WHERE st.subtask_id = subtask_id
                    FOR JSON PATH
                );

    RETURN json;  
END;