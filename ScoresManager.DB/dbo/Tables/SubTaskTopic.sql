CREATE TABLE [dbo].[SubTaskTopic] (
    [SubTaskTopicId] SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Name]           NVARCHAR (250) NOT NULL,
    [sysCreatedAt]   DATETIME       CONSTRAINT [DF_SubTaskTopic_sysCreatedAt] DEFAULT (getutcdate()) NULL,
    [sysChangedAt]   DATETIME       CONSTRAINT [DF_SubTaskTopic_sysChangedAt] DEFAULT (getutcdate()) NULL,
    [sysCreatedBy]   INT            CONSTRAINT [DF_SubTaskTopic_sysCreatedBy] DEFAULT ((-1)) NULL,
    [sysChangedBy]   INT            CONSTRAINT [DF_SubTaskTopic_sysChangedBy] DEFAULT ((-1)) NULL,
    CONSTRAINT [PK_SubTaskTopic] PRIMARY KEY CLUSTERED ([SubTaskTopicId] ASC),
    CONSTRAINT [UC_SubTaskTopic_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);

