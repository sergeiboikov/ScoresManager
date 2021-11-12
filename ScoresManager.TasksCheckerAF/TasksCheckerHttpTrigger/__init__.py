import logging
import azure.functions as func
import pyodbc
import pandas as pd
import os
import json 

# access sensitive credentials from Azure Key Vault (Application settings)
scoresmanager_db_connection_string = os.getenv('ScoresManagerDBConnectionStringFromKeyVault_DEV')

def compare_sql_queries(connection: str, user_query: str, check_query: str) -> str:
    """
    The function executes user_query and check_query and compares result 

    :param connection: Connection where queries will be executed
    :type connection: str
    :param user_query: Users' query for validating
    :type user_query: str
    :param check_query: Template query
    :type check_query: str
    :return: Result of validating. If result is correct returns SUCCESS. If the result is wrong, returns ERROR with description
    :rtype: str
    """
    errors = list()
    success = 'SUCCESS'
    # Set parameters
    cnxn = pyodbc.connect(connection)
    try:
        df_user = pd.read_sql_query(user_query, cnxn)
    except Exception as ex:
        errors.append(f'ERROR. Wrong syntax')
        return errors
    df_check = pd.read_sql_query(check_query, cnxn)
    # Check row counts
    if len(df_user) != len(df_check):
        errors.append(f'ERROR. Wrong number of records (Expected: {len(df_check)}. Received: {len(df_user)})')
    # Check column counts
    if len(df_user.columns) != len(df_check.columns):
        errors.append(f'ERROR. Wrong number of columns (Expected: {len(df_check.columns)}. Received: {len(df_user.columns)})')
    # Check column names
    if set(df_user.columns) != set(df_check.columns):
        errors.append(f'ERROR. Wrong column names (Expected: {df_check.columns.values}. Received: {df_user.columns.values})')
    # Check dataframes for equality
    if not df_user.equals(df_check):
        errors.append(f'ERROR. Wrong result')
    # Output
    if errors:
        return errors
    else:
        return success

def get_check_script_info(con: str, subtask_id: str) -> dict:
    """
    Get info about check script from ScoresManager DB

    :param con: Connection to ScoresManager database
    :type con: str
    :param subtask_id: SubTaskId
    :type subtask_id: str
    :return: Dictionary in format: {CheckScriptText: Value, ConnectionString: Value, CheckScriptTypeName: Value, ConnectionTypeName: Value}
    :rtype: dict
    """
    cnxn = pyodbc.connect(con)
    curs = cnxn.cursor()
    curs.execute(f'SELECT [dbo].[udf_get_CheckScript_by_SubTaskId] ({subtask_id})')
    result = curs.fetchone()
    # Expected result: {'CheckScriptText': 'SELECT 1', 'ConnectionString': 'AdventureWorks2019ConnectionStringFromKeyVault', 'CheckScriptTypeName': 'SQL', 'ConnectionTypeName': 'ODBC'}
    return json.loads(result[0])[0]

def get_odbc_conn_str_from_key_vault(app_setting_name: str) -> str:
    """
    The function return ODBC connection string from Azure KeyVault. Link to the Azure KeysVault secret is
    get from App configuration of Azure Function

    :param app_setting_name: App configuration name
    :type app_setting_name: str
    :return: ODBC connection string
    :rtype: str
    """
    return os.getenv(app_setting_name)

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    subtask_id = req.params.get('subtask_id')
    query_user = req.params.get('query_user')

    if not subtask_id:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            subtask_id = req_body.get('subtask_id')

    if not query_user:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            query_user = req_body.get('query_user')

    if subtask_id and query_user:
        check_script_odbc_conn = ''
        compare_result = ''
        # Get info about Subtask from ScoresManager db
        check_script_info = get_check_script_info(scoresmanager_db_connection_string, subtask_id)
        check_script_text = check_script_info['CheckScriptText']
        check_script_conn_str = check_script_info['ConnectionString']
        check_script_type = check_script_info['CheckScriptTypeName']
        check_script_conn_type = check_script_info['ConnectionTypeName']
        if check_script_conn_type == 'ODBC':
            check_script_odbc_conn = get_odbc_conn_str_from_key_vault(check_script_conn_str)
        if check_script_type == 'SQL':
            compare_result = compare_sql_queries(check_script_odbc_conn, query_user, check_script_text)
        return func.HttpResponse(f"{compare_result}")
    else:
        return func.HttpResponse(
             "Pass a subtask_id and a query_user in the query string or in the request body.",
             status_code=200
        )
