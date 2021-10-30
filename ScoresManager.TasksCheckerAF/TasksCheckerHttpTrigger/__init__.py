import logging
import azure.functions as func
import pyodbc
import pandas as pd
import os

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
        print(ex.args[0])
        return
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

def get_template(subtask_id: str):
    pass

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    subtask_id = req.params.get('subtask_id')
    query_user = req.params.get('query_user')

    query_user = """
    SELECT 1
    """

    query_check = """
    SELECT 1
    """

    compare_result = compare_sql_queries(db_connection_string, query_user, query_check)

    if not subtask_id:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            subtask_id = req_body.get('subtask_id')

    if subtask_id:
        return func.HttpResponse(f"{compare_result}")
    else:
        return func.HttpResponse(
             "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.",
             status_code=200
        )
