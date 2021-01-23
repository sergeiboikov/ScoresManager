CREATE TABLE [dbo].[Task] (
    [TaskId]       INT            IDENTITY (1, 1) NOT NULL,
    [CourseId]     INT            NOT NULL,
    [Name]         NVARCHAR (250) NOT NULL,
    [Description]  NVARCHAR (250) NOT NULL,
    [TaskTopicId]  SMALLINT       NOT NULL,
    [sysCreatedAt] DATETIME       CONSTRAINT [DF_Task_sysCreatedAt] DEFAULT (getutcdate()) NULL,
    [sysChangedAt] DATETIME       CONSTRAINT [DF_Task_sysChangedAt] DEFAULT (getutcdate()) NULL,
    [sysCreatedBy] INT            CONSTRAINT [DF_Task_sysCreatedBy] DEFAULT ((-1)) NULL,
    [sysChangedBy] INT            CONSTRAINT [DF_Task_sysChangedBy] DEFAULT ((-1)) NULL,
    CONSTRAINT [PK_Task] PRIMARY KEY CLUSTERED ([TaskId] ASC),
    CONSTRAINT [FK_Task_Course_CourseId] FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Course] ([CourseId]),
    CONSTRAINT [FK_Task_TaskTopic_TaskTopicId] FOREIGN KEY ([TaskTopicId]) REFERENCES [dbo].[TaskTopic] ([TaskTopicId]),
    CONSTRAINT [UC_Task_CourseId_Name] UNIQUE NONCLUSTERED ([CourseId] ASC, [Name] ASC)
);





