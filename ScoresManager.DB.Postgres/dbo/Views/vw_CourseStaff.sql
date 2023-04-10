CREATE VIEW dbo.vw_CourseStaff
AS
SELECT	 cs.CourseStaffId
		, c.CourseId
		, c.Name  AS CourseName   
		, u.UserId
        , u.Name  AS UserName     
		, u.Email  AS UserEmail
        ,ut.Name  AS UserType
		, s.Name  AS StatusName
FROM dbo.CourseStaff cs
INNER JOIN dbo.Course c ON c.CourseId = cs.CourseId
INNER JOIN dbo.User u ON u.UserId = cs.UserId
INNER JOIN dbo.UserType ut ON ut.UserTypeId = cs.UserTypeId
LEFT JOIN dbo.Status s ON s.StatusId = cs.StatusId;
