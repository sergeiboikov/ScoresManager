CREATE TABLE dbo.CheckScriptType
(
	CheckScriptTypeId SMALLINT      NOT NULL,
    Name              VARCHAR(250)  NOT NULL, 
    sysCreatedAt      TIMESTAMP     CONSTRAINT DF_CheckScriptType_sysCreatedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysChangedAt      TIMESTAMP     CONSTRAINT DF_CheckScriptType_sysChangedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysCreatedBy      INT           CONSTRAINT DF_CheckScriptType_sysCreatedBy DEFAULT ((-1))         NULL,
    sysChangedBy      INT           CONSTRAINT DF_CheckScriptType_sysChangedBy DEFAULT ((-1))         NULL,
    CONSTRAINT PK_CheckScriptType PRIMARY KEY  (CheckScriptTypeId),
    CONSTRAINT UC_CheckScriptType_Name UNIQUE  (Name)
);

CREATE SEQUENCE dbo.sq_dbo_CheckScriptType_CheckScriptTypeId START 1;
