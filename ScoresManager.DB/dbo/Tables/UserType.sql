CREATE TABLE [dbo].[UserType] (
    [UserTypeId]   SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (100) NOT NULL,
    [Description]  NVARCHAR (250) NOT NULL,
    [sysCreatedAt] DATETIME       CONSTRAINT [DF_UserType_sysCreatedAt] DEFAULT (getutcdate()) NULL,
    [sysChangedAt] DATETIME       CONSTRAINT [DF_UserType_sysChangedAt] DEFAULT (getutcdate()) NULL,
    [sysCreatedBy] INT            CONSTRAINT [DF_UserType_sysCreatedBy] DEFAULT ((-1)) NULL,
    [sysChangedBy] INT            CONSTRAINT [DF_UserType_sysChangedBy] DEFAULT ((-1)) NULL,
    CONSTRAINT [PK_UserType] PRIMARY KEY CLUSTERED ([UserTypeId] ASC),
    CONSTRAINT [UC_UserType_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);

