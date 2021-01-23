

CREATE VIEW [student].[vw_Task]
AS
SELECT    t.TaskId
		, t.CourseId
		, t.Name
		, t.Description
		, tt.[Name] AS Topic
		, t.sysCreatedAt
		, t.sysChangedAt
		, t.sysCreatedBy
		, t.sysChangedBy
FROM         dbo.Task t
INNER JOIN dbo.TaskTopic tt ON tt.TaskTopicId = t.TaskTopicId