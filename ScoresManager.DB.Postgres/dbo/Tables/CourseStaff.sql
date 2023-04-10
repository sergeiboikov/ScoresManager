CREATE TABLE dbo.CourseStaff (
    CourseStaffId INT       NOT NULL,
    CourseId      INT       NOT NULL,
    UserId        INT       NOT NULL,
    UserTypeId    SMALLINT  NOT NULL,
    StatusId      SMALLINT  NULL,
    sysCreatedAt  TIMESTAMP CONSTRAINT DF_CourseStaff_sysCreatedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysChangedAt  TIMESTAMP CONSTRAINT DF_CourseStaff_sysChangedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysCreatedBy  INT       CONSTRAINT DF_CourseStaff_sysCreatedBy DEFAULT ((-1)) NULL,
    sysChangedBy  INT       CONSTRAINT DF_CourseStaff_sysChangedBy DEFAULT ((-1)) NULL,
    CONSTRAINT PK_CourseStaff PRIMARY KEY  (CourseStaffId),
    CONSTRAINT FK_CourseStaff_Course_CourseId FOREIGN KEY (CourseId) REFERENCES dbo.Course (CourseId),
    CONSTRAINT FK_CourseStaff_User_UserId FOREIGN KEY (UserId) REFERENCES dbo.User (UserId),
    CONSTRAINT FK_CourseStaff_UserType_UserTypeId FOREIGN KEY (UserTypeId) REFERENCES dbo.UserType (UserTypeId),
    CONSTRAINT FK_CourseStaff_Status_StatusId FOREIGN KEY (StatusId) REFERENCES dbo.Status (StatusId),
    CONSTRAINT UC_CourseStaff_CourseId_UserId UNIQUE  (CourseId , UserId)
);

CREATE SEQUENCE dbo.sq_dbo_CourseStaff_CourseStaffId START 1;
