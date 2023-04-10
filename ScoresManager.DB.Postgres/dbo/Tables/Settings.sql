CREATE TABLE dbo.Settings (
    SettingsId   INT            NOT NULL,
    UserId       INT            NULL,
    SettingName  VARCHAR (100)  NOT NULL,
    SettingValue VARCHAR (100)  NULL,
    sysCreatedAt TIMESTAMP      CONSTRAINT DF_Settings_sysCreatedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysChangedAt TIMESTAMP      CONSTRAINT DF_Settings_sysChangedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysCreatedBy INT            CONSTRAINT DF_Settings_sysCreatedBy DEFAULT ((-1)) NULL,
    sysChangedBy INT            CONSTRAINT DF_Settings_sysChangedBy DEFAULT ((-1)) NULL,
    CONSTRAINT PK_Settings PRIMARY KEY  (SettingsId),
    CONSTRAINT FK_Settings_User_UserId FOREIGN KEY (UserId) REFERENCES dbo.User (UserId),
    CONSTRAINT UC_Settings_SettingsId UNIQUE  (SettingsId)
);

CREATE SEQUENCE dbo.sq_dbo_Settings_SettingsId START 1;