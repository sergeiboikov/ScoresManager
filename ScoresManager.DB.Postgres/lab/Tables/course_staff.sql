CREATE TABLE lab.course_staff (
    course_staff_id INT       NOT NULL,
    course_id       INT       NOT NULL,
    user_id         INT       NOT NULL,
    user_type_id    SMALLINT  NOT NULL,
    status_id       SMALLINT  NULL,
    sys_created_at  TIMESTAMP CONSTRAINT df_course_staff_sys_created_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_changed_at  TIMESTAMP CONSTRAINT df_course_staff_sys_changed_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_created_by  INT       CONSTRAINT df_course_staff_sys_created_by DEFAULT ((-1)) NULL,
    sys_changed_by  INT       CONSTRAINT df_course_staff_sys_changed_by DEFAULT ((-1)) NULL,
    CONSTRAINT pk_course_staff                          PRIMARY KEY     (course_staff_id),
    CONSTRAINT fk_course_staff_course_course_id         FOREIGN KEY     (course_id)     REFERENCES lab.course (course_id),
    CONSTRAINT fk_course_staff_user_user_id             FOREIGN KEY     (user_id)       REFERENCES lab.user (user_id),
    CONSTRAINT fk_course_staff_user_type_user_type_id   FOREIGN KEY     (user_type_id)  REFERENCES lab.user_type (user_type_id),
    CONSTRAINT fk_course_staff_status_status_id         FOREIGN KEY     (status_id)     REFERENCES lab.status (status_id),
    CONSTRAINT uc_course_staff_course_id_user_id        UNIQUE          (course_id , user_id)
);

CREATE SEQUENCE lab.sq_lab_course_staff_course_staff_id START 1;
