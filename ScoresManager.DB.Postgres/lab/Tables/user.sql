CREATE TABLE lab."user" (
    user_id         INT            NOT NULL,
    "name"          VARCHAR (100)  NOT NULL,
    email           VARCHAR (100)  NOT NULL,
    notes           VARCHAR (500)  NULL,
    sys_created_at  TIMESTAMP      CONSTRAINT df_user_sys_created_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_changed_at  TIMESTAMP      CONSTRAINT df_user_sys_changed_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_created_by  INT            CONSTRAINT df_user_sys_created_by DEFAULT ((-1)) NULL,
    sys_changed_by  INT            CONSTRAINT df_user_sys_changed_by DEFAULT ((-1)) NULL,
    CONSTRAINT pk_user PRIMARY KEY  (user_id),
    CONSTRAINT uc_user_email UNIQUE  (email)
);

CREATE SEQUENCE lab.sq_lab_user_user_id START 1;