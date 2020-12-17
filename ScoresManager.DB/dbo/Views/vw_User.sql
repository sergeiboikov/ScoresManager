CREATE VIEW [dbo].[vw_User]
AS
SELECT   ut.[Name]      AS [UserType]
        , u.[Name]      AS [UserName]
        , u.[Email]     AS [UserEmail]  
        , u.[Notes]     AS [UserNotes]  
FROM [dbo].[User] u
INNER JOIN [dbo].[UserType] ut ON ut.UserTypeId = u.UserTypeId