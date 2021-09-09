CREATE FUNCTION dbo.udf_get_StatusId_by_Name(@StatusName NVARCHAR(100))  
RETURNS SMALLINT   
AS   
-- Returns StatusId for Name
BEGIN  
    DECLARE @ret int;  

    SELECT @ret = s.StatusId
    FROM [dbo].[Status] s
    WHERE s.[Name] = @StatusName;

    RETURN @ret;  
END;