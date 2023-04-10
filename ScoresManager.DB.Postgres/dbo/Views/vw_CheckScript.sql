﻿ dbo.vw_CheckScript
AS 
SELECT  ST.SubTaskId
	,	ST.Name				AS SubTaskName
	,	T.TaskId
	,	T.Name				AS TaskName
	,	C.CourseId
	,	C.Name				AS CourseName
	,	CS.CheckScriptId
	,	CS.Text				AS CheckScriptText
	,	CS.Description		AS CheckScriptDesc
	,	CST.Name			AS CheckScriptTypeName
	,	CN.ConnectionString
	,	CT.Name				AS ConnectionTypeName
FROM		  dbo.SubTask			ST	
	INNER JOIN dbo.Task				T	ON	 T.TaskId			   	= ST.TaskId
	INNER JOIN dbo.Course			C	ON	 C.CourseId		   		=  T.CourseId
	INNER JOIN dbo.CheckScript		CS	ON  CS.CheckScriptId	   	= ST.CheckScriptId
	INNER JOIN dbo.CheckScriptType	CST ON CST.CheckScriptTypeId 	= CS.CheckScriptTypeId
	INNER JOIN dbo.Connection		CN	ON  CN.ConnectionId	   		= CS.ConnectionId
	INNER JOIN dbo.ConnectionType	CT	ON  CT.ConnectionTypeId 	=  CN.ConnectionTypeId;
