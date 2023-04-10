CREATE VIEW dbo.vw_TaskTopic
AS
SELECT	  t.TopicId
	,	  t."name"				AS TaskTopicName
FROM dbo.Topic t
WHERE IsTopicForTasks = CAST(1 AS BIT);
