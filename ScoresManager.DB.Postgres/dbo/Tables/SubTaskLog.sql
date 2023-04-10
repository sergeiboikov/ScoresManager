﻿CREATE TABLE dbo.SubTaskLog (
    SubTaskLogId INT                NOT NULL,
    SubTaskId    INT                NOT NULL,
    StudentId    INT                NOT NULL,
    ReviewerId   INT                NULL,
    Score        NUMERIC (8, 2)                 CONSTRAINT DF_SubTaskLog_Score          DEFAULT ((0)) NOT NULL,
    OnTime       NUMERIC (8, 2)                 CONSTRAINT DF_SubTaskLog_OnTime         DEFAULT ((0)) NOT NULL,
    NameConv     NUMERIC (8, 2)                 CONSTRAINT DF_SubTaskLog_NameConv       DEFAULT ((0)) NOT NULL,
    Readability  NUMERIC (8, 2)                 CONSTRAINT DF_SubTaskLog_Readability    DEFAULT ((0)) NOT NULL,
    Sarg         NUMERIC (8, 2)                 CONSTRAINT DF_SubTaskLog_Sarg           DEFAULT ((0)) NOT NULL,
    SchemaName   NUMERIC (8, 2)                 CONSTRAINT DF_SubTaskLog_SchemaName     DEFAULT ((0)) NOT NULL,
    Aliases      NUMERIC (8, 2)                 CONSTRAINT DF_SubTaskLog_Aliases        DEFAULT ((0)) NOT NULL,
    DetermSort   NUMERIC (8, 2)                 CONSTRAINT DF_SubTaskLog_DetermSort     DEFAULT ((0)) NOT NULL,
    Accuracy     NUMERIC (8, 2)                 CONSTRAINT DF_SubTaskLog_Accuracy       DEFAULT ((0)) NOT NULL,
    Extra        NUMERIC (8, 2)                 CONSTRAINT DF_SubTaskLog_Extra          DEFAULT ((0)) NOT NULL,
    TotalScore   NUMERIC (8, 2)                 CONSTRAINT DF_SubTaskLog_TotalScore     DEFAULT ((0)) NOT NULL,
    Comment      VARCHAR (500)      NULL,
    sysCreatedAt TIMESTAMP                      CONSTRAINT DF_SubTaskLog_sysCreatedAt   DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysChangedAt TIMESTAMP                      CONSTRAINT DF_SubTaskLog_sysChangedAt   DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysCreatedBy INT                            CONSTRAINT DF_SubTaskLog_sysCreatedBy   DEFAULT ((-1)) NULL,
    sysChangedBy INT                            CONSTRAINT DF_SubTaskLog_sysChangedBy   DEFAULT ((-1)) NULL,
    CONSTRAINT PK_SubTaskLog PRIMARY KEY  (SubTaskLogId),
    CONSTRAINT FK_SubTaskLog_CourseStaff_ReviewerId FOREIGN KEY (ReviewerId) REFERENCES dbo.CourseStaff (CourseStaffId),
    CONSTRAINT FK_SubTaskLog_CourseStaff_StudentId FOREIGN KEY (StudentId) REFERENCES dbo.CourseStaff (CourseStaffId),
    CONSTRAINT FK_SubTaskLog_SubTask_SubTaskId FOREIGN KEY (SubTaskId) REFERENCES dbo.SubTask (SubTaskId),
    CONSTRAINT UC_SubTaskLog_SubTaskId_StudentId UNIQUE  (SubTaskId , StudentId)
);

CREATE SEQUENCE dbo.sq_dbo_SubTaskLog_SubTaskLogId START 1;