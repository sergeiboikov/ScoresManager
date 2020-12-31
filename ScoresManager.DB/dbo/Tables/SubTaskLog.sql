CREATE TABLE [dbo].[SubTaskLog] (
    [SubTaskLogId] INT            IDENTITY (1, 1) NOT NULL,
    [SubTaskId]    INT            NOT NULL,
    [StudentId]    INT            NOT NULL,
    [ReviewerId]   INT            NULL,
    [Score]        NUMERIC (8, 2) CONSTRAINT [DF_SubTaskLog_Score] DEFAULT ((0)) NOT NULL,
    [OnTime]       NUMERIC (8, 2) CONSTRAINT [DF_SubTaskLog_OnTime] DEFAULT ((0)) NOT NULL,
    [NameConv]     NUMERIC (8, 2) CONSTRAINT [DF_SubTaskLog_NameConv] DEFAULT ((0)) NOT NULL,
    [Readability]  NUMERIC (8, 2) CONSTRAINT [DF_SubTaskLog_Readability] DEFAULT ((0)) NOT NULL,
    [Sarg]         NUMERIC (8, 2) CONSTRAINT [DF_SubTaskLog_Sarg] DEFAULT ((0)) NOT NULL,
    [SchemaName]   NUMERIC (8, 2) CONSTRAINT [DF_SubTaskLog_SchemaName] DEFAULT ((0)) NOT NULL,
    [Aliases]      NUMERIC (8, 2) CONSTRAINT [DF_SubTaskLog_Aliases] DEFAULT ((0)) NOT NULL,
    [DetermSort]   NUMERIC (8, 2) CONSTRAINT [DF_SubTaskLog_DetermSort] DEFAULT ((0)) NOT NULL,
    [Accuracy]     AS             ((((([NameConv]+[Readability])+[Sarg])+[SchemaName])+[Aliases])+[DetermSort]),
    [Extra]        NUMERIC (8, 2) CONSTRAINT [DF_SubTaskLog_Extra] DEFAULT ((0)) NOT NULL,
    [TotalScore]   AS             ((([Score]+[OnTime])+((((([NameConv]+[Readability])+[Sarg])+[SchemaName])+[Aliases])+[DetermSort]))+[Extra]),
    [Comment]      NVARCHAR (500) NULL,
    [sysCreatedAt] DATETIME       CONSTRAINT [DF_SubTaskLog_sysCreatedAt] DEFAULT (getutcdate()) NULL,
    [sysChangedAt] DATETIME       CONSTRAINT [DF_SubTaskLog_sysChangedAt] DEFAULT (getutcdate()) NULL,
    [sysCreatedBy] INT            CONSTRAINT [DF_SubTaskLog_sysCreatedBy] DEFAULT ((-1)) NULL,
    [sysChangedBy] INT            CONSTRAINT [DF_SubTaskLog_sysChangedBy] DEFAULT ((-1)) NULL,
    CONSTRAINT [PK_SubTaskLog] PRIMARY KEY CLUSTERED ([SubTaskLogId] ASC),
    CONSTRAINT [FK_SubTaskLog_SubTask_SubTaskId] FOREIGN KEY ([SubTaskId]) REFERENCES [dbo].[SubTask] ([SubTaskId]),
    CONSTRAINT [FK_SubTaskLog_User_ReviewerId] FOREIGN KEY ([ReviewerId]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [FK_SubTaskLog_User_StudentId] FOREIGN KEY ([StudentId]) REFERENCES [dbo].[User] ([UserId])
);





