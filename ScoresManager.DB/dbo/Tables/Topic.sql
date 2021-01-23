CREATE TABLE [dbo].[Topic] (
    [TopicId]            SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Name]               NVARCHAR (250) NOT NULL,
    [IsTopicForTasks]    BIT            NULL,
    [IsTopicForSubTasks] BIT            NULL,
    [sysCreatedAt]       DATETIME       CONSTRAINT [DF_Topic_sysCreatedAt] DEFAULT (getutcdate()) NULL,
    [sysChangedAt]       DATETIME       CONSTRAINT [DF_Topic_sysChangedAt] DEFAULT (getutcdate()) NULL,
    [sysCreatedBy]       INT            CONSTRAINT [DF_Topic_sysCreatedBy] DEFAULT ((-1)) NULL,
    [sysChangedBy]       INT            CONSTRAINT [DF_Topic_sysChangedBy] DEFAULT ((-1)) NULL,
    CONSTRAINT [PK_Topic] PRIMARY KEY CLUSTERED ([TopicId] ASC),
    CONSTRAINT [UC_Topic_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);

