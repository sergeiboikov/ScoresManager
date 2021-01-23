

CREATE VIEW [dbo].[vw_SubTaskBonus_Pivoted]
AS
SELECT DISTINCT    
		   t.CourseId			AS [CourseId] 
		,  t.TaskId
		,  t.[Name]				AS [TaskName] 
		, st.SubTaskId	
		, st.[Name]				AS [SubTaskName]         
		, st.[Description]		AS [SubTaskDesc] 
		, st.TopicId			AS [SubTaskTopicId]
		, stt.[Name]			AS [SubTaskTopicName]
		, (SELECT CONVERT(Bit, 1) AS [IsNameConv]	FROM [dbo].[vw_SubTaskBonus] stb WHERE stb.SubTaskId = st.SubTaskId AND stb.BonusCode = N'NameConv')	AS [IsNameConv]
		, (SELECT CONVERT(Bit, 1) AS [IsRead]		FROM [dbo].[vw_SubTaskBonus] stb WHERE stb.SubTaskId = st.SubTaskId AND stb.BonusCode = N'Read')		AS [IsRead]
		, (SELECT CONVERT(Bit, 1) AS [IsSARG]		FROM [dbo].[vw_SubTaskBonus] stb WHERE stb.SubTaskId = st.SubTaskId AND stb.BonusCode = N'SARG')		AS [IsSARG]
		, (SELECT CONVERT(Bit, 1) AS [IsSchemaName]	FROM [dbo].[vw_SubTaskBonus] stb WHERE stb.SubTaskId = st.SubTaskId AND stb.BonusCode = N'SchemaName')	AS [IsSchemaName]
		, (SELECT CONVERT(Bit, 1) AS [IsAliases]	FROM [dbo].[vw_SubTaskBonus] stb WHERE stb.SubTaskId = st.SubTaskId AND stb.BonusCode = N'Aliases')		AS [IsAliases]
		, (SELECT CONVERT(Bit, 1) AS [IsDetermSort]	FROM [dbo].[vw_SubTaskBonus] stb WHERE stb.SubTaskId = st.SubTaskId AND stb.BonusCode = N'DetermSort')	AS [IsDetermSort]
FROM [dbo].[SubTask] st
INNER JOIN [dbo].[Task] t ON t.TaskId = st.TaskId
INNER JOIN [dbo].[Topic] stt ON stt.TopicId = st.TopicId