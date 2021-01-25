
CREATE VIEW [dbo].[vw_UserType]
AS
SELECT    [UserTypeId]
		, [Name]         AS [UserTypeName]
        , [Description]  AS [UserTypeDesc]
FROM [dbo].[UserType]