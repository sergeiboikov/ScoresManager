CREATE TABLE dbo.UserType (
    UserTypeId   SMALLINT       NOT NULL,
    Name         VARCHAR(100)   NOT NULL,
    Description  VARCHAR(250)   NOT NULL,
    sysCreatedAt TIMESTAMP      CONSTRAINT DF_UserType_sysCreatedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysChangedAt TIMESTAMP      CONSTRAINT DF_UserType_sysChangedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysCreatedBy INT            CONSTRAINT DF_UserType_sysCreatedBy DEFAULT ((-1)) NULL,
    sysChangedBy INT            CONSTRAINT DF_UserType_sysChangedBy DEFAULT ((-1)) NULL,
    CONSTRAINT PK_UserType PRIMARY KEY  (UserTypeId),
    CONSTRAINT UC_UserType_Name UNIQUE  (Name)
);

CREATE SEQUENCE dbo.sq_dbo_UserType_UserTypeId START 1;
