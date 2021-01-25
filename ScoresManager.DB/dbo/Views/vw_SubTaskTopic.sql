



CREATE VIEW [dbo].[vw_SubTaskTopic]
AS
SELECT	  [TopicId]
	,	  [Name]				AS [SubTaskTopicName]
FROM [dbo].[Topic]
WHERE [IsTopicForSubTasks] = 1