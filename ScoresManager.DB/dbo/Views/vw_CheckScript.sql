﻿CREATE VIEW [dbo].[vw_CheckScript]
AS 
SELECT  ST.[SubTaskId]
	,	ST.[Name]			AS [SubTaskName]
	,	CS.[CheckScriptId]
	,	CS.[Text]			AS [CheckScriptText]
	,	CS.[Description]	AS [CheckScriptDesc]
	,	CST.[Name]			AS [CheckScriptTypeName]
	,	C.[ConnectionString]
	,	CT.[Name]			AS [ConnectionTypeName]
FROM		   [dbo].[SubTask]			ST	
	INNER JOIN [dbo].[CheckScript]		CS	ON CS.[CheckScriptId]	   = ST.[CheckScriptId]
	INNER JOIN [dbo].[CheckScriptType]	CST ON CST.[CheckScriptTypeId] = CS.[CheckScriptTypeId]
	INNER JOIN [dbo].[Connection]		C	ON C.[ConnectionId]		   = CS.[ConnectionId]
	INNER JOIN [dbo].[ConnectionType]	CT	ON CT.[ConnectionTypeId]   = C.[ConnectionTypeId]
