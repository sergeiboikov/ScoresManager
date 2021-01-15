

CREATE VIEW [student].[vw_Task]
AS
SELECT   TaskId, CourseId, Name, Description, Topic, sysCreatedAt, sysChangedAt, sysCreatedBy, sysChangedBy
FROM         dbo.Task