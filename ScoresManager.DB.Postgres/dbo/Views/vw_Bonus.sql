CREATE VIEW dbo.vw_Bonus
AS
SELECT	  BonusId
	,	  Name					AS BonusName
	,	  Description			AS BonusDesc
	,	  Code					AS BonusCode
FROM dbo.Bonus;
