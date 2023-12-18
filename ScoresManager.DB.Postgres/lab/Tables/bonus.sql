CREATE TABLE lab.bonus (
    bonus_id        SMALLINT       NOT NULL,
    name            VARCHAR(250)   NOT NULL,
    description     VARCHAR(250)   NOT NULL,
    code            VARCHAR(30)    NOT NULL,
    sys_created_at  TIMESTAMP      CONSTRAINT df_bonus_sys_created_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_changed_at  TIMESTAMP      CONSTRAINT df_bonus_sys_changed_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_created_by  INT            CONSTRAINT df_bonus_sys_created_by DEFAULT ((-1)) NULL,
    sys_changed_by  INT            CONSTRAINT df_bonus_sys_changed_by DEFAULT ((-1)) NULL,
    CONSTRAINT pk_bonus PRIMARY KEY (bonus_id),
    CONSTRAINT uc_bonus_code UNIQUE (code)
);

CREATE SEQUENCE lab.sq_lab_bonus_bonus_id START 1;
