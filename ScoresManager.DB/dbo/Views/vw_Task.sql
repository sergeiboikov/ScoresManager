


CREATE VIEW [dbo].[vw_Task]
AS
SELECT		c.[CourseId] 
		 ,	c.[Name]			AS [CourseName]
		 ,  t.TaskId
		 ,  t.[Name]			AS [TaskName]    
		 ,  t.[Description]		AS [TaskDesc]
		 ,  tt.[Name]			AS [Topic]        
FROM [dbo].[Task] t
INNER JOIN [dbo].[Course] c ON c.CourseId = t.CourseId
INNER JOIN [dbo].[Topic] tt ON tt.TopicId = t.TopicId