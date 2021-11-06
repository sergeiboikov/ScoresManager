DECLARE @JSON_CONFIG  NVARCHAR(MAX);
SELECT @JSON_CONFIG = N'[{"ConnectionName":"ODBC", "ConnectionDescription":"Application setting name in Function App Configuration (ODBC connection string)"}]'

EXEC [dbo].[usp_ConnectionType_Insert] @JSON_CONFIG
GO