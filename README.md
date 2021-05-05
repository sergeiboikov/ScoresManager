# ScoresManager

##Description
The application allows entering information about an education course and monitor students' performance through dashboard (Power BI): 
The application contains the following information about a course:
- Course info (course name, datestart, datefinish);
- Users (user name, Email);
- Course staff (students, mentors);
- Tasks (task name, description, course, topic);
- Subtask (subtask name, topic, description, possible bonuses for the subtask)
- Topics for tasks (subtasks)
- Scores (task, subtask, student, reviewer, subtask, score, etc.)

##Architecture
![image](https://user-images.githubusercontent.com/46808009/117140853-e908ed80-adbe-11eb-9284-dc97f311242a.png)

##Installation
1. Build and deploy DB from ScoresManager.DB project to SQL Server;
2. Publish canvas powerapps application from ScoresManager.PowerApps folder. As a source you need to choose DB from the first step;
3. Publish power bi report from ScoresManager.PowerBI folder. As a source you need to choose DB from the first step.
