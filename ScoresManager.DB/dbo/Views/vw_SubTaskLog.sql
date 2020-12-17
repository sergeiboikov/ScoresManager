CREATE VIEW [dbo].[vw_SubTaskLog]
AS
SELECT    st.[Name]         AS [SubTaskName]   
       ,  u1.[Name]         AS [StudentName]   
       ,  u2.[Name]         AS [ReviewerName]  
       , stl.[Score]       
       , stl.[OnTime]      
       , stl.[Accuracy]    
       , stl.[Extra]       
       , stl.[TotalScore]  
       , stl.[Comment]     
FROM [dbo].[SubTaskLog] stl
INNER JOIN [dbo].[SubTask] st ON st.SubTaskId = stl.SubTaskId
INNER JOIN [dbo].[User] u1 ON u1.UserId = stl.StudentId
INNER JOIN [dbo].[User] u2 ON u2.UserId = stl.ReviewerId