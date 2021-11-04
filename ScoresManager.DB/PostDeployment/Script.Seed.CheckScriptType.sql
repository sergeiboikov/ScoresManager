DECLARE @JSON_CONFIG  NVARCHAR(MAX);
SELECT @JSON_CONFIG = N'[{"CheckScriptTypeName":"SQL"}]'

EXEC [dbo].[usp_CheckScriptType_Insert] @JSON_CONFIG
GO