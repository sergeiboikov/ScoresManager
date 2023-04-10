CREATE TABLE dbo.User (
    UserId       INT            NOT NULL,
    Name         VARCHAR (100)  NOT NULL,
    Email        VARCHAR (100)  NOT NULL,
    Notes        VARCHAR (500)  NULL,
    sysCreatedAt TIMESTAMP      CONSTRAINT DF_User_sysCreatedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysChangedAt TIMESTAMP      CONSTRAINT DF_User_sysChangedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysCreatedBy INT            CONSTRAINT DF_User_sysCreatedBy DEFAULT ((-1)) NULL,
    sysChangedBy INT            CONSTRAINT DF_User_sysChangedBy DEFAULT ((-1)) NULL,
    CONSTRAINT PK_User PRIMARY KEY  (UserId),
    CONSTRAINT UC_User_Email UNIQUE  (Email)
);

CREATE SEQUENCE dbo.sq_dbo_User_UserId START 1;