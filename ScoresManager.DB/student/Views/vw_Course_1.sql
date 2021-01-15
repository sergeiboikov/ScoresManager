

CREATE VIEW [student].[vw_Course]
AS
SELECT   CourseId, Name, Datestart, Datefinish, sysCreatedAt, sysChangedAt, sysCreatedBy, sysChangedBy
FROM         dbo.Course