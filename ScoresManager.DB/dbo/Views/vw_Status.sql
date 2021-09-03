
CREATE VIEW [dbo].[vw_Status]
AS
SELECT    [StatusId]
		, [Name]         AS [StatusName]
        , [Description]  AS [StatusDesc]
FROM [dbo].[Status]