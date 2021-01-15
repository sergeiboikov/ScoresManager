

CREATE VIEW [student].[vw_SubTask]
AS
SELECT   SubTaskId, TaskId, Name, Description, Topic, sysCreatedAt, sysChangedAt, sysCreatedBy, sysChangedBy
FROM         dbo.SubTask