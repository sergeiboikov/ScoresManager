-- =============================================
-- Author:			Elyana Pogosyan
-- Create Date:		2021-10-26
-- Description: Load information for CheckScriptType from JSON
-- Format JSON: N'[{"ConnectionTypeName":"ODBC", "ConnectionTypeDescription":"Open Database Connectivity"}]' 
--  Example: EXEC [dbo].[usp_ConnectionType_Insert] @json = N'[{"ConnectionTypeName":"ODBC", "ConnectionTypeDescription":"Open Database Connectivity"}]'  

-- =============================================


CREATE PROCEDURE [dbo].[usp_ConnectionType_Insert]
(
    @json NVARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;

IF ISJSON(@json) > 0
	BEGIN
        BEGIN TRY
	        BEGIN TRANSACTION
                DROP TABLE IF EXISTS #TEMP_SOURCE;

			    SELECT *
			    INTO #TEMP_SOURCE
				FROM OPENJSON(@json)
                WITH (
                         ConnectionTypeName			 NVARCHAR(250)	 '$.ConnectionTypeName'
						,ConnectionTypeDescription	 NVARCHAR(250)	 '$.ConnectionTypeDescription'
                ) AS RootL;

				-- ConnectionType insert

				MERGE INTO [dbo].[ConnectionType] tgt
				USING (
						SELECT DISTINCT  tmp.[ConnectionTypeName]
										,tmp.[ConnectionTypeDescription]
						FROM #TEMP_SOURCE AS tmp
					 ) src ON (TRIM(UPPER(src.[ConnectionTypeName])) = TRIM(UPPER(tgt.[Name])))
				WHEN MATCHED THEN
				UPDATE SET
					 tgt.[Description]	= src.[ConnectionTypeDescription]
					,tgt.[sysChangedAt]	= getutcdate()
				WHEN NOT MATCHED THEN
				INSERT (
					 [Name]
					,[Description]
				) VALUES
				(
					 src.[ConnectionTypeName]
					,src.[ConnectionTypeDescription]
				);


				DROP TABLE #TEMP_SOURCE;
            COMMIT TRANSACTION
        END TRY
        BEGIN CATCH
	            IF @@TRANCOUNT > 0 
		            ROLLBACK TRANSACTION;
	            THROW;
        END CATCH;
    END
END