CREATE TABLE dbo.Task (
    TaskId       INT                NOT NULL,
    CourseId     INT                NOT NULL,
    Name         VARCHAR (250)      NOT NULL,
    Description  VARCHAR (250)      NOT NULL,
    TopicId      SMALLINT           NOT NULL,
    sysCreatedAt TIMESTAMP          CONSTRAINT DF_Task_sysCreatedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysChangedAt TIMESTAMP          CONSTRAINT DF_Task_sysChangedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysCreatedBy INT                CONSTRAINT DF_Task_sysCreatedBy DEFAULT ((-1)) NULL,
    sysChangedBy INT                CONSTRAINT DF_Task_sysChangedBy DEFAULT ((-1)) NULL,
    CONSTRAINT PK_Task PRIMARY KEY  (TaskId),
    CONSTRAINT FK_Task_Course_CourseId FOREIGN KEY (CourseId) REFERENCES dbo.Course (CourseId),
    CONSTRAINT FK_Task_Topic_TopicId FOREIGN KEY (TopicId) REFERENCES dbo.Topic (TopicId),
    CONSTRAINT UC_Task_CourseId_Name UNIQUE  (CourseId , Name)
);

CREATE SEQUENCE dbo.sq_dbo_Task_TaskId START 1;