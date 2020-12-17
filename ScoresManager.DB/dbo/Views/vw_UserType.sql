CREATE VIEW [dbo].[vw_UserType]
AS
SELECT    [Name]         AS [UserTypeName]
        , [Description]  AS [UserTypeDesc]
FROM [dbo].[UserType]