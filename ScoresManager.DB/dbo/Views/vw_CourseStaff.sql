
CREATE VIEW [dbo].[vw_CourseStaff]
AS
SELECT	  c.[Name]  AS [CourseName]   
		, u.UserId
        , u.[Name]  AS [UserName]     
        ,ut.[Name]  AS [UserType]
FROM [dbo].[CourseStaff] cs
INNER JOIN [dbo].[Course] c ON c.CourseId = cs.CourseId
INNER JOIN [dbo].[User] u ON u.UserId = cs.UserId
INNER JOIN [dbo].[UserType] ut ON ut.UserTypeId = cs.UserTypeId

