CREATE VIEW [dbo].[vw_Task]
AS
SELECT     c.[Name]			AS [CourseName]
		,  t.[Name]			AS [TaskName]    
		,  t.[Description]  AS [TaskDesc]
		,  t.[Topic]		AS [TaskTopic]        
FROM [dbo].[Task] t
INNER JOIN [dbo].[Course] c ON c.CourseId = t.CourseId