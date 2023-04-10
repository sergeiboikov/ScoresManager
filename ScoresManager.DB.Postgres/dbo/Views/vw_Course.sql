CREATE VIEW dbo.vw_Course
AS
SELECT		CourseId	  
		,	Name AS CourseName
		,	Datestart 
		,	Datefinish
FROM dbo.Course;
