CREATE TABLE [dbo].[CourseStaff] (
    [CourseStaffId]     INT       IDENTITY (1, 1) NOT NULL,
    [CourseId]          INT       NOT NULL,
    [UserId]            INT       NOT NULL,
    [UserTypeId]        SMALLINT  NOT NULL,
    [sysCreatedAt] DATETIME       DEFAULT (getutcdate()) NULL,
    [sysChangedAt] DATETIME       DEFAULT (getutcdate()) NULL,
    [sysCreatedBy] INT            DEFAULT ((-1)) NULL,
    [sysChangedBy] INT            DEFAULT ((-1)) NULL,
    CONSTRAINT [PK_CourseStaff] PRIMARY KEY CLUSTERED ([CourseStaffId] ASC),
    CONSTRAINT [FK_CourseStaff_Course_CourseId] FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Course] ([CourseId]),
    CONSTRAINT [FK_CourseStaff_User_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [FK_CourseStaff_UserType_UserTypeId] FOREIGN KEY ([UserTypeId]) REFERENCES [dbo].[UserType] ([UserTypeId])
);