

CREATE VIEW [student].[vw_SubTask]
AS
SELECT    st.SubTaskId
		, st.TaskId
		, st.Name
		, st.Description
		, stt.[Name] AS Topic
		, st.sysCreatedAt
		, st.sysChangedAt
		, st.sysCreatedBy
		, st.sysChangedBy
FROM         dbo.SubTask st
INNER JOIN [dbo].[SubTaskTopic] stt ON stt.SubTaskTopicId = st.SubTaskTopicId