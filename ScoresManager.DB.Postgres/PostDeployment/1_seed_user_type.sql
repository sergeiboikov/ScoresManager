-- =============================================
-- Author:      Sergei Boikov
-- Create Date: 2023-04-16
-- Description: Query for populating initial values to the "user_type" table
-- =============================================

CALL mentor.usp_user_type_insert('[{"user_type_name":"mentor", "user_type_description":"Mentor"}, {"user_type_name":"student", "user_type_description":"Student"}]');