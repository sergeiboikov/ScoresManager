CREATE TABLE dbo.Topic (
    TopicId            SMALLINT         NOT NULL,
    Name               VARCHAR (250)    NOT NULL,
    IsTopicForTasks    BIT              NULL,
    IsTopicForSubTasks BIT              NULL,
    sysCreatedAt       TIMESTAMP        CONSTRAINT DF_Topic_sysCreatedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysChangedAt       TIMESTAMP        CONSTRAINT DF_Topic_sysChangedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysCreatedBy       INT              CONSTRAINT DF_Topic_sysCreatedBy DEFAULT ((-1)) NULL,
    sysChangedBy       INT              CONSTRAINT DF_Topic_sysChangedBy DEFAULT ((-1)) NULL,
    CONSTRAINT PK_Topic PRIMARY KEY  (TopicId),
    CONSTRAINT UC_Topic_Name UNIQUE  (Name)
);

CREATE SEQUENCE dbo.sq_dbo_Topic_TopicId START 1;