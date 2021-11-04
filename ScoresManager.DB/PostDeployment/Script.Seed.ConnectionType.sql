DECLARE @JSON_CONFIG  NVARCHAR(MAX);
SELECT @JSON_CONFIG = N'[{"ConnectionName":"FunctionApp", "ConnectionDescription":"Application setting name in Function App Configuration"}]'

EXEC [dbo].[usp_ConnectionType_Insert] @JSON_CONFIG
GO