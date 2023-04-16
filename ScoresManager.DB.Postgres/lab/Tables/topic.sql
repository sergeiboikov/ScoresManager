CREATE TABLE lab.topic (
    topic_id                SMALLINT         NOT NULL,
    "name"                  VARCHAR (250)    NOT NULL,
    is_topic_for_tasks      BIT              NULL,
    is_topic_for_subtasks   BIT              NULL,
    sys_created_at          TIMESTAMP        CONSTRAINT df_topic_sys_created_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_changed_at          TIMESTAMP        CONSTRAINT df_topic_sys_changed_at DEFAULT (CURRENT_TIMESTAMP(0)::TIMESTAMP WITHOUT TIME ZONE) NULL,
    sys_created_by          INT              CONSTRAINT df_topic_sys_created_by DEFAULT ((-1)) NULL,
    sys_changed_by          INT              CONSTRAINT df_topic_sys_changed_by DEFAULT ((-1)) NULL,
    CONSTRAINT pk_topic PRIMARY KEY  (topic_id),
    CONSTRAINT uc_topic_name UNIQUE  ("name")
);

CREATE SEQUENCE lab.sq_dbo_topic_topic_id START 1;