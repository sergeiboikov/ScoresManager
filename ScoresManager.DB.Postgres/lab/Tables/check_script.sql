CREATE TABLE lab.check_script
(
    check_script_id         INT           NOT NULL, 
    "text"                  TEXT          NOT NULL, 
    description             TEXT          NOT NULL, 
    connection_id           INT           NOT NULL, 
    check_script_type_id    SMALLINT      NOT NULL, 
    sys_created_at          TIMESTAMP     CONSTRAINT df_check_script_sys_created_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_changed_at          TIMESTAMP     CONSTRAINT df_check_script_sys_changed_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_created_by          INT           CONSTRAINT df_check_script_sys_created_by DEFAULT ((-1)) NULL,
    sys_changed_by          INT           CONSTRAINT df_check_script_sys_changed_by DEFAULT ((-1)) NULL,
    CONSTRAINT pk_check_script PRIMARY KEY  (check_script_id), 
    CONSTRAINT fk_check_script_connection_connection_id FOREIGN KEY (connection_id) REFERENCES lab.connection(connection_id), 
    CONSTRAINT fk_check_script_check_script_type_check_script_type_id FOREIGN KEY (check_script_type_id) REFERENCES lab.check_script_type(check_script_type_id)
);

CREATE SEQUENCE lab.sq_dbo_check_script_check_script_id START 1;