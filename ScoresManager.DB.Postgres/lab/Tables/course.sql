CREATE TABLE lab.course (
    course_id       INT            NOT NULL,
    "name"          VARCHAR (250)  NOT NULL,
    datestart       DATE           NOT NULL,
    datefinish      DATE           NULL,
    sys_created_at  TIMESTAMP      CONSTRAINT df_course_sys_created_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_changed_at  TIMESTAMP      CONSTRAINT df_course_sys_changed_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_created_by  INT            CONSTRAINT df_course_sys_created_by DEFAULT ((-1)) NULL,
    sys_changed_by  INT            CONSTRAINT df_course_sys_changed_by DEFAULT ((-1)) NULL,
    CONSTRAINT pk_course PRIMARY KEY  (course_id),
    CONSTRAINT ch_course_datefinish CHECK (datefinish >= datestart),
    CONSTRAINT uc_course_name UNIQUE  ("name")
);

CREATE SEQUENCE lab.sq_dbo_course_course_id START 1;
