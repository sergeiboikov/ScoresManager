CREATE TABLE dbo.Status (
    StatusId     SMALLINT       NOT NULL,
    Name         VARCHAR (100)  NOT NULL,
    Description  VARCHAR (250)  NULL,
    sysCreatedAt TIMESTAMP      CONSTRAINT DF_Status_sysCreatedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysChangedAt TIMESTAMP      CONSTRAINT DF_Status_sysChangedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysCreatedBy INT            CONSTRAINT DF_Status_sysCreatedBy DEFAULT ((-1)) NULL,
    sysChangedBy INT            CONSTRAINT DF_Status_sysChangedBy DEFAULT ((-1)) NULL,
    CONSTRAINT PK_Status PRIMARY KEY  (StatusId),
    CONSTRAINT UC_Status_Name UNIQUE  (Name)
);

CREATE SEQUENCE dbo.sq_dbo_Status_StatusId START 1;