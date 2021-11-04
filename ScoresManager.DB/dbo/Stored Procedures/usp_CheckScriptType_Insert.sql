-- =============================================
-- Author:			Elyana Pogosyan
-- Create Date:		2021-10-26
-- Modified By:		Sergei Boikov
-- Modified Date:	2021-10-31
-- Description: Load information for CheckScriptType from JSON
-- Format JSON: N'[{"CheckScriptTypeName":"SQL"}]' 
--  Example: EXEC [dbo].[usp_CheckScriptType_Insert] @json = N'[{"CheckScriptTypeName":"SQL"}]' 

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
				MERGE INTO [dbo].[CheckScriptType] tgt
				USING (
					SELECT tmp.[CheckScriptTypeName]
					FROM #TEMP_SOURCE tmp
				) src 
					ON (TRIM(UPPER(src.[CheckScriptTypeName])) = TRIM(UPPER(tgt.[Name])))
				WHEN NOT MATCHED BY TARGET THEN
				INSERT (
					 [Name]
				) VALUES
				(
					 src.[CheckScriptTypeName]
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