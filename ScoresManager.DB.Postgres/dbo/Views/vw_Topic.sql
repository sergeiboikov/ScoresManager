CREATE VIEW dbo.vw_Topic
AS
SELECT	TopicId
	,	Name				AS TopicName
	,	IsTopicForTasks	
	,	IsTopicForSubTasks
FROM dbo.Topic;
