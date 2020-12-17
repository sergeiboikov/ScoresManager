CREATE TABLE [dbo].[User] (
    [UserId]       INT            IDENTITY (1, 1) NOT NULL,
    [UserTypeId]   SMALLINT       NOT NULL,
    [Name]         NVARCHAR (100) NOT NULL,
    [Email]        NVARCHAR (100) NOT NULL,
    [Notes]        NVARCHAR (500) NULL,
    [sysCreatedAt] DATETIME       DEFAULT (getutcdate()) NULL,
    [sysChangedAt] DATETIME       DEFAULT (getutcdate()) NULL,
    [sysCreatedBy] INT            DEFAULT ((-1)) NULL,
    [sysChangedBy] INT            DEFAULT ((-1)) NULL,
    CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED ([UserId] ASC),
    CONSTRAINT [FK_User_UserType_UserTypeId] FOREIGN KEY ([UserTypeId]) REFERENCES [dbo].[UserType] ([UserTypeId])
);

