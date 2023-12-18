CREATE TABLE lab.subtask_bonus (
    subtask_bonus_id INT          NOT NULL,
    subtask_id       INT          NOT NULL,
    bonus_id         SMALLINT     NOT NULL,
    sys_created_at   TIMESTAMP    CONSTRAINT df_subtask_bonus_sys_created_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_changed_at   TIMESTAMP    CONSTRAINT df_subtask_bonus_sys_changed_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_created_by   INT          CONSTRAINT df_subtask_bonus_sys_created_by DEFAULT ((-1)) NULL,
    sys_changed_by   INT          CONSTRAINT df_subtask_bonus_sys_changed_by DEFAULT ((-1)) NULL,
    CONSTRAINT pk_subtask_bonus PRIMARY KEY  (subtask_bonus_id),
    CONSTRAINT fk_subtask_bonus_subtask_subtask_id FOREIGN KEY (subtask_id) REFERENCES lab.subtask (subtask_id),
    CONSTRAINT uc_subtask_bonus_subtask_id_bonus_id UNIQUE  (subtask_id , bonus_id)
);

CREATE SEQUENCE lab.sq_lab_subtask_bonus_subtask_bonus_id START 1;