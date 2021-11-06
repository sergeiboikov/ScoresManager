DECLARE @JSON_CONFIG  NVARCHAR(MAX);
SELECT @JSON_CONFIG = N'[{"ConnectionTypeName":"ODBC", "ConnectionTypeDescription":"Application setting name in Function App Configuration (ODBC connection string)"}]'

EXEC [dbo].[usp_ConnectionType_Insert] @JSON_CONFIG
GO