CREATE TABLE dbo.SubTaskBonus (
    SubTaskBonusId INT          NOT NULL,
    SubTaskId      INT          NOT NULL,
    BonusId        SMALLINT     NOT NULL,
    sysCreatedAt   TIMESTAMP    CONSTRAINT DF_SubTaskBonus_sysCreatedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysChangedAt   TIMESTAMP    CONSTRAINT DF_SubTaskBonus_sysChangedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysCreatedBy   INT          CONSTRAINT DF_SubTaskBonus_sysCreatedBy DEFAULT ((-1)) NULL,
    sysChangedBy   INT          CONSTRAINT DF_SubTaskBonus_sysChangedBy DEFAULT ((-1)) NULL,
    CONSTRAINT PK_SubTaskBonus PRIMARY KEY  (SubTaskBonusId),
    CONSTRAINT FK_SubTaskBonus_SubTask_SubTaskId FOREIGN KEY (SubTaskId) REFERENCES dbo.SubTask (SubTaskId),
    CONSTRAINT UC_SubTaskBonus_SubTaskId_BonusId UNIQUE  (SubTaskId , BonusId)
);

CREATE SEQUENCE dbo.sq_dbo_SubTaskBonus_SubTaskBonusId START 1;