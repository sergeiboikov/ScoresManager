


CREATE VIEW [dbo].[vw_TaskTopic]
AS
SELECT	  [TopicId]
	,	  [Name]				AS [TaskTopicName]
FROM [dbo].[Topic]
WHERE [IsTopicForTasks] = 1