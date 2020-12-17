CREATE TABLE [dbo].[UserType] (
    [UserTypeId]   SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (100) NOT NULL,
    [Description]  NVARCHAR (250) NOT NULL,
    [sysCreatedAt] DATETIME       DEFAULT (getutcdate()) NULL,
    [sysChangedAt] DATETIME       DEFAULT (getutcdate()) NULL,
    [sysCreatedBy] INT            DEFAULT ((-1)) NULL,
    [sysChangedBy] INT            DEFAULT ((-1)) NULL,
    CONSTRAINT [PK_UserType] PRIMARY KEY CLUSTERED ([UserTypeId] ASC)
);