CREATE TABLE lab.check_script_type
(
    check_script_type_id SMALLINT     NOT NULL,
    "name"              VARCHAR(250)  NOT NULL, 
    sys_created_at      TIMESTAMP     CONSTRAINT df_check_script_type_sys_created_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_changed_at      TIMESTAMP     CONSTRAINT df_check_script_type_sys_changed_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_created_by      INT           CONSTRAINT df_check_script_type_sys_created_by DEFAULT ((-1))         NULL,
    sys_changed_by      INT           CONSTRAINT df_check_script_type_sys_changed_by DEFAULT ((-1))         NULL,
    CONSTRAINT pk_check_script_type PRIMARY KEY  (check_script_type_id),
    CONSTRAINT uc_check_script_type_name UNIQUE  ("name")
);

CREATE SEQUENCE lab.sq_lab_check_script_type_check_script_type_id START 1;
