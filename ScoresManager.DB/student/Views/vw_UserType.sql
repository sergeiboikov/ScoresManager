
CREATE VIEW [student].[vw_UserType]
AS
SELECT   UserTypeId, Name, Description, sysCreatedAt, sysChangedAt, sysCreatedBy, sysChangedBy
FROM         dbo.UserType