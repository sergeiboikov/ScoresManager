CREATE TABLE [dbo].[Connection]
(
	[ConnectionId]     INT IDENTITY (1, 1) NOT NULL, 
    [ConnectionString] NVARCHAR(250) NOT NULL, 
    [ConnectionTypeId] SMALLINT      NOT NULL, 
    [sysCreatedAt]     DATETIME CONSTRAINT [DF_Connection_sysCreatedAt] DEFAULT (getutcdate()) NULL, 
    [sysChangedAt]     DATETIME CONSTRAINT [DF_Connection_sysChangedAt] DEFAULT (getutcdate()) NULL, 
    [sysCreatedBy]     INT      CONSTRAINT [DF_Connection_sysCreatedBy] DEFAULT ((-1))         NULL, 
    [sysChangedBy]     INT      CONSTRAINT [DF_Connection_sysChangedBy] DEFAULT ((-1))         NULL, 
    CONSTRAINT [PK_Connection] PRIMARY KEY CLUSTERED ([ConnectionId] ASC), 
    CONSTRAINT [FK_Connection_ConnectionType_ConnectionTypeId] FOREIGN KEY ([ConnectionTypeId]) REFERENCES [dbo].[ConnectionType]([ConnectionTypeId])
)
