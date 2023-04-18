/*========================================================================================================================
 * created by: Sergei Boikov
 * created at: Apr 18, 2023
 * comment   : Query for grant permissions to ScoresManagerDB
 * 
========================================================================================================================*/

/*========================================================================================================================
 * Grant permissions for mentor
========================================================================================================================*/

CREATE USER mentor WITH PASSWORD '{pwd}';

GRANT USAGE ON SCHEMA mentor TO mentor;
GRANT SELECT ON ALL TABLES IN SCHEMA mentor TO mentor;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA mentor TO mentor;