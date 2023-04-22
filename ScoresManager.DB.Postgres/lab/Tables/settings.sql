CREATE TABLE lab.settings (
    settings_id     INT            NOT NULL,
    user_id         INT            NULL,
    setting_name    VARCHAR (100)  NOT NULL,
    setting_value   VARCHAR (100)  NULL,
    sys_created_at  TIMESTAMP      CONSTRAINT df_settings_sys_created_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_changed_at  TIMESTAMP      CONSTRAINT df_settings_sys_changed_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_created_by  INT            CONSTRAINT df_settings_sys_created_by DEFAULT ((-1)) NULL,
    sys_changed_by  INT            CONSTRAINT df_settings_sys_changed_by DEFAULT ((-1)) NULL,
    CONSTRAINT pk_settings PRIMARY KEY  (settings_id),
    CONSTRAINT fk_settings_user_user_id FOREIGN KEY (user_id) REFERENCES lab.user (user_id),
    CONSTRAINT uc_settings_settings_id UNIQUE  (settings_id)
);

CREATE SEQUENCE lab.sq_lab_settings_settings_id START 1;