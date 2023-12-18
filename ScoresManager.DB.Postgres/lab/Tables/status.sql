CREATE TABLE lab.status (
    status_id       SMALLINT       NOT NULL,
    "name"          VARCHAR (100)  NOT NULL,
    description     VARCHAR (250)  NULL,
    sys_created_at  TIMESTAMP      CONSTRAINT df_status_sys_created_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_changed_at  TIMESTAMP      CONSTRAINT df_status_sys_changed_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_created_by  INT            CONSTRAINT df_status_sys_created_by DEFAULT ((-1)) NULL,
    sys_changed_by  INT            CONSTRAINT df_status_sys_changed_by DEFAULT ((-1)) NULL,
    CONSTRAINT pk_status PRIMARY KEY  (status_id),
    CONSTRAINT uc_status_name UNIQUE  ("name")
);

CREATE SEQUENCE lab.sq_lab_status_status_id START 1;