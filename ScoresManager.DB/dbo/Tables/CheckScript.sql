CREATE TABLE [dbo].[CheckScript]
(
	[CheckScriptId]     INT IDENTITY (1, 1) NOT NULL, 
    [Text]              NVARCHAR(MAX)       NOT NULL, 
    [Description]       NVARCHAR(MAX)       NOT NULL, 
    [ConnectionId]      INT                 NOT NULL, 
    [CheckScriptTypeId] SMALLINT            NOT NULL, 
    [sysCreatedAt]      DATETIME       CONSTRAINT [DF_CheckScript_sysCreatedAt] DEFAULT (getutcdate()) NULL,
    [sysChangedAt]      DATETIME       CONSTRAINT [DF_CheckScript_sysChangedAt] DEFAULT (getutcdate()) NULL,
    [sysCreatedBy]      INT            CONSTRAINT [DF_CheckScript_sysCreatedBy] DEFAULT ((-1))         NULL,
    [sysChangedBy]      INT            CONSTRAINT [DF_CheckScript_sysChangedBy] DEFAULT ((-1))         NULL,
    CONSTRAINT [PK_CheckScript] PRIMARY KEY CLUSTERED ([CheckScriptId] ASC), 
    CONSTRAINT [FK_CheckScript_Connection_ConnectionId] FOREIGN KEY ([ConnectionId]) REFERENCES [dbo].[Connection]([ConnectionId]), 
    CONSTRAINT [FK_CheckScript_CheckScriptType_CheckScriptTypeId] FOREIGN KEY ([CheckScriptTypeId]) REFERENCES [dbo].[CheckScriptType]([CheckScriptTypeId])
)
