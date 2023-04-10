-- =============================================
-- Author:			Elyana Pogosyan
-- Create Date:		2021-10-30
-- Description:		Get data from CheckScript table for SubTaskId in the JSON format
--						Input parameter: "SubTaskId" (int)
--						Output: JSON in the following format: {CheckScriptText: Value, ConnectionString: Value, CheckScriptTypeName: Value, ConnectionTypeName: Value}
-- =============================================

CREATE FUNCTION dbo.udf_get_CheckScript_by_SubTaskId (@SubTaskId INT)  
RETURNS TEXT   
AS   
BEGIN  
    DECLARE @json TEXT;  

    SET @json = (
				   SELECT CS.Text AS CheckScriptText
						,  C.ConnectionString
						,CST.Name AS CheckScriptTypeName
						, CT.Name AS ConnectionTypeName
					FROM dbo.SubTask ST 
						INNER JOIN dbo.CheckScript		CS ON  CS.CheckScriptId	  = ST.CheckScriptId
						INNER JOIN dbo.Connection		 C ON   C.ConnectionId	  = CS.ConnectionId
						INNER JOIN dbo.ConnectionType	CT ON  CT.ConnectionTypeId  =  C.ConnectionTypeId
						INNER JOIN dbo.CheckScriptType CST ON CST.CheckScriptTypeId = CS.CheckScriptTypeId
					WHERE ST.SubTaskId = @SubTaskId
					FOR JSON PATH
				);

    RETURN @json;  
END;