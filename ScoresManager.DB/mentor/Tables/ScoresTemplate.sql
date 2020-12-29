CREATE TABLE [mentor].[ScoresTemplate] (
    [ScoresTemplateId] INT      NOT NULL,
    [Score]            INT      NOT NULL,
    [Accuracy]         INT      NOT NULL,
    [OnTime]           INT      NOT NULL,
    [Extra]            INT      NOT NULL,
    [sysCreatedAt] DATETIME       CONSTRAINT [DF_ScoresTemplate_sysCreatedAt] DEFAULT (getutcdate()) NULL,
    [sysChangedAt] DATETIME       CONSTRAINT [DF_ScoresTemplate_sysChangedAt] DEFAULT (getutcdate()) NULL,
    [sysCreatedBy] INT            CONSTRAINT [DF_ScoresTemplate_sysCreatedBy] DEFAULT ((-1)) NULL,
    [sysChangedBy] INT            CONSTRAINT [DF_ScoresTemplate_sysChangedBy] DEFAULT ((-1)) NULL,
    CONSTRAINT [PK_mentor.ScoresTemplate] PRIMARY KEY CLUSTERED ([ScoresTemplateId] ASC)
);

