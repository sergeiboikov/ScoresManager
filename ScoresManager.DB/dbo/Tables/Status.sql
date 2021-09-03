CREATE TABLE [dbo].[Status] (
    [StatusId]     SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (100) NOT NULL,
    [Description]  NVARCHAR (250) NULL,
    [sysCreatedAt] DATETIME       CONSTRAINT [DF_Status_sysCreatedAt] DEFAULT (getutcdate()) NULL,
    [sysChangedAt] DATETIME       CONSTRAINT [DF_Status_sysChangedAt] DEFAULT (getutcdate()) NULL,
    [sysCreatedBy] INT            CONSTRAINT [DF_Status_sysCreatedBy] DEFAULT ((-1)) NULL,
    [sysChangedBy] INT            CONSTRAINT [DF_Status_sysChangedBy] DEFAULT ((-1)) NULL,
    CONSTRAINT [PK_Status] PRIMARY KEY CLUSTERED ([StatusId] ASC),
    CONSTRAINT [UC_Status_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);

