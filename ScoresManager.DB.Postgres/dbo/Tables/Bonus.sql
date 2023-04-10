CREATE TABLE dbo.Bonus (
    BonusId      SMALLINT       NOT NULL,
    Name         VARCHAR(250)   NOT NULL,
    Description  VARCHAR(250)   NOT NULL,
    Code         VARCHAR(30)    NOT NULL,
    sysCreatedAt TIMESTAMP      CONSTRAINT DF_Bonus_sysCreatedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysChangedAt TIMESTAMP      CONSTRAINT DF_Bonus_sysChangedAt DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sysCreatedBy INT            CONSTRAINT DF_Bonus_sysCreatedBy DEFAULT ((-1)) NULL,
    sysChangedBy INT            CONSTRAINT DF_Bonus_sysChangedBy DEFAULT ((-1)) NULL,
    CONSTRAINT PK_Bonus PRIMARY KEY  (BonusId),
    CONSTRAINT UC_Bonus_Code UNIQUE  (Code)
);

CREATE SEQUENCE dbo.sq_dbo_Bonus_BonusId START 1;
