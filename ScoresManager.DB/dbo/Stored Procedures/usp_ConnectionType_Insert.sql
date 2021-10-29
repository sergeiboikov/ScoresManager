-- =============================================
-- Author:			Elyana Pogosyan
-- Create Date:		2021-10-26
-- Description: Load information for CheckScriptType from JSON
-- Format JSON: N'["ConnectionName":"ODBC", "ConnectionDescription":"Open Database Connectivity"]' 
--  Example: EXEC [dbo].[usp_ConnectionType_Insert] @json = N'["ConnectionName":"ODBC", "ConnectionDescription":"Open Database Connectivity"]'  

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
                         ConnectionName			 NVARCHAR(250)	 '$.ConnectionName'
						,ConnectionDescription	 NVARCHAR(250)	 '$.ConnectionDescription'
                ) AS RootL;

				-- ConnectionType insert

				MERGE INTO [dbo].[ConnectionType] tgt
				USING (
						SELECT DISTINCT  tmp.[ConnectionName]
										,tmp.[ConnectionDescription]
						FROM #TEMP_SOURCE AS tmp
					 ) src ON (TRIM(UPPER(src.[ConnectionName])) = TRIM(UPPER(tgt.[Name])))
				WHEN MATCHED THEN
				UPDATE SET
					 tgt.[Description]	= src.[ConnectionDescription]
					,tgt.[sysChangedAt]	= getutcdate()
				WHEN NOT MATCHED THEN
				INSERT (
					 [Name]
					,[Description]
				) VALUES
				(
					 src.[ConnectionName]
					,src.[ConnectionDescription]
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