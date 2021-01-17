CREATE TABLE [dbo].[Bonus] (
    [BonusId]      SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (250) NOT NULL,
    [Description]  NVARCHAR (250) NOT NULL,
    [Code]         NVARCHAR (30)  NOT NULL,
    [sysCreatedAt] DATETIME       CONSTRAINT [DF_Bonus_sysCreatedAt] DEFAULT (getutcdate()) NULL,
    [sysChangedAt] DATETIME       CONSTRAINT [DF_Bonus_sysChangedAt] DEFAULT (getutcdate()) NULL,
    [sysCreatedBy] INT            CONSTRAINT [DF_Bonus_sysCreatedBy] DEFAULT ((-1)) NULL,
    [sysChangedBy] INT            CONSTRAINT [DF_Bonus_sysChangedBy] DEFAULT ((-1)) NULL,
    CONSTRAINT [PK_Bonus] PRIMARY KEY CLUSTERED ([BonusId] ASC),
    CONSTRAINT [UC_Bonus_Code] UNIQUE NONCLUSTERED ([Code] ASC)
);





