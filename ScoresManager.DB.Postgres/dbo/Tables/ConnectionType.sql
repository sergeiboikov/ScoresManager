CREATE TABLE dbo.ConnectionType
(
	ConnectionTypeId  SMALLINT          NOT NULL, 
    Name              VARCHAR(250)      NOT NULL, 
    Description       VARCHAR(250)      NOT NULL, 
    sysCreatedAt      TIMESTAMP         CONSTRAINT DF_ConnectionType_sysCreatedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL, 
    sysChangedAt      TIMESTAMP         CONSTRAINT DF_ConnectionType_sysChangedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL, 
    sysCreatedBy      INT               CONSTRAINT DF_ConnectionType_sysCreatedBy DEFAULT ((-1))         NULL, 
    sysChangedBy      INT               CONSTRAINT DF_ConnectionType_sysChangedBy DEFAULT ((-1))         NULL,
    CONSTRAINT PK_ConnectionType PRIMARY KEY  (ConnectionTypeId),
    CONSTRAINT UC_ConnectionType_Name UNIQUE  (Name)
);

CREATE SEQUENCE dbo.sq_dbo_ConnectionType_ConnectionTypeId START 1;