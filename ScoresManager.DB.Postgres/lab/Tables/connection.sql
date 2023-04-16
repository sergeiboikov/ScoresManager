CREATE TABLE lab."connection" (
    connection_id       INT            NOT NULL, 
    connection_string   VARCHAR(250)   NOT NULL, 
    connection_type_id  SMALLINT       NOT NULL, 
    sys_created_at      TIMESTAMP      CONSTRAINT df_connection_sys_created_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL, 
    sys_changed_at      TIMESTAMP      CONSTRAINT df_connection_sys_changed_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL, 
    sys_created_by      INT            CONSTRAINT df_connection_sys_created_by DEFAULT ((-1)) NULL, 
    sys_changed_by      INT            CONSTRAINT df_connection_sys_changed_by DEFAULT ((-1)) NULL, 
    CONSTRAINT pk_connection PRIMARY KEY  (connection_id), 
    CONSTRAINT fk_connection_connection_type_connection_type_id FOREIGN KEY (connection_type_id) REFERENCES lab.connection_type(connection_type_id)
);

CREATE SEQUENCE lab.sq_dbo_connection_connection_id START 1;