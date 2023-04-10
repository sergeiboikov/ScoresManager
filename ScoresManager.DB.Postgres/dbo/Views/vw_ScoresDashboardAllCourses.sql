CREATE VIEW dbo.vw_ScoresDashboardAllCourses
AS
SELECT c.Name				AS CourseName
	 , t.Name				AS TaskName
	 , t.Description		AS TaskDesc
	 , tt.Name				AS TaskTopic
	 , st.SubTaskId			AS SubTaskId
	 , st.Name				AS SubTaskName
	 , st.Description		AS SubTaskDesc
	 , stt.Name				AS SubTaskTopicName
	 , cs1.CourseStaffId	AS StudentId
	 , u1.Name				AS StudentName
	 , cs2.CourseStaffId	AS ReviewerId
	 , u2.Name				AS ReviewerName
	 , stl.Score			AS Score
	 , stl.OnTime			AS OnTime
	 , stl.Accuracy			AS Accuracy
	 , stl.Extra			AS Extra
	 , stl.TotalScore		AS TotalScore
	 , stl.Comment			AS Comment
FROM dbo.SubTaskLog stl
INNER JOIN dbo.SubTask st ON st.SubTaskId = stl.SubTaskId
INNER JOIN dbo.Topic stt ON stt.TopicId = st.TopicId
INNER JOIN dbo.Task t ON t.TaskId = st.TaskId
INNER JOIN dbo.Topic tt ON tt.TopicId = t.TopicId
INNER JOIN dbo.Course c ON c.CourseId = t.CourseId
INNER JOIN dbo.CourseStaff cs1 ON cs1.CourseStaffId = stl.StudentId
INNER JOIN dbo.User u1 ON u1.UserId = cs1.UserId
INNER JOIN dbo.CourseStaff cs2 ON cs2.CourseStaffId = stl.ReviewerId
INNER JOIN dbo.User u2 ON u2.UserId = cs2.UserId;
