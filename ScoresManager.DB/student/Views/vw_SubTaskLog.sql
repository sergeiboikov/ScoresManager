
CREATE VIEW [student].[vw_SubTaskLog]
AS
SELECT   SubTaskLogId, SubTaskId, StudentId, ReviewerId, Score, OnTime, Accuracy, Extra, TotalScore, Comment, sysCreatedAt, sysChangedAt, sysCreatedBy, sysChangedBy
FROM         dbo.SubTaskLog