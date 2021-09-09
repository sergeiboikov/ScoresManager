CREATE VIEW [dbo].[vw_Student]
AS
SELECT u.UserId				AS UserId
	 , u.[Name]				AS UserName
	 , s.[Name]				AS StatusName
FROM dbo.CourseStaff cs
INNER JOIN dbo.UserType ut ON ut.UserTypeId = cs.UserTypeId
	AND ut.[Name] = 'Student'
INNER JOIN dbo.[User] u ON u.UserId = cs.UserId
LEFT JOIN dbo.[Status] s ON s.StatusId = cs.StatusId