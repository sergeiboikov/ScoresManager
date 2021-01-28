

/****** Object:  View [dbo].[vw_SubTaskLog]    Script Date: 12/30/2020 4:10:54 PM ******/
CREATE VIEW [dbo].[vw_SubTaskLog]
AS
SELECT	  stl.SubTaskLogId
		,	c.CourseId
		,   c.[Name]			AS [CourseName]
		,   t.TaskId
		,   t.[Name]			AS [TaskName]
		,  st.SubTaskId
		,  st.[Name]			AS [SubTaskName] 
		,  cs1.CourseStaffId	AS [StudentId]
		,  u1.[Name]			AS [StudentName]   
		,  cs2.CourseStaffId	AS [ReviewerId]
		,  u2.[Name]			AS [ReviewerName]  
		, stl.[Score]       
		, stl.[OnTime]      
		, stl.[Accuracy]    
		, stl.[Extra]       
		, stl.[TotalScore]  
		, stl.[Comment]     
FROM [dbo].[SubTaskLog] stl
INNER JOIN [dbo].[SubTask] st ON st.SubTaskId = stl.SubTaskId
INNER JOIN [dbo].[Task] t ON t.TaskId = st.TaskId
INNER JOIN [dbo].[Course] c ON c.CourseId = t.CourseId
INNER JOIN [dbo].[CourseStaff] cs1 ON cs1.CourseStaffId = stl.StudentId
INNER JOIN [dbo].[User] u1 ON u1.UserId = cs1.UserId
INNER JOIN [dbo].[CourseStaff] cs2 ON cs2.CourseStaffId = stl.ReviewerId
INNER JOIN [dbo].[User] u2 ON u2.UserId = cs2.UserId