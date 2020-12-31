
CREATE VIEW [student].[vw_User]
AS
SELECT   UserId, Name, Email, Notes, sysCreatedAt, sysChangedAt, sysCreatedBy, sysChangedBy
FROM         dbo.[User]