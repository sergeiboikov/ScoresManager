CREATE TABLE [dbo].[ConnectionType]
(
	[ConnectionTypeId]  SMALLINT IDENTITY (1, 1) NOT NULL , 
    [Name]              NVARCHAR(250) NOT NULL, 
    [Description]       NVARCHAR(250) NOT NULL, 
    [sysCreatedAt]      DATETIME CONSTRAINT [DF_ConnectionType_sysCreatedAt] DEFAULT (getutcdate()) NULL, 
    [sysChangedAt]      DATETIME CONSTRAINT [DF_ConnectionType_sysChangedAt] DEFAULT (getutcdate()) NULL, 
    [sysCreatedBy]      INT      CONSTRAINT [DF_ConnectionType_sysCreatedBy] DEFAULT ((-1))         NULL, 
    [sysChangedBy]      INT      CONSTRAINT [DF_ConnectionType_sysChangedBy] DEFAULT ((-1))         NULL,
    CONSTRAINT [PK_ConnectionType] PRIMARY KEY CLUSTERED ([ConnectionTypeId] ASC),
    CONSTRAINT [UC_ConnectionType_Name] UNIQUE NONCLUSTERED ([Name] ASC)
)
