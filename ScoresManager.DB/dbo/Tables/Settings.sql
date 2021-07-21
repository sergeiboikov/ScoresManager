CREATE TABLE [dbo].[Settings] (
    [SettingsId]   INT            IDENTITY (1, 1) NOT NULL,
    [UserId]       INT            NULL,
    [SettingName]  NVARCHAR (100) NOT NULL,
    [SettingValue] NVARCHAR (100) NULL,
    [sysCreatedAt] DATETIME       CONSTRAINT [DF_Settings_sysCreatedAt] DEFAULT (getutcdate()) NULL,
    [sysChangedAt] DATETIME       CONSTRAINT [DF_Settings_sysChangedAt] DEFAULT (getutcdate()) NULL,
    [sysCreatedBy] INT            CONSTRAINT [DF_Settings_sysCreatedBy] DEFAULT ((-1)) NULL,
    [sysChangedBy] INT            CONSTRAINT [DF_Settings_sysChangedBy] DEFAULT ((-1)) NULL,
    CONSTRAINT [PK_Settings] PRIMARY KEY CLUSTERED ([SettingsId] ASC),
    CONSTRAINT [FK_Settings_User_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [UC_Settings_SettingsId] UNIQUE NONCLUSTERED ([SettingsId] ASC)
);

