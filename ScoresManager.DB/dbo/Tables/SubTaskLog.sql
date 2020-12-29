CREATE TABLE [dbo].[SubTaskLog] (
    [SubTaskLogId] INT            IDENTITY (1, 1) NOT NULL,
    [SubTaskId]    INT            NOT NULL,
    [StudentId]    INT            NOT NULL,
    [ReviewerId]   INT            NULL,
    [Score]        NUMERIC (8, 2) DEFAULT ((0)) NOT NULL,
    [OnTime]       NUMERIC (8, 2) DEFAULT ((0)) NOT NULL,
    [Accuracy]     NUMERIC (8, 2) DEFAULT ((0)) NOT NULL,
    [Extra]        NUMERIC (8, 2) DEFAULT ((0)) NOT NULL,
    [TotalScore]   AS             ((([Score]+[OnTime])+[Accuracy])+[Extra]),
    [Comment]      NVARCHAR (500) NULL,
    [sysCreatedAt] DATETIME       CONSTRAINT [DF_SubTaskLog_sysCreatedAt] DEFAULT (getutcdate()) NULL,
    [sysChangedAt] DATETIME       CONSTRAINT [DF_SubTaskLog_sysChangedAt] DEFAULT (getutcdate()) NULL,
    [sysCreatedBy] INT            CONSTRAINT [DF_SubTaskLog_sysCreatedBy] DEFAULT ((-1)) NULL,
    [sysChangedBy] INT            CONSTRAINT [DF_SubTaskLog_sysChangedBy] DEFAULT ((-1)) NULL,
    CONSTRAINT [PK_SubTaskLog] PRIMARY KEY CLUSTERED ([SubTaskLogId] ASC),
    CONSTRAINT [FK_SubTaskLog_SubTask_SubTaskId] FOREIGN KEY ([SubTaskId]) REFERENCES [dbo].[SubTask] ([SubTaskId]),
    CONSTRAINT [FK_SubTaskLog_User_StudentId] FOREIGN KEY ([StudentId]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [FK_SubTaskLog_User_ReviewerId] FOREIGN KEY ([ReviewerId]) REFERENCES [dbo].[User] ([UserId])
);

