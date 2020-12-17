CREATE TABLE [dbo].[Course] (
    [CourseId]     INT            IDENTITY (1, 1) NOT NULL,
    [Name]   NVARCHAR (250) NOT NULL,
    [Datestart]    DATE           NOT NULL,
    [Datefinish]   DATE           NULL,
    [sysCreatedAt] DATETIME       CONSTRAINT [DF_Course_sysCreatedAt] DEFAULT (getutcdate()) NULL,
    [sysChangedAt] DATETIME       CONSTRAINT [DF_Course_sysChangedAt] DEFAULT (getutcdate()) NULL,
    [sysCreatedBy] INT            CONSTRAINT [DF_Course_sysCreatedBy] DEFAULT ((-1)) NULL,
    [sysChangedBy] INT            CONSTRAINT [DF_Course_sysChangedBy] DEFAULT ((-1)) NULL,
    CONSTRAINT [PK_Course] PRIMARY KEY CLUSTERED ([CourseId] ASC)
);

