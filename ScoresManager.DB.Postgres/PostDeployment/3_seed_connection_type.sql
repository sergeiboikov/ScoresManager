-- =============================================
-- Author:      Sergei Boikov
-- Create Date: 2023-04-16
-- Description: Query for populating initial values to the "connection_type" table
-- =============================================

CALL mentor.usp_connection_type_insert('[{"connection_type_name":"ODBC", "connection_type_description":"Application setting name in Function App Configuration (ODBC connection string)"}]');