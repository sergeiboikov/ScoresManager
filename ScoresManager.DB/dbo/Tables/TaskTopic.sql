CREATE TABLE [dbo].[TaskTopic] (
    [TaskTopicId]  SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (250) NOT NULL,
    [sysCreatedAt] DATETIME       CONSTRAINT [DF_TaskTopic_sysCreatedAt] DEFAULT (getutcdate()) NULL,
    [sysChangedAt] DATETIME       CONSTRAINT [DF_TaskTopic_sysChangedAt] DEFAULT (getutcdate()) NULL,
    [sysCreatedBy] INT            CONSTRAINT [DF_TaskTopic_sysCreatedBy] DEFAULT ((-1)) NULL,
    [sysChangedBy] INT            CONSTRAINT [DF_TaskTopic_sysChangedBy] DEFAULT ((-1)) NULL,
    CONSTRAINT [PK_TaskTopic] PRIMARY KEY CLUSTERED ([TaskTopicId] ASC),
    CONSTRAINT [UC_TaskTopic_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);

