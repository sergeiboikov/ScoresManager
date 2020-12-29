CREATE TABLE [mentor].[ScoresTemplate] (
    [ScoresTemplateId] INT      NOT NULL,
    [Score]            INT      NOT NULL,
    [Accuracy]         INT      NOT NULL,
    [OnTime]           INT      NOT NULL,
    [Extra]            INT      NOT NULL,
    [sysCreatedAt]     DATETIME DEFAULT (getutcdate()) NULL,
    [sysChangedAt]     DATETIME DEFAULT (getutcdate()) NULL,
    [sysCreatedBy]     INT      DEFAULT ((-1)) NULL,
    [sysChangedBy]     INT      DEFAULT ((-1)) NULL,
    CONSTRAINT [PK_mentor.ScoresTemplate] PRIMARY KEY CLUSTERED ([ScoresTemplateId] ASC)
);

