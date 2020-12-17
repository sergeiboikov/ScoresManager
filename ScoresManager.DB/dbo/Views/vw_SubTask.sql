CREATE VIEW [dbo].[vw_SubTask]
AS
SELECT     t.[Name]			AS [TaskName] 
		, st.[Name]			AS [SubTaskName]         
		, st.[Description]  AS [SubTaskDesc]
		, st.[Topic]		AS [SubTaskTopic]        
FROM [dbo].[SubTask] st
INNER JOIN [dbo].[Task] t ON t.TaskId = st.TaskId