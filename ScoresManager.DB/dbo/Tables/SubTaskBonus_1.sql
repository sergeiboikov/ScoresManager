CREATE TABLE [dbo].[SubTaskBonus] (
    [SubTaskBonusId] INT      IDENTITY (1, 1) NOT NULL,
    [SubTaskId]      INT      NOT NULL,
    [BonusId]        SMALLINT NOT NULL,
    [sysCreatedAt]   DATETIME CONSTRAINT [DF_SubTaskBonus_sysCreatedAt] DEFAULT (getutcdate()) NULL,
    [sysChangedAt]   DATETIME CONSTRAINT [DF_SubTaskBonus_sysChangedAt] DEFAULT (getutcdate()) NULL,
    [sysCreatedBy]   INT      CONSTRAINT [DF_SubTaskBonus_sysCreatedBy] DEFAULT ((-1)) NULL,
    [sysChangedBy]   INT      CONSTRAINT [DF_SubTaskBonus_sysChangedBy] DEFAULT ((-1)) NULL,
    CONSTRAINT [PK_SubTaskBonus] PRIMARY KEY CLUSTERED ([SubTaskBonusId] ASC)
);



