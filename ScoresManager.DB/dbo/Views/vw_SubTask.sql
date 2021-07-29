



CREATE VIEW [dbo].[vw_SubTask]
AS
SELECT DISTINCT    
		   t. [TaskId]
		,  t. [Name]			AS [TaskName] 
		, st. [SubTaskId]		
		, st. [Name]			AS [SubTaskName]         
		, st. [Description]		AS [SubTaskDesc]
		, st. [MaxScore]		AS [MaxScore]
		,stt.TopicId			AS [SubTaskTopicId]
		,stt.[Name]				AS [SubTaskTopicName]
FROM [dbo].[SubTask] st
INNER JOIN [dbo].[Task] t ON t.TaskId = st.TaskId
INNER JOIN [dbo].[Topic] stt ON stt.TopicId = st.TopicId