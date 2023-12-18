-- =============================================
-- Author:      Sergei Boikov
-- Create Date: 2023-04-16
-- Description: Query for populating initial values to the "check_script_type" table
-- =============================================

CALL mentor.usp_check_script_type_insert('["SQL"]');