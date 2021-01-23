

CREATE VIEW [dbo].[vw_Task]
AS
SELECT		c.[CourseId] 
		 ,	c.[Name]			AS [CourseName]
		 ,  t.TaskId
		 ,  t.[Name]			AS [TaskName]    
		 ,  t.[Description]		AS [TaskDesc]
		 ,  tt.[Name]			AS [TaskTopic]        
FROM [dbo].[Task] t
INNER JOIN [dbo].[Course] c ON c.CourseId = t.CourseId
INNER JOIN [dbo].[TaskTopic] tt ON tt.TaskTopicId = t.TaskTopicId