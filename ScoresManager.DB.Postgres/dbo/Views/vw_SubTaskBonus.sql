CREATE VIEW dbo.vw_SubTaskBonus
AS
SELECT	stb.SubTaskBonusId
	,	stb.SubTaskId
	,	 st.Name				AS SubTaskName
	,	stb.BonusId
	,	  b.Name				AS BonusName
	,	  b.Code				AS BonusCode
FROM dbo.SubTaskBonus stb
INNER JOIN dbo.SubTask st ON st.SubTaskId = stb.SubTaskId
INNER JOIN dbo.Bonus b ON b.BonusId = stb.BonusId;
