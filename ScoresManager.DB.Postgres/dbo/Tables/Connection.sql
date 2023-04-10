CREATE TABLE dbo.Connection
(
	ConnectionId     INT            NOT NULL, 
    ConnectionString VARCHAR(250)   NOT NULL, 
    ConnectionTypeId SMALLINT       NOT NULL, 
    sysCreatedAt     TIMESTAMP      CONSTRAINT DF_Connection_sysCreatedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL, 
    sysChangedAt     TIMESTAMP      CONSTRAINT DF_Connection_sysChangedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL, 
    sysCreatedBy     INT            CONSTRAINT DF_Connection_sysCreatedBy DEFAULT ((-1))         NULL, 
    sysChangedBy     INT            CONSTRAINT DF_Connection_sysChangedBy DEFAULT ((-1))         NULL, 
    CONSTRAINT PK_Connection PRIMARY KEY  (ConnectionId), 
    CONSTRAINT FK_Connection_ConnectionType_ConnectionTypeId FOREIGN KEY (ConnectionTypeId) REFERENCES dbo.ConnectionType(ConnectionTypeId)
);

CREATE SEQUENCE dbo.sq_dbo_Connection_ConnectionId START 1;