CREATE TABLE lab.subtask (
    subtask_id      INT               NOT NULL,
    task_id         INT               NOT NULL,
    "name"          VARCHAR (250)     NOT NULL,
    description     TEXT              NOT NULL,
    topic_id        SMALLINT          NOT NULL,
    check_script_id INT               NULL,
    max_score       NUMERIC  (8,2)    NULL,
    sys_created_at  TIMESTAMP         CONSTRAINT df_subtask_sys_created_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_changed_at  TIMESTAMP         CONSTRAINT df_subtask_sys_changed_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_created_by  INT               CONSTRAINT df_subtask_sys_created_by DEFAULT ((-1)) NULL,
    sys_changed_by  INT               CONSTRAINT df_subtask_sys_changed_by DEFAULT ((-1)) NULL,
    CONSTRAINT pk_subtask PRIMARY KEY  (subtask_id),
    CONSTRAINT fk_subtask_task_task_id FOREIGN KEY (task_id) REFERENCES lab.task(task_id),
    CONSTRAINT fk_subtask_topic_topic_id FOREIGN KEY (topic_id) REFERENCES lab.topic(topic_id),
    CONSTRAINT uc_subtask_task_id_name UNIQUE (task_id , "name"), 
    CONSTRAINT fk_subtask_check_script_check_script_id FOREIGN KEY (check_script_id) REFERENCES lab.check_script(check_script_id)
);

CREATE SEQUENCE lab.sq_dbo_subtask_subtask_id START 1;
