

CREATE VIEW [student].[vw_CourseStaff]
AS
SELECT   CourseStaffId, CourseId, UserId, UserTypeId, sysCreatedAt, sysChangedAt, sysCreatedBy, sysChangedBy
FROM         dbo.CourseStaff