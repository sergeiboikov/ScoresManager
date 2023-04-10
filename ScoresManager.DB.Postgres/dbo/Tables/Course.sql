CREATE TABLE dbo.Course (
    CourseId     INT            NOT NULL,
    Name         VARCHAR (250)  NOT NULL,
    Datestart    DATE           NOT NULL,
    Datefinish   DATE           NULL,
    sysCreatedAt TIMESTAMP      CONSTRAINT DF_Course_sysCreatedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysChangedAt TIMESTAMP      CONSTRAINT DF_Course_sysChangedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysCreatedBy INT            CONSTRAINT DF_Course_sysCreatedBy DEFAULT ((-1)) NULL,
    sysChangedBy INT            CONSTRAINT DF_Course_sysChangedBy DEFAULT ((-1)) NULL,
    CONSTRAINT PK_Course PRIMARY KEY  (CourseId),
    CONSTRAINT CH_Course_Datefinish CHECK (Datefinish>=Datestart),
    CONSTRAINT UC_Course_Name UNIQUE  (Name)
);

CREATE SEQUENCE dbo.sq_dbo_Course_CourseId START 1;
