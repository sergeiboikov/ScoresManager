-- =============================================
-- Author:			Elyana Pogosyan
-- Create Date:		2021-10-26
-- Description: Load information for CheckScriptType from JSON
-- Format JSON: N'["CheckScriptTypeName":"SQL"]' 
--  Example: EXEC [dbo].[usp_CheckScriptType_Insert] @json = N'["CheckScriptTypeName":"SQL"]' 

-- =============================================


CREATE PROCEDURE [dbo].[usp_CheckScriptType_Insert]
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
                         CheckScriptTypeName NVARCHAR(250)	 '$.CheckScriptTypeName'
                ) AS RootL;

				-- CheckScriptType insert

				INSERT INTO [dbo].[CheckScriptType] (Name)
				SELECT tmp.[CheckScriptTypeName]
				FROM #TEMP_SOURCE tmp;

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