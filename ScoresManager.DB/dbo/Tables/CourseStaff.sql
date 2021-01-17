CREATE TABLE [dbo].[CourseStaff] (
    [CourseStaffId] INT      IDENTITY (1, 1) NOT NULL,
    [CourseId]      INT      NOT NULL,
    [UserId]        INT      NOT NULL,
    [UserTypeId]    SMALLINT NOT NULL,
    [sysCreatedAt]  DATETIME CONSTRAINT [DF_CourseStaff_sysCreatedAt] DEFAULT (getutcdate()) NULL,
    [sysChangedAt]  DATETIME CONSTRAINT [DF_CourseStaff_sysChangedAt] DEFAULT (getutcdate()) NULL,
    [sysCreatedBy]  INT      CONSTRAINT [DF_CourseStaff_sysCreatedBy] DEFAULT ((-1)) NULL,
    [sysChangedBy]  INT      CONSTRAINT [DF_CourseStaff_sysChangedBy] DEFAULT ((-1)) NULL,
    CONSTRAINT [PK_CourseStaff] PRIMARY KEY CLUSTERED ([CourseStaffId] ASC),
    CONSTRAINT [FK_CourseStaff_Course_CourseId] FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Course] ([CourseId]),
    CONSTRAINT [FK_CourseStaff_User_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [FK_CourseStaff_UserType_UserTypeId] FOREIGN KEY ([UserTypeId]) REFERENCES [dbo].[UserType] ([UserTypeId]),
    CONSTRAINT [UC_CourseStaff_CourseId_UserId] UNIQUE NONCLUSTERED ([CourseId] ASC, [UserId] ASC)
);

