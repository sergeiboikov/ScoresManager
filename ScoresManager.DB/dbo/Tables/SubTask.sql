CREATE TABLE [dbo].[SubTask] (
    [SubTaskId]    INT            IDENTITY (1, 1) NOT NULL,
    [TaskId]       INT            NOT NULL,
    [Name]         NVARCHAR (250) NOT NULL,
    [Description]  NVARCHAR (250) NOT NULL,
    [Topic]        NVARCHAR (250) NOT NULL,
    [sysCreatedAt] DATETIME       CONSTRAINT [DF_SubTask_sysCreatedAt] DEFAULT (getutcdate()) NULL,
    [sysChangedAt] DATETIME       CONSTRAINT [DF_SubTask_sysChangedAt] DEFAULT (getutcdate()) NULL,
    [sysCreatedBy] INT            CONSTRAINT [DF_SubTask_sysCreatedBy] DEFAULT ((-1)) NULL,
    [sysChangedBy] INT            CONSTRAINT [DF_SubTask_sysChangedBy] DEFAULT ((-1)) NULL,
    CONSTRAINT [PK_SubTask] PRIMARY KEY CLUSTERED ([SubTaskId] ASC),
    CONSTRAINT [FK_SubTask_Task_TaskId] FOREIGN KEY ([TaskId]) REFERENCES [dbo].[Task] ([TaskId])
);

