CREATE TABLE dbo.SubTask (
    SubTaskId     INT               NOT NULL,
    TaskId        INT               NOT NULL,
    Name          VARCHAR (250)     NOT NULL,
    Description   TEXT              NOT NULL,
    TopicId       SMALLINT          NOT NULL,
    CheckScriptId INT               NULL,
    MaxScore      NUMERIC  (8,2)    NULL,
    sysCreatedAt  TIMESTAMP         CONSTRAINT DF_SubTask_sysCreatedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysChangedAt  TIMESTAMP         CONSTRAINT DF_SubTask_sysChangedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysCreatedBy  INT               CONSTRAINT DF_SubTask_sysCreatedBy DEFAULT ((-1)) NULL,
    sysChangedBy  INT               CONSTRAINT DF_SubTask_sysChangedBy DEFAULT ((-1)) NULL,
    CONSTRAINT PK_SubTask PRIMARY KEY  (SubTaskId),
    CONSTRAINT FK_SubTask_Task_TaskId FOREIGN KEY (TaskId) REFERENCES dbo.Task (TaskId),
    CONSTRAINT FK_SubTask_Topic_TopicId FOREIGN KEY (TopicId) REFERENCES dbo.Topic (TopicId),
    CONSTRAINT UC_SubTask_TaskId_Name UNIQUE  (TaskId , Name), 
    CONSTRAINT FK_SubTask_CheckScript_CheckScriptId FOREIGN KEY (CheckScriptId) REFERENCES dbo.CheckScript(CheckScriptId)
);

CREATE SEQUENCE dbo.sq_dbo_SubTask_SubTaskId START 1;
