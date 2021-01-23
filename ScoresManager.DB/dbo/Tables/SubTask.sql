CREATE TABLE [dbo].[SubTask] (
    [SubTaskId]      INT            IDENTITY (1, 1) NOT NULL,
    [TaskId]         INT            NOT NULL,
    [Name]           NVARCHAR (250) NOT NULL,
    [Description]    NVARCHAR (250) NOT NULL,
    [SubTaskTopicId] SMALLINT       NOT NULL,
    [sysCreatedAt]   DATETIME       CONSTRAINT [DF_SubTask_sysCreatedAt] DEFAULT (getutcdate()) NULL,
    [sysChangedAt]   DATETIME       CONSTRAINT [DF_SubTask_sysChangedAt] DEFAULT (getutcdate()) NULL,
    [sysCreatedBy]   INT            CONSTRAINT [DF_SubTask_sysCreatedBy] DEFAULT ((-1)) NULL,
    [sysChangedBy]   INT            CONSTRAINT [DF_SubTask_sysChangedBy] DEFAULT ((-1)) NULL,
    CONSTRAINT [PK_SubTask] PRIMARY KEY CLUSTERED ([SubTaskId] ASC),
    CONSTRAINT [FK_SubTask_SubTaskTopic_SubTaskTopicId] FOREIGN KEY ([SubTaskTopicId]) REFERENCES [dbo].[SubTaskTopic] ([SubTaskTopicId]),
    CONSTRAINT [FK_SubTask_Task_TaskId] FOREIGN KEY ([TaskId]) REFERENCES [dbo].[Task] ([TaskId]),
    CONSTRAINT [UC_SubTask_TaskId_Name] UNIQUE NONCLUSTERED ([TaskId] ASC, [Name] ASC)
);





