CREATE TABLE lab.task (
    task_id         INT                NOT NULL,
    course_id       INT                NOT NULL,
    "name"          VARCHAR (250)      NOT NULL,
    description     VARCHAR (250)      NOT NULL,
    topic_id        SMALLINT           NOT NULL,
    sys_created_at  TIMESTAMP          CONSTRAINT df_task_sys_created_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_changed_at  TIMESTAMP          CONSTRAINT df_task_sys_changed_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_created_by  INT                CONSTRAINT df_task_sys_created_by DEFAULT ((-1)) NULL,
    sys_changed_by  INT                CONSTRAINT df_task_sys_changed_by DEFAULT ((-1)) NULL,
    CONSTRAINT pk_task PRIMARY KEY  (task_id),
    CONSTRAINT fk_task_course_course_id FOREIGN KEY (course_id) REFERENCES lab.course (course_id),
    CONSTRAINT fk_task_topic_topic_id FOREIGN KEY (topic_id) REFERENCES lab.topic (topic_id),
    CONSTRAINT uc_task_course_id_name UNIQUE  (course_id , "name")
);

CREATE SEQUENCE lab.sq_lab_task_task_id START 1;