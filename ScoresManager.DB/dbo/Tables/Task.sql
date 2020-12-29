CREATE TABLE [dbo].[Task] (
    [TaskId]       INT            IDENTITY (1, 1) NOT NULL,
    [CourseId]     INT            NOT NULL,
    [Name]         NVARCHAR (250) NOT NULL,
    [Description]  NVARCHAR (250) NOT NULL,
    [Topic]        NVARCHAR (250) NOT NULL,
    [sysCreatedAt] DATETIME       CONSTRAINT [DF_Task_sysCreatedAt] DEFAULT (getutcdate()) NULL,
    [sysChangedAt] DATETIME       CONSTRAINT [DF_Task_sysChangedAt] DEFAULT (getutcdate()) NULL,
    [sysCreatedBy] INT            CONSTRAINT [DF_Task_sysCreatedBy] DEFAULT ((-1)) NULL,
    [sysChangedBy] INT            CONSTRAINT [DF_Task_sysChangedBy] DEFAULT ((-1)) NULL,
    
    CONSTRAINT [PK_Task] PRIMARY KEY CLUSTERED ([TaskId] ASC),
    CONSTRAINT [FK_Task_Course_CourseId] FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Course] ([CourseId])
);

