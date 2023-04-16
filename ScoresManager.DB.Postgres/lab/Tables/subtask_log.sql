CREATE TABLE lab.subtask_log (
    subtask_log_id  INT                NOT NULL,
    subtask_id      INT                NOT NULL,
    student_id      INT                NOT NULL,
    reviewer_id     INT                NULL,
    score           NUMERIC (8,2)                   CONSTRAINT df_subtask_log_score             DEFAULT ((0)) NOT NULL,
    ontime          NUMERIC (8,2)                   CONSTRAINT df_subtask_log_ontime            DEFAULT ((0)) NOT NULL,
    name_conv       NUMERIC (8,2)                   CONSTRAINT df_subtask_log_name_conv         DEFAULT ((0)) NOT NULL,
    readability     NUMERIC (8,2)                   CONSTRAINT df_subtask_log_readability       DEFAULT ((0)) NOT NULL,
    sarg            NUMERIC (8,2)                   CONSTRAINT df_subtask_log_sarg              DEFAULT ((0)) NOT NULL,
    schema_name     NUMERIC (8,2)                   CONSTRAINT df_subtask_log_schema_name       DEFAULT ((0)) NOT NULL,
    aliases         NUMERIC (8,2)                   CONSTRAINT df_subtask_log_aliases           DEFAULT ((0)) NOT NULL,
    determ_sort     NUMERIC (8,2)                   CONSTRAINT df_subtask_log_determ_sort       DEFAULT ((0)) NOT NULL,
    accuracy        NUMERIC (8,2)                   CONSTRAINT df_subtask_log_accuracy          DEFAULT ((0)) NOT NULL,
    extra           NUMERIC (8,2)                   CONSTRAINT df_subtask_log_extra             DEFAULT ((0)) NOT NULL,
    total_score     NUMERIC (8,2)                   CONSTRAINT df_subtask_log_total_score       DEFAULT ((0)) NOT NULL,
    comment         VARCHAR (500)      NULL,
    sys_created_at  TIMESTAMP                       CONSTRAINT df_subtask_log_sys_created_at    DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_changed_at  TIMESTAMP                       CONSTRAINT df_subtask_log_sys_changed_at    DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_created_by  INT                             CONSTRAINT df_subtask_log_sys_created_by    DEFAULT ((-1)) NULL,
    sys_changed_by  INT                             CONSTRAINT df_subtask_log_sys_changed_by    DEFAULT ((-1)) NULL,
    CONSTRAINT pk_subtask_log PRIMARY KEY  (subtask_log_id),
    CONSTRAINT fk_subtask_log_course_staff_reviewer_id FOREIGN KEY (reviewer_id) REFERENCES lab.course_staff (course_staff_id),
    CONSTRAINT fk_subtask_log_course_staff_student_id FOREIGN KEY (student_id) REFERENCES lab.course_staff (course_staff_id),
    CONSTRAINT fk_subtask_log_subtask_subtask_id FOREIGN KEY (subtask_id) REFERENCES lab.subtask (subtask_id),
    CONSTRAINT uc_subtask_log_subtask_id_student_id UNIQUE  (subtask_id , student_id)
);

CREATE SEQUENCE lab.sq_dbo_subtask_log_subtask_log_id START 1;