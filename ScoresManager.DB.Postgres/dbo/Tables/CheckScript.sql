CREATE TABLE dbo.CheckScript
(
	CheckScriptId     INT           NOT NULL, 
    Text              TEXT          NOT NULL, 
    Description       TEXT          NOT NULL, 
    ConnectionId      INT           NOT NULL, 
    CheckScriptTypeId SMALLINT      NOT NULL, 
    sysCreatedAt      TIMESTAMP     CONSTRAINT DF_CheckScript_sysCreatedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysChangedAt      TIMESTAMP     CONSTRAINT DF_CheckScript_sysChangedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysCreatedBy      INT           CONSTRAINT DF_CheckScript_sysCreatedBy DEFAULT ((-1))         NULL,
    sysChangedBy      INT           CONSTRAINT DF_CheckScript_sysChangedBy DEFAULT ((-1))         NULL,
    CONSTRAINT PK_CheckScript PRIMARY KEY  (CheckScriptId), 
    CONSTRAINT FK_CheckScript_Connection_ConnectionId FOREIGN KEY (ConnectionId) REFERENCES dbo.Connection(ConnectionId), 
    CONSTRAINT FK_CheckScript_CheckScriptType_CheckScriptTypeId FOREIGN KEY (CheckScriptTypeId) REFERENCES dbo.CheckScriptType(CheckScriptTypeId)
);

CREATE SEQUENCE dbo.sq_dbo_CheckScript_CheckScriptId START 1;