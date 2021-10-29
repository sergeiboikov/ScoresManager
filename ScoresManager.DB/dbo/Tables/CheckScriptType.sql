CREATE TABLE [dbo].[CheckScriptType]
(
	[CheckScriptTypeId] SMALLINT  IDENTITY (1, 1) NOT NULL,
    [Name]              NVARCHAR(250) NOT NULL, 
    [sysCreatedAt]      DATETIME       CONSTRAINT [DF_CheckScriptType_sysCreatedAt] DEFAULT (getutcdate()) NULL,
    [sysChangedAt]      DATETIME       CONSTRAINT [DF_CheckScriptType_sysChangedAt] DEFAULT (getutcdate()) NULL,
    [sysCreatedBy]      INT            CONSTRAINT [DF_CheckScriptType_sysCreatedBy] DEFAULT ((-1))         NULL,
    [sysChangedBy]      INT            CONSTRAINT [DF_CheckScriptType_sysChangedBy] DEFAULT ((-1))         NULL,
    CONSTRAINT [PK_CheckScriptType] PRIMARY KEY CLUSTERED ([CheckScriptTypeId] ASC),
    CONSTRAINT [UC_CheckScriptType_Name] UNIQUE NONCLUSTERED ([Name] ASC)
)
