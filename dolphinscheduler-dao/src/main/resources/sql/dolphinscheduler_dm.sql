/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/
-- 注意：本脚本专为达梦数据库（DM）适配，包含以下调整：
-- 1. 所有标识符（表名、字段名、索引名）已转换为大写。
-- 2. 自增列使用 `IDENTITY(1,1)`。
-- 3. 移除 MySQL 特有语法（ENGINE, CHARSET 等）。
-- 4. 初始化数据插入时，对自增表使用了 `SET IDENTITY_INSERT ... ON/OFF`。

-- ----------------------------
-- 第一部分：创建 Quartz 相关表 (调度引擎)
-- ----------------------------
DROP TABLE IF EXISTS "QRTZ_JOB_DETAILS";
CREATE TABLE "QRTZ_JOB_DETAILS" (
                                    "SCHED_NAME" VARCHAR(120) NOT NULL,
                                    "JOB_NAME" VARCHAR(200) NOT NULL,
                                    "JOB_GROUP" VARCHAR(200) NOT NULL,
                                    "DESCRIPTION" VARCHAR(250),
                                    "JOB_CLASS_NAME" VARCHAR(250) NOT NULL,
                                    "IS_DURABLE" VARCHAR(1) NOT NULL,
                                    "IS_NONCONCURRENT" VARCHAR(1) NOT NULL,
                                    "IS_UPDATE_DATA" VARCHAR(1) NOT NULL,
                                    "REQUESTS_RECOVERY" VARCHAR(1) NOT NULL,
                                    "JOB_DATA" BLOB,
                                    PRIMARY KEY ("SCHED_NAME","JOB_NAME","JOB_GROUP")
);
CREATE INDEX "IDX_QRTZ_J_REQ_RECOVERY" ON "QRTZ_JOB_DETAILS"("SCHED_NAME","REQUESTS_RECOVERY");
CREATE INDEX "IDX_QRTZ_J_GRP" ON "QRTZ_JOB_DETAILS"("SCHED_NAME","JOB_GROUP");

DROP TABLE IF EXISTS "QRTZ_TRIGGERS";
CREATE TABLE "QRTZ_TRIGGERS" (
                                 "SCHED_NAME" VARCHAR(120) NOT NULL,
                                 "TRIGGER_NAME" VARCHAR(200) NOT NULL,
                                 "TRIGGER_GROUP" VARCHAR(200) NOT NULL,
                                 "JOB_NAME" VARCHAR(200) NOT NULL,
                                 "JOB_GROUP" VARCHAR(200) NOT NULL,
                                 "DESCRIPTION" VARCHAR(250),
                                 "NEXT_FIRE_TIME" NUMBER(20),
                                 "PREV_FIRE_TIME" NUMBER(20),
                                 "PRIORITY" NUMBER(11),
                                 "TRIGGER_STATE" VARCHAR(16) NOT NULL,
                                 "TRIGGER_TYPE" VARCHAR(8) NOT NULL,
                                 "START_TIME" NUMBER(20) NOT NULL,
                                 "END_TIME" NUMBER(20),
                                 "CALENDAR_NAME" VARCHAR(200),
                                 "MISFIRE_INSTR" NUMBER(5),
                                 "JOB_DATA" BLOB,
                                 PRIMARY KEY ("SCHED_NAME","TRIGGER_NAME","TRIGGER_GROUP")
);
CREATE INDEX "IDX_QRTZ_T_J" ON "QRTZ_TRIGGERS"("SCHED_NAME","JOB_NAME","JOB_GROUP");
CREATE INDEX "IDX_QRTZ_T_JG" ON "QRTZ_TRIGGERS"("SCHED_NAME","JOB_GROUP");
CREATE INDEX "IDX_QRTZ_T_C" ON "QRTZ_TRIGGERS"("SCHED_NAME","CALENDAR_NAME");
CREATE INDEX "IDX_QRTZ_T_G" ON "QRTZ_TRIGGERS"("SCHED_NAME","TRIGGER_GROUP");
CREATE INDEX "IDX_QRTZ_T_STATE" ON "QRTZ_TRIGGERS"("SCHED_NAME","TRIGGER_STATE");
CREATE INDEX "IDX_QRTZ_T_N_STATE" ON "QRTZ_TRIGGERS"("SCHED_NAME","TRIGGER_NAME","TRIGGER_GROUP","TRIGGER_STATE");
CREATE INDEX "IDX_QRTZ_T_N_G_STATE" ON "QRTZ_TRIGGERS"("SCHED_NAME","TRIGGER_GROUP","TRIGGER_STATE");
CREATE INDEX "IDX_QRTZ_T_NEXT_FIRE_TIME" ON "QRTZ_TRIGGERS"("SCHED_NAME","NEXT_FIRE_TIME");
CREATE INDEX "IDX_QRTZ_T_NFT_ST" ON "QRTZ_TRIGGERS"("SCHED_NAME","TRIGGER_STATE","NEXT_FIRE_TIME");
CREATE INDEX "IDX_QRTZ_T_NFT_MISFIRE" ON "QRTZ_TRIGGERS"("SCHED_NAME","MISFIRE_INSTR","NEXT_FIRE_TIME");
CREATE INDEX "IDX_QRTZ_T_NFT_ST_MISFIRE" ON "QRTZ_TRIGGERS"("SCHED_NAME","MISFIRE_INSTR","NEXT_FIRE_TIME","TRIGGER_STATE");
CREATE INDEX "IDX_QRTZ_T_NFT_ST_MISFIRE_GRP" ON "QRTZ_TRIGGERS"("SCHED_NAME","MISFIRE_INSTR","NEXT_FIRE_TIME","TRIGGER_GROUP","TRIGGER_STATE");
ALTER TABLE "QRTZ_TRIGGERS" ADD CONSTRAINT "QRTZ_TRIGGERS_IBFK_1" FOREIGN KEY ("SCHED_NAME", "JOB_NAME", "JOB_GROUP") REFERENCES "QRTZ_JOB_DETAILS" ("SCHED_NAME", "JOB_NAME", "JOB_GROUP");

DROP TABLE IF EXISTS "QRTZ_BLOB_TRIGGERS";
CREATE TABLE "QRTZ_BLOB_TRIGGERS" (
                                      "SCHED_NAME" VARCHAR(120) NOT NULL,
                                      "TRIGGER_NAME" VARCHAR(200) NOT NULL,
                                      "TRIGGER_GROUP" VARCHAR(200) NOT NULL,
                                      "BLOB_DATA" BLOB,
                                      PRIMARY KEY ("SCHED_NAME","TRIGGER_NAME","TRIGGER_GROUP")
);
CREATE INDEX "IDX_QRTZ_BLOB_TRIGGERS" ON "QRTZ_BLOB_TRIGGERS"("SCHED_NAME","TRIGGER_NAME","TRIGGER_GROUP");
ALTER TABLE "QRTZ_BLOB_TRIGGERS" ADD CONSTRAINT "QRTZ_BLOB_TRIGGERS_IBFK_1" FOREIGN KEY ("SCHED_NAME", "TRIGGER_NAME", "TRIGGER_GROUP") REFERENCES "QRTZ_TRIGGERS" ("SCHED_NAME", "TRIGGER_NAME", "TRIGGER_GROUP");

DROP TABLE IF EXISTS "QRTZ_CALENDARS";
CREATE TABLE "QRTZ_CALENDARS" (
                                  "SCHED_NAME" VARCHAR(120) NOT NULL,
                                  "CALENDAR_NAME" VARCHAR(200) NOT NULL,
                                  "CALENDAR" BLOB NOT NULL,
                                  PRIMARY KEY ("SCHED_NAME","CALENDAR_NAME")
);

DROP TABLE IF EXISTS "QRTZ_CRON_TRIGGERS";
CREATE TABLE "QRTZ_CRON_TRIGGERS" (
                                      "SCHED_NAME" VARCHAR(120) NOT NULL,
                                      "TRIGGER_NAME" VARCHAR(200) NOT NULL,
                                      "TRIGGER_GROUP" VARCHAR(200) NOT NULL,
                                      "CRON_EXPRESSION" VARCHAR(120) NOT NULL,
                                      "TIME_ZONE_ID" VARCHAR(80),
                                      PRIMARY KEY ("SCHED_NAME","TRIGGER_NAME","TRIGGER_GROUP")
);
ALTER TABLE "QRTZ_CRON_TRIGGERS" ADD CONSTRAINT "QRTZ_CRON_TRIGGERS_IBFK_1" FOREIGN KEY ("SCHED_NAME", "TRIGGER_NAME", "TRIGGER_GROUP") REFERENCES "QRTZ_TRIGGERS" ("SCHED_NAME", "TRIGGER_NAME", "TRIGGER_GROUP");

DROP TABLE IF EXISTS "QRTZ_FIRED_TRIGGERS";
CREATE TABLE "QRTZ_FIRED_TRIGGERS" (
                                       "SCHED_NAME" VARCHAR(120) NOT NULL,
                                       "ENTRY_ID" VARCHAR(200) NOT NULL,
                                       "TRIGGER_NAME" VARCHAR(200) NOT NULL,
                                       "TRIGGER_GROUP" VARCHAR(200) NOT NULL,
                                       "INSTANCE_NAME" VARCHAR(200) NOT NULL,
                                       "FIRED_TIME" NUMBER(20) NOT NULL,
                                       "SCHED_TIME" NUMBER(20) NOT NULL,
                                       "PRIORITY" NUMBER(11) NOT NULL,
                                       "STATE" VARCHAR(16) NOT NULL,
                                       "JOB_NAME" VARCHAR(200),
                                       "JOB_GROUP" VARCHAR(200),
                                       "IS_NONCONCURRENT" VARCHAR(1),
                                       "REQUESTS_RECOVERY" VARCHAR(1),
                                       PRIMARY KEY ("SCHED_NAME","ENTRY_ID")
);
CREATE INDEX "IDX_QRTZ_FT_TRIG_INST_NAME" ON "QRTZ_FIRED_TRIGGERS"("SCHED_NAME","INSTANCE_NAME");
CREATE INDEX "IDX_QRTZ_FT_INST_JOB_REQ_RCVRY" ON "QRTZ_FIRED_TRIGGERS"("SCHED_NAME","INSTANCE_NAME","REQUESTS_RECOVERY");
CREATE INDEX "IDX_QRTZ_FT_J_G" ON "QRTZ_FIRED_TRIGGERS"("SCHED_NAME","JOB_NAME","JOB_GROUP");
CREATE INDEX "IDX_QRTZ_FT_JG" ON "QRTZ_FIRED_TRIGGERS"("SCHED_NAME","JOB_GROUP");
CREATE INDEX "IDX_QRTZ_FT_T_G" ON "QRTZ_FIRED_TRIGGERS"("SCHED_NAME","TRIGGER_NAME","TRIGGER_GROUP");
CREATE INDEX "IDX_QRTZ_FT_TG" ON "QRTZ_FIRED_TRIGGERS"("SCHED_NAME","TRIGGER_GROUP");

DROP TABLE IF EXISTS "QRTZ_LOCKS";
CREATE TABLE "QRTZ_LOCKS" (
                              "SCHED_NAME" VARCHAR(120) NOT NULL,
                              "LOCK_NAME" VARCHAR(40) NOT NULL,
                              PRIMARY KEY ("SCHED_NAME","LOCK_NAME")
);

DROP TABLE IF EXISTS "QRTZ_PAUSED_TRIGGER_GRPS";
CREATE TABLE "QRTZ_PAUSED_TRIGGER_GRPS" (
                                            "SCHED_NAME" VARCHAR(120) NOT NULL,
                                            "TRIGGER_GROUP" VARCHAR(200) NOT NULL,
                                            PRIMARY KEY ("SCHED_NAME","TRIGGER_GROUP")
);

DROP TABLE IF EXISTS "QRTZ_SCHEDULER_STATE";
CREATE TABLE "QRTZ_SCHEDULER_STATE" (
                                        "SCHED_NAME" VARCHAR(120) NOT NULL,
                                        "INSTANCE_NAME" VARCHAR(200) NOT NULL,
                                        "LAST_CHECKIN_TIME" NUMBER(20) NOT NULL,
                                        "CHECKIN_INTERVAL" NUMBER(20) NOT NULL,
                                        PRIMARY KEY ("SCHED_NAME","INSTANCE_NAME")
);

DROP TABLE IF EXISTS "QRTZ_SIMPLE_TRIGGERS";
CREATE TABLE "QRTZ_SIMPLE_TRIGGERS" (
                                        "SCHED_NAME" VARCHAR(120) NOT NULL,
                                        "TRIGGER_NAME" VARCHAR(200) NOT NULL,
                                        "TRIGGER_GROUP" VARCHAR(200) NOT NULL,
                                        "REPEAT_COUNT" NUMBER(20) NOT NULL,
                                        "REPEAT_INTERVAL" NUMBER(20) NOT NULL,
                                        "TIMES_TRIGGERED" NUMBER(20) NOT NULL,
                                        PRIMARY KEY ("SCHED_NAME","TRIGGER_NAME","TRIGGER_GROUP")
);
ALTER TABLE "QRTZ_SIMPLE_TRIGGERS" ADD CONSTRAINT "QRTZ_SIMPLE_TRIGGERS_IBFK_1" FOREIGN KEY ("SCHED_NAME", "TRIGGER_NAME", "TRIGGER_GROUP") REFERENCES "QRTZ_TRIGGERS" ("SCHED_NAME", "TRIGGER_NAME", "TRIGGER_GROUP");

DROP TABLE IF EXISTS "QRTZ_SIMPROP_TRIGGERS";
CREATE TABLE "QRTZ_SIMPROP_TRIGGERS" (
                                         "SCHED_NAME" VARCHAR(120) NOT NULL,
                                         "TRIGGER_NAME" VARCHAR(200) NOT NULL,
                                         "TRIGGER_GROUP" VARCHAR(200) NOT NULL,
                                         "STR_PROP_1" VARCHAR(512),
                                         "STR_PROP_2" VARCHAR(512),
                                         "STR_PROP_3" VARCHAR(512),
                                         "INT_PROP_1" NUMBER(11),
                                         "INT_PROP_2" NUMBER(11),
                                         "LONG_PROP_1" NUMBER(20),
                                         "LONG_PROP_2" NUMBER(20),
                                         "DEC_PROP_1" NUMBER(13,4),
                                         "DEC_PROP_2" NUMBER(13,4),
                                         "BOOL_PROP_1" VARCHAR(1),
                                         "BOOL_PROP_2" VARCHAR(1),
                                         PRIMARY KEY ("SCHED_NAME","TRIGGER_NAME","TRIGGER_GROUP")
);
ALTER TABLE "QRTZ_SIMPROP_TRIGGERS" ADD CONSTRAINT "QRTZ_SIMPROP_TRIGGERS_IBFK_1" FOREIGN KEY ("SCHED_NAME", "TRIGGER_NAME", "TRIGGER_GROUP") REFERENCES "QRTZ_TRIGGERS" ("SCHED_NAME", "TRIGGER_NAME", "TRIGGER_GROUP");

-- ----------------------------
-- 第二部分：创建 DolphinScheduler 核心元数据表
-- 表名顺序已按您提供的列表整理
-- ----------------------------

-- T_DS_ACCESS_TOKEN
DROP TABLE IF EXISTS "T_DS_ACCESS_TOKEN";
CREATE TABLE "T_DS_ACCESS_TOKEN" (
                                     "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                     "USER_ID" NUMBER(11),
                                     "TOKEN" VARCHAR(64),
                                     "EXPIRE_TIME" DATETIME,
                                     "CREATE_TIME" DATETIME,
                                     "UPDATE_TIME" DATETIME,
                                     PRIMARY KEY ("ID")
);

-- T_DS_ALERT
DROP TABLE IF EXISTS "T_DS_ALERT";
CREATE TABLE "T_DS_ALERT" (
                              "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                              "TITLE" VARCHAR(512),
                              "SIGN" VARCHAR(40) NOT NULL DEFAULT '',
                              "CONTENT" CLOB,
                              "ALERT_STATUS" NUMBER(3) DEFAULT 0,
                              "WARNING_TYPE" NUMBER(3) DEFAULT 2,
                              "LOG" CLOB,
                              "ALERTGROUP_ID" NUMBER(11),
                              "CREATE_TIME" DATETIME,
                              "UPDATE_TIME" DATETIME,
                              "PROJECT_CODE" NUMBER(20),
                              "WORKFLOW_DEFINITION_CODE" NUMBER(20),
                              "WORKFLOW_INSTANCE_ID" NUMBER(11),
                              "ALERT_TYPE" NUMBER(11),
                              PRIMARY KEY ("ID")
);
CREATE INDEX "IDX_STATUS" ON "T_DS_ALERT"("ALERT_STATUS");
CREATE INDEX "IDX_SIGN" ON "T_DS_ALERT"("SIGN");

-- T_DS_ALERTGROUP
DROP TABLE IF EXISTS "T_DS_ALERTGROUP";
CREATE TABLE "T_DS_ALERTGROUP"(
                                  "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                  "ALERT_INSTANCE_IDS" VARCHAR(255),
                                  "CREATE_USER_ID" NUMBER(11),
                                  "GROUP_NAME" VARCHAR(255),
                                  "DESCRIPTION" VARCHAR(255),
                                  "CREATE_TIME" DATETIME,
                                  "UPDATE_TIME" DATETIME,
                                  PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "T_DS_ALERTGROUP_NAME_UN" ON "T_DS_ALERTGROUP"("GROUP_NAME");

-- T_DS_COMMAND
DROP TABLE IF EXISTS "T_DS_COMMAND";
CREATE TABLE "T_DS_COMMAND" (
                                "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                "COMMAND_TYPE" NUMBER(3),
                                "WORKFLOW_DEFINITION_CODE" NUMBER(20) NOT NULL,
                                "WORKFLOW_DEFINITION_VERSION" NUMBER(11) DEFAULT 0,
                                "WORKFLOW_INSTANCE_ID" NUMBER(11) DEFAULT 0,
                                "COMMAND_PARAM" CLOB,
                                "TASK_DEPEND_TYPE" NUMBER(3),
                                "FAILURE_STRATEGY" NUMBER(3) DEFAULT 0,
                                "WARNING_TYPE" NUMBER(3) DEFAULT 0,
                                "WARNING_GROUP_ID" NUMBER(11),
                                "SCHEDULE_TIME" DATETIME,
                                "START_TIME" DATETIME,
                                "EXECUTOR_ID" NUMBER(11),
                                "UPDATE_TIME" DATETIME,
                                "WORKFLOW_INSTANCE_PRIORITY" NUMBER(11) DEFAULT 2,
                                "WORKER_GROUP" VARCHAR(255),
                                "TENANT_CODE" VARCHAR(64) DEFAULT 'default',
                                "ENVIRONMENT_CODE" NUMBER(20) DEFAULT -1,
                                "DRY_RUN" NUMBER(3) DEFAULT 0,
                                PRIMARY KEY ("ID")
);
CREATE INDEX "PRIORITY_ID_INDEX" ON "T_DS_COMMAND"("WORKFLOW_INSTANCE_PRIORITY","ID");

-- T_DS_SERIAL_COMMAND
DROP TABLE IF EXISTS "T_DS_SERIAL_COMMAND";
CREATE TABLE "T_DS_SERIAL_COMMAND" (
                                       "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                       "WORKFLOW_DEFINITION_CODE" NUMBER(20) NOT NULL,
                                       "WORKFLOW_DEFINITION_VERSION" NUMBER(11) NOT NULL,
                                       "WORKFLOW_INSTANCE_ID" NUMBER(20) NOT NULL,
                                       "STATE" NUMBER(3) NOT NULL DEFAULT 0,
                                       "COMMAND" CLOB,
                                       "CREATE_TIME" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                       "UPDATE_TIME" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                       PRIMARY KEY ("ID")
);
CREATE INDEX "IDX_WORKFLOW_INSTANCE_ID" ON "T_DS_SERIAL_COMMAND"("WORKFLOW_INSTANCE_ID");

-- T_DS_DATASOURCE
DROP TABLE IF EXISTS "T_DS_DATASOURCE";
CREATE TABLE "T_DS_DATASOURCE" (
                                   "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                   "NAME" VARCHAR(64) NOT NULL,
                                   "NOTE" VARCHAR(255),
                                   "TYPE" NUMBER(3) NOT NULL,
                                   "USER_ID" NUMBER(11) NOT NULL,
                                   "CONNECTION_PARAMS" CLOB NOT NULL,
                                   "CREATE_TIME" DATETIME NOT NULL,
                                   "UPDATE_TIME" DATETIME,
                                   PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "T_DS_DATASOURCE_NAME_UN" ON "T_DS_DATASOURCE"("NAME","TYPE");

-- T_DS_ERROR_COMMAND
DROP TABLE IF EXISTS "T_DS_ERROR_COMMAND";
CREATE TABLE "T_DS_ERROR_COMMAND" (
                                      "ID" NUMBER(11) NOT NULL,
                                      "COMMAND_TYPE" NUMBER(3),
                                      "EXECUTOR_ID" NUMBER(11),
                                      "WORKFLOW_DEFINITION_CODE" NUMBER(20) NOT NULL,
                                      "WORKFLOW_DEFINITION_VERSION" NUMBER(11) DEFAULT 0,
                                      "WORKFLOW_INSTANCE_ID" NUMBER(11) DEFAULT 0,
                                      "COMMAND_PARAM" CLOB,
                                      "TASK_DEPEND_TYPE" NUMBER(3),
                                      "FAILURE_STRATEGY" NUMBER(3) DEFAULT 0,
                                      "WARNING_TYPE" NUMBER(3) DEFAULT 0,
                                      "WARNING_GROUP_ID" NUMBER(11),
                                      "SCHEDULE_TIME" DATETIME,
                                      "START_TIME" DATETIME,
                                      "UPDATE_TIME" DATETIME,
                                      "WORKFLOW_INSTANCE_PRIORITY" NUMBER(11) DEFAULT 2,
                                      "WORKER_GROUP" VARCHAR(255),
                                      "TENANT_CODE" VARCHAR(64) DEFAULT 'default',
                                      "ENVIRONMENT_CODE" NUMBER(20) DEFAULT -1,
                                      "MESSAGE" CLOB,
                                      "DRY_RUN" NUMBER(3) DEFAULT 0,
                                      PRIMARY KEY ("ID")
);

-- T_DS_WORKFLOW_DEFINITION
DROP TABLE IF EXISTS "T_DS_WORKFLOW_DEFINITION";
CREATE TABLE "T_DS_WORKFLOW_DEFINITION" (
                                            "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                            "CODE" NUMBER(20) NOT NULL,
                                            "NAME" VARCHAR(255),
                                            "VERSION" NUMBER(11) NOT NULL DEFAULT 1,
                                            "DESCRIPTION" CLOB,
                                            "PROJECT_CODE" NUMBER(20) NOT NULL,
                                            "RELEASE_STATE" NUMBER(3),
                                            "USER_ID" NUMBER(11),
                                            "GLOBAL_PARAMS" CLOB,
                                            "FLAG" NUMBER(3),
                                            "LOCATIONS" CLOB,
                                            "WARNING_GROUP_ID" NUMBER(11),
                                            "TIMEOUT" NUMBER(11) DEFAULT 0,
                                            "EXECUTION_TYPE" NUMBER(3) DEFAULT 0,
                                            "CREATE_TIME" DATETIME NOT NULL,
                                            "UPDATE_TIME" DATETIME NOT NULL,
                                            PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "WORKFLOW_UNIQUE" ON "T_DS_WORKFLOW_DEFINITION"("NAME","PROJECT_CODE");
CREATE UNIQUE INDEX "UNIQ_WORKFLOW_DEFINITION_CODE" ON "T_DS_WORKFLOW_DEFINITION"("CODE");
CREATE INDEX "IDX_PROJECT_CODE" ON "T_DS_WORKFLOW_DEFINITION"("PROJECT_CODE");

-- T_DS_WORKFLOW_DEFINITION_LOG
DROP TABLE IF EXISTS "T_DS_WORKFLOW_DEFINITION_LOG";
CREATE TABLE "T_DS_WORKFLOW_DEFINITION_LOG" (
                                                "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                                "CODE" NUMBER(20) NOT NULL,
                                                "NAME" VARCHAR(255),
                                                "VERSION" NUMBER(11) NOT NULL DEFAULT 1,
                                                "DESCRIPTION" CLOB,
                                                "PROJECT_CODE" NUMBER(20) NOT NULL,
                                                "RELEASE_STATE" NUMBER(3),
                                                "USER_ID" NUMBER(11),
                                                "GLOBAL_PARAMS" CLOB,
                                                "FLAG" NUMBER(3),
                                                "LOCATIONS" CLOB,
                                                "WARNING_GROUP_ID" NUMBER(11),
                                                "TIMEOUT" NUMBER(11) DEFAULT 0,
                                                "EXECUTION_TYPE" NUMBER(3) DEFAULT 0,
                                                "OPERATOR" NUMBER(11),
                                                "OPERATE_TIME" DATETIME,
                                                "CREATE_TIME" DATETIME NOT NULL,
                                                "UPDATE_TIME" DATETIME NOT NULL,
                                                PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "UNIQ_IDX_CODE_VERSION" ON "T_DS_WORKFLOW_DEFINITION_LOG"("CODE","VERSION");
CREATE INDEX "IDX_PROJECT_CODE_LOG" ON "T_DS_WORKFLOW_DEFINITION_LOG"("PROJECT_CODE");

-- T_DS_TASK_DEFINITION
DROP TABLE IF EXISTS "T_DS_TASK_DEFINITION";
CREATE TABLE "T_DS_TASK_DEFINITION" (
                                        "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                        "CODE" NUMBER(20) NOT NULL,
                                        "NAME" VARCHAR(255),
                                        "VERSION" NUMBER(11) NOT NULL DEFAULT 1,
                                        "DESCRIPTION" CLOB,
                                        "PROJECT_CODE" NUMBER(20) NOT NULL,
                                        "USER_ID" NUMBER(11),
                                        "TASK_TYPE" VARCHAR(50) NOT NULL,
                                        "TASK_EXECUTE_TYPE" NUMBER(11) DEFAULT 0,
                                        "TASK_PARAMS" CLOB,
                                        "FLAG" NUMBER(3),
                                        "TASK_PRIORITY" NUMBER(3) DEFAULT 2,
                                        "WORKER_GROUP" VARCHAR(255),
                                        "ENVIRONMENT_CODE" NUMBER(20) DEFAULT -1,
                                        "FAIL_RETRY_TIMES" NUMBER(11),
                                        "FAIL_RETRY_INTERVAL" NUMBER(11),
                                        "TIMEOUT_FLAG" NUMBER(3) DEFAULT 0,
                                        "TIMEOUT_NOTIFY_STRATEGY" NUMBER(3),
                                        "TIMEOUT" NUMBER(11) DEFAULT 0,
                                        "DELAY_TIME" NUMBER(11) DEFAULT 0,
                                        "RESOURCE_IDS" CLOB,
                                        "TASK_GROUP_ID" NUMBER(11),
                                        "TASK_GROUP_PRIORITY" NUMBER(3) DEFAULT 0,
                                        "CPU_QUOTA" NUMBER(11) DEFAULT -1 NOT NULL,
                                        "MEMORY_MAX" NUMBER(11) DEFAULT -1 NOT NULL,
                                        "CREATE_TIME" DATETIME NOT NULL,
                                        "UPDATE_TIME" DATETIME NOT NULL,
                                        PRIMARY KEY ("ID","CODE")
);
CREATE INDEX "IDX_PROJECT_CODE_TASK" ON "T_DS_TASK_DEFINITION"("PROJECT_CODE");

-- T_DS_TASK_DEFINITION_LOG
DROP TABLE IF EXISTS "T_DS_TASK_DEFINITION_LOG";
CREATE TABLE "T_DS_TASK_DEFINITION_LOG" (
                                            "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                            "CODE" NUMBER(20) NOT NULL,
                                            "NAME" VARCHAR(255),
                                            "VERSION" NUMBER(11) NOT NULL DEFAULT 1,
                                            "DESCRIPTION" CLOB,
                                            "PROJECT_CODE" NUMBER(20) NOT NULL,
                                            "USER_ID" NUMBER(11),
                                            "TASK_TYPE" VARCHAR(50) NOT NULL,
                                            "TASK_EXECUTE_TYPE" NUMBER(11) DEFAULT 0,
                                            "TASK_PARAMS" CLOB,
                                            "FLAG" NUMBER(3),
                                            "TASK_PRIORITY" NUMBER(3) DEFAULT 2,
                                            "WORKER_GROUP" VARCHAR(255),
                                            "ENVIRONMENT_CODE" NUMBER(20) DEFAULT -1,
                                            "FAIL_RETRY_TIMES" NUMBER(11),
                                            "FAIL_RETRY_INTERVAL" NUMBER(11),
                                            "TIMEOUT_FLAG" NUMBER(3) DEFAULT 0,
                                            "TIMEOUT_NOTIFY_STRATEGY" NUMBER(3),
                                            "TIMEOUT" NUMBER(11) DEFAULT 0,
                                            "DELAY_TIME" NUMBER(11) DEFAULT 0,
                                            "RESOURCE_IDS" CLOB,
                                            "OPERATOR" NUMBER(11),
                                            "TASK_GROUP_ID" NUMBER(11),
                                            "TASK_GROUP_PRIORITY" NUMBER(3) DEFAULT 0,
                                            "OPERATE_TIME" DATETIME,
                                            "CPU_QUOTA" NUMBER(11) DEFAULT -1 NOT NULL,
                                            "MEMORY_MAX" NUMBER(11) DEFAULT -1 NOT NULL,
                                            "CREATE_TIME" DATETIME NOT NULL,
                                            "UPDATE_TIME" DATETIME NOT NULL,
                                            PRIMARY KEY ("ID")
);
CREATE INDEX "IDX_CODE_VERSION_TASK" ON "T_DS_TASK_DEFINITION_LOG"("CODE","VERSION");
CREATE INDEX "IDX_PROJECT_CODE_TASK_LOG" ON "T_DS_TASK_DEFINITION_LOG"("PROJECT_CODE");

-- T_DS_WORKFLOW_TASK_RELATION
DROP TABLE IF EXISTS "T_DS_WORKFLOW_TASK_RELATION";
CREATE TABLE "T_DS_WORKFLOW_TASK_RELATION" (
                                               "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                               "NAME" VARCHAR(255),
                                               "PROJECT_CODE" NUMBER(20) NOT NULL,
                                               "WORKFLOW_DEFINITION_CODE" NUMBER(20) NOT NULL,
                                               "WORKFLOW_DEFINITION_VERSION" NUMBER(11) NOT NULL,
                                               "PRE_TASK_CODE" NUMBER(20) NOT NULL,
                                               "PRE_TASK_VERSION" NUMBER(11) NOT NULL,
                                               "POST_TASK_CODE" NUMBER(20) NOT NULL,
                                               "POST_TASK_VERSION" NUMBER(11) NOT NULL,
                                               "CONDITION_TYPE" NUMBER(3),
                                               "CONDITION_PARAMS" CLOB,
                                               "CREATE_TIME" DATETIME NOT NULL,
                                               "UPDATE_TIME" DATETIME NOT NULL,
                                               PRIMARY KEY ("ID")
);
CREATE INDEX "IDX_CODE_REL" ON "T_DS_WORKFLOW_TASK_RELATION"("PROJECT_CODE","WORKFLOW_DEFINITION_CODE");
CREATE INDEX "IDX_PRE_TASK_CODE_VERSION" ON "T_DS_WORKFLOW_TASK_RELATION"("PRE_TASK_CODE","PRE_TASK_VERSION");
CREATE INDEX "IDX_POST_TASK_CODE_VERSION" ON "T_DS_WORKFLOW_TASK_RELATION"("POST_TASK_CODE","POST_TASK_VERSION");

-- ----------------------------
-- 续：创建 DolphinScheduler 核心元数据表
-- ----------------------------

-- T_DS_WORKFLOW_TASK_RELATION_LOG
DROP TABLE IF EXISTS "T_DS_WORKFLOW_TASK_RELATION_LOG";
CREATE TABLE "T_DS_WORKFLOW_TASK_RELATION_LOG" (
                                                   "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                                   "NAME" VARCHAR(255),
                                                   "PROJECT_CODE" NUMBER(20) NOT NULL,
                                                   "WORKFLOW_DEFINITION_CODE" NUMBER(20) NOT NULL,
                                                   "WORKFLOW_DEFINITION_VERSION" NUMBER(11) NOT NULL,
                                                   "PRE_TASK_CODE" NUMBER(20) NOT NULL,
                                                   "PRE_TASK_VERSION" NUMBER(11) NOT NULL,
                                                   "POST_TASK_CODE" NUMBER(20) NOT NULL,
                                                   "POST_TASK_VERSION" NUMBER(11) NOT NULL,
                                                   "CONDITION_TYPE" NUMBER(3),
                                                   "CONDITION_PARAMS" CLOB,
                                                   "OPERATOR" NUMBER(11),
                                                   "OPERATE_TIME" DATETIME,
                                                   "CREATE_TIME" DATETIME NOT NULL,
                                                   "UPDATE_TIME" DATETIME NOT NULL,
                                                   PRIMARY KEY ("ID")
);
CREATE INDEX "IDX_WORKFLOW_CODE_VERSION_LOG" ON "T_DS_WORKFLOW_TASK_RELATION_LOG"("WORKFLOW_DEFINITION_CODE","WORKFLOW_DEFINITION_VERSION");

-- T_DS_WORKFLOW_INSTANCE
DROP TABLE IF EXISTS "T_DS_WORKFLOW_INSTANCE";
CREATE TABLE "T_DS_WORKFLOW_INSTANCE" (
                                          "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                          "NAME" VARCHAR(255),
                                          "WORKFLOW_DEFINITION_CODE" NUMBER(20) NOT NULL,
                                          "WORKFLOW_DEFINITION_VERSION" NUMBER(11) NOT NULL DEFAULT 1,
                                          "PROJECT_CODE" NUMBER(20),
                                          "STATE" NUMBER(3),
                                          "STATE_HISTORY" CLOB,
                                          "RECOVERY" NUMBER(3),
                                          "START_TIME" DATETIME,
                                          "END_TIME" DATETIME,
                                          "RUN_TIMES" NUMBER(11),
                                          "HOST" VARCHAR(135),
                                          "COMMAND_TYPE" NUMBER(3),
                                          "COMMAND_PARAM" CLOB,
                                          "TASK_DEPEND_TYPE" NUMBER(3),
                                          "MAX_TRY_TIMES" NUMBER(3) DEFAULT 0,
                                          "FAILURE_STRATEGY" NUMBER(3) DEFAULT 0,
                                          "WARNING_TYPE" NUMBER(3) DEFAULT 0,
                                          "WARNING_GROUP_ID" NUMBER(11),
                                          "SCHEDULE_TIME" DATETIME,
                                          "COMMAND_START_TIME" DATETIME,
                                          "GLOBAL_PARAMS" CLOB,
                                          "FLAG" NUMBER(3) DEFAULT 1,
                                          "UPDATE_TIME" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                          "IS_SUB_WORKFLOW" NUMBER(11) DEFAULT 0,
                                          "EXECUTOR_ID" NUMBER(11) NOT NULL,
                                          "EXECUTOR_NAME" VARCHAR(64),
                                          "HISTORY_CMD" CLOB,
                                          "WORKFLOW_INSTANCE_PRIORITY" NUMBER(11) DEFAULT 2,
                                          "WORKER_GROUP" VARCHAR(255),
                                          "ENVIRONMENT_CODE" NUMBER(20) DEFAULT -1,
                                          "TIMEOUT" NUMBER(11) DEFAULT 0,
                                          "TENANT_CODE" VARCHAR(64) DEFAULT 'default',
                                          "VAR_POOL" CLOB,
                                          "DRY_RUN" NUMBER(3) DEFAULT 0,
                                          "NEXT_WORKFLOW_INSTANCE_ID" NUMBER(11) DEFAULT 0,
                                          "RESTART_TIME" DATETIME,
                                          PRIMARY KEY ("ID")
);
CREATE INDEX "WORKFLOW_INSTANCE_INDEX" ON "T_DS_WORKFLOW_INSTANCE"("WORKFLOW_DEFINITION_CODE","ID");
CREATE INDEX "START_TIME_INDEX" ON "T_DS_WORKFLOW_INSTANCE"("START_TIME","END_TIME");

-- T_DS_PROJECT
DROP TABLE IF EXISTS "T_DS_PROJECT";
CREATE TABLE "T_DS_PROJECT" (
                                "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                "NAME" VARCHAR(255),
                                "CODE" NUMBER(20) NOT NULL,
                                "DESCRIPTION" VARCHAR(255),
                                "USER_ID" NUMBER(11),
                                "FLAG" NUMBER(3) DEFAULT 1,
                                "CREATE_TIME" DATETIME NOT NULL,
                                "UPDATE_TIME" DATETIME,
                                PRIMARY KEY ("ID")
);
CREATE INDEX "USER_ID_INDEX" ON "T_DS_PROJECT"("USER_ID");
CREATE UNIQUE INDEX "UNIQUE_NAME" ON "T_DS_PROJECT"("NAME");
CREATE UNIQUE INDEX "UNIQUE_CODE" ON "T_DS_PROJECT"("CODE");

-- T_DS_PROJECT_PARAMETER
DROP TABLE IF EXISTS "T_DS_PROJECT_PARAMETER";
CREATE TABLE "T_DS_PROJECT_PARAMETER" (
                                          "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                          "PARAM_NAME" VARCHAR(255) NOT NULL,
                                          "PARAM_VALUE" CLOB NOT NULL,
                                          "PARAM_DATA_TYPE" VARCHAR(50) DEFAULT 'VARCHAR',
                                          "CODE" NUMBER(20) NOT NULL,
                                          "PROJECT_CODE" NUMBER(20) NOT NULL,
                                          "USER_ID" NUMBER(11),
                                          "OPERATOR" NUMBER(11),
                                          "CREATE_TIME" DATETIME NOT NULL,
                                          "UPDATE_TIME" DATETIME,
                                          PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "UNIQUE_PROJECT_PARAMETER_NAME" ON "T_DS_PROJECT_PARAMETER"("PROJECT_CODE","PARAM_NAME");
CREATE UNIQUE INDEX "UNIQUE_PROJECT_PARAMETER_CODE" ON "T_DS_PROJECT_PARAMETER"("CODE");

-- T_DS_PROJECT_PREFERENCE
DROP TABLE IF EXISTS "T_DS_PROJECT_PREFERENCE";
CREATE TABLE "T_DS_PROJECT_PREFERENCE" (
                                           "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                           "CODE" NUMBER(20) NOT NULL,
                                           "PROJECT_CODE" NUMBER(20) NOT NULL,
                                           "PREFERENCES" VARCHAR(512) NOT NULL,
                                           "USER_ID" NUMBER(11),
                                           "STATE" NUMBER(11) DEFAULT 1,
                                           "CREATE_TIME" DATETIME NOT NULL,
                                           "UPDATE_TIME" DATETIME,
                                           PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "UNIQUE_PROJECT_PREFERENCE_PROJECT_CODE" ON "T_DS_PROJECT_PREFERENCE"("PROJECT_CODE");
CREATE UNIQUE INDEX "UNIQUE_PROJECT_PREFERENCE_CODE" ON "T_DS_PROJECT_PREFERENCE"("CODE");

-- T_DS_QUEUE
DROP TABLE IF EXISTS "T_DS_QUEUE";
CREATE TABLE "T_DS_QUEUE" (
                              "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                              "QUEUE_NAME" VARCHAR(64),
                              "QUEUE" VARCHAR(64),
                              "CREATE_TIME" DATETIME,
                              "UPDATE_TIME" DATETIME,
                              PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "UNIQUE_QUEUE_NAME" ON "T_DS_QUEUE"("QUEUE_NAME");

-- T_DS_RELATION_DATASOURCE_USER
DROP TABLE IF EXISTS "T_DS_RELATION_DATASOURCE_USER";
CREATE TABLE "T_DS_RELATION_DATASOURCE_USER" (
                                                 "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                                 "USER_ID" NUMBER(11) NOT NULL,
                                                 "DATASOURCE_ID" NUMBER(11),
                                                 "PERM" NUMBER(11) DEFAULT 1,
                                                 "CREATE_TIME" DATETIME,
                                                 "UPDATE_TIME" DATETIME,
                                                 PRIMARY KEY ("ID")
);

-- T_DS_RELATION_WORKFLOW_INSTANCE
DROP TABLE IF EXISTS "T_DS_RELATION_WORKFLOW_INSTANCE";
CREATE TABLE "T_DS_RELATION_WORKFLOW_INSTANCE" (
                                                   "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                                   "PARENT_WORKFLOW_INSTANCE_ID" NUMBER(11),
                                                   "PARENT_TASK_INSTANCE_ID" NUMBER(11),
                                                   "WORKFLOW_INSTANCE_ID" NUMBER(11),
                                                   PRIMARY KEY ("ID")
);
CREATE INDEX "IDX_PARENT_WORKFLOW_TASK" ON "T_DS_RELATION_WORKFLOW_INSTANCE"("PARENT_WORKFLOW_INSTANCE_ID","PARENT_TASK_INSTANCE_ID");
CREATE INDEX "IDX_WORKFLOW_INSTANCE_ID_REL_WK" ON "T_DS_RELATION_WORKFLOW_INSTANCE"("WORKFLOW_INSTANCE_ID");

-- T_DS_RELATION_PROJECT_USER
DROP TABLE IF EXISTS "T_DS_RELATION_PROJECT_USER";
CREATE TABLE "T_DS_RELATION_PROJECT_USER" (
                                              "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                              "USER_ID" NUMBER(11) NOT NULL,
                                              "PROJECT_ID" NUMBER(11),
                                              "PERM" NUMBER(11) DEFAULT 1,
                                              "CREATE_TIME" DATETIME,
                                              "UPDATE_TIME" DATETIME,
                                              PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "UNIQ_UID_PID" ON "T_DS_RELATION_PROJECT_USER"("USER_ID","PROJECT_ID");

-- T_DS_RELATION_RESOURCES_USER
DROP TABLE IF EXISTS "T_DS_RELATION_RESOURCES_USER";
CREATE TABLE "T_DS_RELATION_RESOURCES_USER" (
                                                "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                                "USER_ID" NUMBER(11) NOT NULL,
                                                "RESOURCES_ID" NUMBER(11),
                                                "PERM" NUMBER(11) DEFAULT 1,
                                                "CREATE_TIME" DATETIME,
                                                "UPDATE_TIME" DATETIME,
                                                PRIMARY KEY ("ID")
);

-- T_DS_RELATION_UDFS_USER
DROP TABLE IF EXISTS "T_DS_RELATION_UDFS_USER";
CREATE TABLE "T_DS_RELATION_UDFS_USER" (
                                           "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                           "USER_ID" NUMBER(11) NOT NULL,
                                           "UDF_ID" NUMBER(11),
                                           "PERM" NUMBER(11) DEFAULT 1,
                                           "CREATE_TIME" DATETIME,
                                           "UPDATE_TIME" DATETIME,
                                           PRIMARY KEY ("ID")
);

-- T_DS_RESOURCES
DROP TABLE IF EXISTS "T_DS_RESOURCES";
CREATE TABLE "T_DS_RESOURCES" (
                                  "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                  "ALIAS" VARCHAR(64),
                                  "FILE_NAME" VARCHAR(64),
                                  "DESCRIPTION" VARCHAR(255),
                                  "USER_ID" NUMBER(11),
                                  "TYPE" NUMBER(3),
                                  "SIZE" NUMBER(20),
                                  "CREATE_TIME" DATETIME,
                                  "UPDATE_TIME" DATETIME,
                                  "PID" NUMBER(11),
                                  "FULL_NAME" VARCHAR(128),
                                  "IS_DIRECTORY" NUMBER(3),
                                  PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "T_DS_RESOURCES_UN" ON "T_DS_RESOURCES"("FULL_NAME","TYPE");

-- T_DS_SCHEDULES
DROP TABLE IF EXISTS "T_DS_SCHEDULES";
CREATE TABLE "T_DS_SCHEDULES" (
                                  "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                  "WORKFLOW_DEFINITION_CODE" NUMBER(20) NOT NULL,
                                  "START_TIME" DATETIME NOT NULL,
                                  "END_TIME" DATETIME NOT NULL,
                                  "TIMEZONE_ID" VARCHAR(40),
                                  "CRONTAB" VARCHAR(255) NOT NULL,
                                  "FAILURE_STRATEGY" NUMBER(3) NOT NULL,
                                  "USER_ID" NUMBER(11) NOT NULL,
                                  "RELEASE_STATE" NUMBER(3) NOT NULL,
                                  "WARNING_TYPE" NUMBER(3) NOT NULL,
                                  "WARNING_GROUP_ID" NUMBER(11),
                                  "WORKFLOW_INSTANCE_PRIORITY" NUMBER(11) DEFAULT 2,
                                  "WORKER_GROUP" VARCHAR(255) DEFAULT '',
                                  "TENANT_CODE" VARCHAR(64) DEFAULT 'default',
                                  "ENVIRONMENT_CODE" NUMBER(20) DEFAULT -1,
                                  "CREATE_TIME" DATETIME NOT NULL,
                                  "UPDATE_TIME" DATETIME NOT NULL,
                                  PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "UNIQ_WORKFLOW_DEFINITION_CODE_SCH" ON "T_DS_SCHEDULES"("WORKFLOW_DEFINITION_CODE");

-- T_DS_SESSION
DROP TABLE IF EXISTS "T_DS_SESSION";
CREATE TABLE "T_DS_SESSION" (
                                "ID" VARCHAR(64) NOT NULL,
                                "USER_ID" NUMBER(11),
                                "IP" VARCHAR(45),
                                "LAST_LOGIN_TIME" DATETIME,
                                PRIMARY KEY ("ID")
);

-- T_DS_TASK_INSTANCE
DROP TABLE IF EXISTS "T_DS_TASK_INSTANCE";
CREATE TABLE "T_DS_TASK_INSTANCE" (
                                      "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                      "NAME" VARCHAR(255),
                                      "TASK_TYPE" VARCHAR(50) NOT NULL,
                                      "TASK_EXECUTE_TYPE" NUMBER(11) DEFAULT 0,
                                      "TASK_CODE" NUMBER(20) NOT NULL,
                                      "TASK_DEFINITION_VERSION" NUMBER(11) NOT NULL DEFAULT 1,
                                      "WORKFLOW_INSTANCE_ID" NUMBER(11),
                                      "WORKFLOW_INSTANCE_NAME" VARCHAR(255),
                                      "PROJECT_CODE" NUMBER(20),
                                      "STATE" NUMBER(3),
                                      "SUBMIT_TIME" DATETIME,
                                      "START_TIME" DATETIME,
                                      "END_TIME" DATETIME,
                                      "HOST" VARCHAR(135),
                                      "EXECUTE_PATH" VARCHAR(200),
                                      "LOG_PATH" CLOB,
                                      "ALERT_FLAG" NUMBER(3),
                                      "RETRY_TIMES" NUMBER(3) DEFAULT 0,
                                      "PID" NUMBER(3),
                                      "APP_LINK" CLOB,
                                      "TASK_PARAMS" CLOB,
                                      "FLAG" NUMBER(3) DEFAULT 1,
                                      "RETRY_INTERVAL" NUMBER(3),
                                      "MAX_RETRY_TIMES" NUMBER(3),
                                      "TASK_INSTANCE_PRIORITY" NUMBER(11),
                                      "WORKER_GROUP" VARCHAR(255),
                                      "ENVIRONMENT_CODE" NUMBER(20) DEFAULT -1,
                                      "ENVIRONMENT_CONFIG" CLOB,
                                      "EXECUTOR_ID" NUMBER(11),
                                      "EXECUTOR_NAME" VARCHAR(64),
                                      "FIRST_SUBMIT_TIME" DATETIME,
                                      "DELAY_TIME" NUMBER(3) DEFAULT 0,
                                      "VAR_POOL" CLOB,
                                      "TASK_GROUP_ID" NUMBER(11),
                                      "DRY_RUN" NUMBER(3) DEFAULT 0,
                                      "CPU_QUOTA" NUMBER(11) DEFAULT -1 NOT NULL,
                                      "MEMORY_MAX" NUMBER(11) DEFAULT -1 NOT NULL,
                                      PRIMARY KEY ("ID")
);
CREATE INDEX "WORKFLOW_INSTANCE_ID_TASK" ON "T_DS_TASK_INSTANCE"("WORKFLOW_INSTANCE_ID");
CREATE INDEX "IDX_CODE_VERSION_TASK_INST" ON "T_DS_TASK_INSTANCE"("TASK_CODE","TASK_DEFINITION_VERSION");

-- T_DS_TASK_INSTANCE_CONTEXT
DROP TABLE IF EXISTS "T_DS_TASK_INSTANCE_CONTEXT";
CREATE TABLE "T_DS_TASK_INSTANCE_CONTEXT" (
                                              "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                              "TASK_INSTANCE_ID" NUMBER(11) NOT NULL,
                                              "CONTEXT" CLOB NOT NULL,
                                              "CONTEXT_TYPE" VARCHAR(200) NOT NULL,
                                              "CREATE_TIME" DATETIME NOT NULL,
                                              "UPDATE_TIME" DATETIME NOT NULL,
                                              PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "TASK_INSTANCE_ID_CONTEXT_TYPE" ON "T_DS_TASK_INSTANCE_CONTEXT"("TASK_INSTANCE_ID","CONTEXT_TYPE");

-- T_DS_TENANT
DROP TABLE IF EXISTS "T_DS_TENANT";
CREATE TABLE "T_DS_TENANT" (
                               "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                               "TENANT_CODE" VARCHAR(64),
                               "DESCRIPTION" VARCHAR(255),
                               "QUEUE_ID" NUMBER(11),
                               "CREATE_TIME" DATETIME,
                               "UPDATE_TIME" DATETIME,
                               PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "UNIQUE_TENANT_CODE" ON "T_DS_TENANT"("TENANT_CODE");

-- T_DS_UDFS
DROP TABLE IF EXISTS "T_DS_UDFS";
CREATE TABLE "T_DS_UDFS" (
                             "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                             "USER_ID" NUMBER(11) NOT NULL,
                             "FUNC_NAME" VARCHAR(255) NOT NULL,
                             "CLASS_NAME" VARCHAR(255) NOT NULL,
                             "TYPE" NUMBER(3) NOT NULL,
                             "ARG_TYPES" VARCHAR(255),
                             "DATABASE" VARCHAR(255),
                             "DESCRIPTION" VARCHAR(255),
                             "RESOURCE_ID" NUMBER(11) NOT NULL,
                             "RESOURCE_NAME" VARCHAR(255) NOT NULL,
                             "CREATE_TIME" DATETIME NOT NULL,
                             "UPDATE_TIME" DATETIME NOT NULL,
                             PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "UNIQUE_FUNC_NAME" ON "T_DS_UDFS"("FUNC_NAME");

-- T_DS_USER
DROP TABLE IF EXISTS "T_DS_USER";
CREATE TABLE "T_DS_USER" (
                             "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                             "USER_NAME" VARCHAR(64),
                             "USER_PASSWORD" VARCHAR(64),
                             "USER_TYPE" NUMBER(3,0),
                             "EMAIL" VARCHAR(64),
                             "PHONE" VARCHAR(11),
                             "TENANT_ID" NUMBER(11) DEFAULT -1,
                             "CREATE_TIME" DATETIME,
                             "UPDATE_TIME" DATETIME,
                             "QUEUE" VARCHAR(64),
                             "STATE" NUMBER(3,0) DEFAULT 1,
                             "TIME_ZONE" VARCHAR(32),
                             PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "USER_NAME_UNIQUE" ON "T_DS_USER"("USER_NAME");

-- T_DS_WORKER_GROUP
DROP TABLE IF EXISTS "T_DS_WORKER_GROUP";
CREATE TABLE "T_DS_WORKER_GROUP" (
                                     "ID" NUMBER(20) IDENTITY(1,1) NOT NULL,
                                     "NAME" VARCHAR(255) NOT NULL,
                                     "ADDR_LIST" CLOB,
                                     "CREATE_TIME" DATETIME,
                                     "UPDATE_TIME" DATETIME,
                                     "DESCRIPTION" CLOB,
                                     PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "NAME_UNIQUE" ON "T_DS_WORKER_GROUP"("NAME");

-- T_DS_VERSION
DROP TABLE IF EXISTS "T_DS_VERSION";
CREATE TABLE "T_DS_VERSION" (
                                "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                "VERSION" VARCHAR(63) NOT NULL,
                                PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "VERSION_UNIQUE" ON "T_DS_VERSION"("VERSION");

-- T_DS_PLUGIN_DEFINE
DROP TABLE IF EXISTS "T_DS_PLUGIN_DEFINE";
CREATE TABLE "T_DS_PLUGIN_DEFINE" (
                                      "ID" NUMBER IDENTITY(1,1) NOT NULL,
                                      "PLUGIN_NAME" VARCHAR(255) NOT NULL,
                                      "PLUGIN_TYPE" VARCHAR(63) NOT NULL,
                                      "PLUGIN_PARAMS" CLOB,
                                      "CREATE_TIME" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                      "UPDATE_TIME" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                      PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "T_DS_PLUGIN_DEFINE_UN" ON "T_DS_PLUGIN_DEFINE"("PLUGIN_NAME","PLUGIN_TYPE");

-- T_DS_ALERT_PLUGIN_INSTANCE
DROP TABLE IF EXISTS "T_DS_ALERT_PLUGIN_INSTANCE";
CREATE TABLE "T_DS_ALERT_PLUGIN_INSTANCE" (
                                              "ID" NUMBER IDENTITY(1,1) NOT NULL,
                                              "PLUGIN_DEFINE_ID" NUMBER NOT NULL,
                                              "PLUGIN_INSTANCE_PARAMS" CLOB,
                                              "CREATE_TIME" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                              "UPDATE_TIME" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                              "INSTANCE_NAME" VARCHAR(255),
                                              PRIMARY KEY ("ID")
);

-- T_DS_RELATION_PROJECT_WORKER_GROUP
DROP TABLE IF EXISTS "T_DS_RELATION_PROJECT_WORKER_GROUP";
CREATE TABLE "T_DS_RELATION_PROJECT_WORKER_GROUP" (
                                                      "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                                      "PROJECT_CODE" NUMBER(20) NOT NULL,
                                                      "WORKER_GROUP" VARCHAR(255),
                                                      "CREATE_TIME" DATETIME,
                                                      "UPDATE_TIME" DATETIME,
                                                      PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "UNIQUE_PROJECT_WORKER_GROUP" ON "T_DS_RELATION_PROJECT_WORKER_GROUP"("PROJECT_CODE","WORKER_GROUP");

-- T_DS_ENVIRONMENT
DROP TABLE IF EXISTS "T_DS_ENVIRONMENT";
CREATE TABLE "T_DS_ENVIRONMENT" (
                                    "ID" NUMBER(20) IDENTITY(1,1) NOT NULL,
                                    "CODE" NUMBER(20),
                                    "NAME" VARCHAR(255) NOT NULL,
                                    "CONFIG" CLOB,
                                    "DESCRIPTION" CLOB,
                                    "OPERATOR" NUMBER(11),
                                    "CREATE_TIME" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                    "UPDATE_TIME" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                    PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "ENVIRONMENT_NAME_UNIQUE" ON "T_DS_ENVIRONMENT"("NAME");
CREATE UNIQUE INDEX "ENVIRONMENT_CODE_UNIQUE" ON "T_DS_ENVIRONMENT"("CODE");

-- T_DS_ENVIRONMENT_WORKER_GROUP_RELATION
DROP TABLE IF EXISTS "T_DS_ENVIRONMENT_WORKER_GROUP_RELATION";
CREATE TABLE "T_DS_ENVIRONMENT_WORKER_GROUP_RELATION" (
                                                          "ID" NUMBER(20) IDENTITY(1,1) NOT NULL,
                                                          "ENVIRONMENT_CODE" NUMBER(20) NOT NULL,
                                                          "WORKER_GROUP" VARCHAR(255) NOT NULL,
                                                          "OPERATOR" NUMBER(11),
                                                          "CREATE_TIME" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                                          "UPDATE_TIME" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                                          PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "ENVIRONMENT_WORKER_GROUP_UNIQUE" ON "T_DS_ENVIRONMENT_WORKER_GROUP_RELATION"("ENVIRONMENT_CODE","WORKER_GROUP");

-- T_DS_TASK_GROUP_QUEUE
DROP TABLE IF EXISTS "T_DS_TASK_GROUP_QUEUE";
CREATE TABLE "T_DS_TASK_GROUP_QUEUE" (
                                         "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                         "TASK_ID" NUMBER(11),
                                         "TASK_NAME" VARCHAR(255),
                                         "GROUP_ID" NUMBER(11),
                                         "WORKFLOW_INSTANCE_ID" NUMBER(11),
                                         "PRIORITY" NUMBER(8) DEFAULT 0,
                                         "STATUS" NUMBER(3) DEFAULT -1,
                                         "FORCE_START" NUMBER(3) DEFAULT 0,
                                         "IN_QUEUE" NUMBER(3) DEFAULT 0,
                                         "CREATE_TIME" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                         "UPDATE_TIME" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                         PRIMARY KEY( "ID" )
);
CREATE INDEX "IDX_T_DS_TASK_GROUP_QUEUE_IN_QUEUE" ON "T_DS_TASK_GROUP_QUEUE"("IN_QUEUE");
CREATE INDEX "IDX_TASK_ID_TGQ" ON "T_DS_TASK_GROUP_QUEUE"("TASK_ID");
CREATE INDEX "IDX_GROUP_ID_TGQ" ON "T_DS_TASK_GROUP_QUEUE"("GROUP_ID");
CREATE INDEX "IDX_STATUS_TGQ" ON "T_DS_TASK_GROUP_QUEUE"("STATUS");
CREATE INDEX "IDX_WORKFLOW_INSTANCE_ID_TGQ" ON "T_DS_TASK_GROUP_QUEUE"("WORKFLOW_INSTANCE_ID");

-- T_DS_TASK_GROUP
DROP TABLE IF EXISTS "T_DS_TASK_GROUP";
CREATE TABLE "T_DS_TASK_GROUP" (
                                   "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                   "NAME" VARCHAR(255),
                                   "DESCRIPTION" VARCHAR(255),
                                   "GROUP_SIZE" NUMBER(11) NOT NULL,
                                   "USE_SIZE" NUMBER(11) DEFAULT 0,
                                   "USER_ID" NUMBER(11),
                                   "PROJECT_CODE" NUMBER(20) DEFAULT 0,
                                   "STATUS" NUMBER(3) DEFAULT 1,
                                   "CREATE_TIME" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                   "UPDATE_TIME" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                   PRIMARY KEY("ID")
);

-- T_DS_AUDIT_LOG
DROP TABLE IF EXISTS "T_DS_AUDIT_LOG";
CREATE TABLE "T_DS_AUDIT_LOG" (
                                  "ID" NUMBER(20) IDENTITY(1,1) NOT NULL,
                                  "USER_ID" NUMBER(11) NOT NULL,
                                  "MODEL_ID" NUMBER(20),
                                  "MODEL_NAME" VARCHAR(100),
                                  "MODEL_TYPE" VARCHAR(100) NOT NULL,
                                  "OPERATION_TYPE" VARCHAR(100) NOT NULL,
                                  "DESCRIPTION" VARCHAR(100),
                                  "LATENCY" NUMBER(11),
                                  "DETAIL" VARCHAR(100),
                                  "CREATE_TIME" DATETIME DEFAULT CURRENT_TIMESTAMP,
                                  PRIMARY KEY ("ID")
);

-- T_DS_K8S
DROP TABLE IF EXISTS "T_DS_K8S";
CREATE TABLE "T_DS_K8S" (
                            "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                            "K8S_NAME" VARCHAR(255),
                            "K8S_CONFIG" CLOB,
                            "CREATE_TIME" DATETIME,
                            "UPDATE_TIME" DATETIME,
                            PRIMARY KEY ("ID")
);

-- T_DS_K8S_NAMESPACE
DROP TABLE IF EXISTS "T_DS_K8S_NAMESPACE";
CREATE TABLE "T_DS_K8S_NAMESPACE" (
                                      "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                      "CODE" NUMBER(20) NOT NULL DEFAULT 0,
                                      "NAMESPACE" VARCHAR(255),
                                      "USER_ID" NUMBER(11),
                                      "CLUSTER_CODE" NUMBER(20) NOT NULL DEFAULT 0,
                                      "CREATE_TIME" DATETIME,
                                      "UPDATE_TIME" DATETIME,
                                      PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "K8S_NAMESPACE_UNIQUE" ON "T_DS_K8S_NAMESPACE"("NAMESPACE","CLUSTER_CODE");

-- T_DS_RELATION_NAMESPACE_USER
DROP TABLE IF EXISTS "T_DS_RELATION_NAMESPACE_USER";
CREATE TABLE "T_DS_RELATION_NAMESPACE_USER" (
                                                "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                                "USER_ID" NUMBER(11) NOT NULL,
                                                "NAMESPACE_ID" NUMBER(11),
                                                "PERM" NUMBER(11) DEFAULT 1,
                                                "CREATE_TIME" DATETIME,
                                                "UPDATE_TIME" DATETIME,
                                                PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "NAMESPACE_USER_UNIQUE" ON "T_DS_RELATION_NAMESPACE_USER"("USER_ID","NAMESPACE_ID");

-- T_DS_ALERT_SEND_STATUS
DROP TABLE IF EXISTS "T_DS_ALERT_SEND_STATUS";
CREATE TABLE "T_DS_ALERT_SEND_STATUS" (
                                          "ID" NUMBER(11) IDENTITY(1,1) NOT NULL,
                                          "ALERT_ID" NUMBER(11) NOT NULL,
                                          "ALERT_PLUGIN_INSTANCE_ID" NUMBER(11) NOT NULL,
                                          "SEND_STATUS" NUMBER(3) DEFAULT 0,
                                          "LOG" CLOB,
                                          "CREATE_TIME" DATETIME,
                                          PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "ALERT_SEND_STATUS_UNIQUE" ON "T_DS_ALERT_SEND_STATUS"("ALERT_ID","ALERT_PLUGIN_INSTANCE_ID");

-- T_DS_CLUSTER
DROP TABLE IF EXISTS "T_DS_CLUSTER";
CREATE TABLE "T_DS_CLUSTER"(
                               "ID" NUMBER(20) IDENTITY(1,1) NOT NULL,
                               "CODE" NUMBER(20),
                               "NAME" VARCHAR(255) NOT NULL,
                               "CONFIG" CLOB,
                               "DESCRIPTION" CLOB,
                               "OPERATOR" NUMBER(11),
                               "CREATE_TIME" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                               "UPDATE_TIME" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                               PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "CLUSTER_NAME_UNIQUE" ON "T_DS_CLUSTER"("NAME");
CREATE UNIQUE INDEX "CLUSTER_CODE_UNIQUE" ON "T_DS_CLUSTER"("CODE");

-- T_DS_FAV_TASK
DROP TABLE IF EXISTS "T_DS_FAV_TASK";
CREATE TABLE "T_DS_FAV_TASK"
(
    "ID" NUMBER(20) IDENTITY(1,1) NOT NULL,
    "TASK_TYPE" VARCHAR(64) NOT NULL,
    "USER_ID" NUMBER(11) NOT NULL,
    PRIMARY KEY ("ID")
);

DROP TABLE IF EXISTS "T_DS_RELATION_SUB_WORKFLOW";
CREATE TABLE "T_DS_RELATION_SUB_WORKFLOW" (
                                              "ID" NUMBER(20) IDENTITY(1,1) NOT NULL,
                                              "PARENT_WORKFLOW_INSTANCE_ID" NUMBER(20) NOT NULL,
                                              "PARENT_TASK_CODE" NUMBER(20) NOT NULL,
                                              "SUB_WORKFLOW_INSTANCE_ID" NUMBER(20) NOT NULL,
                                              PRIMARY KEY ("ID")
);
CREATE INDEX "IDX_PARENT_WORKFLOW_INSTANCE_ID_SUB" ON "T_DS_RELATION_SUB_WORKFLOW"("PARENT_WORKFLOW_INSTANCE_ID");
CREATE INDEX "IDX_PARENT_TASK_CODE" ON "T_DS_RELATION_SUB_WORKFLOW"("PARENT_TASK_CODE");
CREATE INDEX "IDX_SUB_WORKFLOW_INSTANCE_ID" ON "T_DS_RELATION_SUB_WORKFLOW"("SUB_WORKFLOW_INSTANCE_ID");

-- T_DS_WORKFLOW_TASK_LINEAGE
DROP TABLE IF EXISTS "T_DS_WORKFLOW_TASK_LINEAGE";
CREATE TABLE "T_DS_WORKFLOW_TASK_LINEAGE" (
                                              "ID" NUMBER IDENTITY(1,1) NOT NULL,
                                              "WORKFLOW_DEFINITION_CODE" NUMBER(20) NOT NULL DEFAULT 0,
                                              "WORKFLOW_DEFINITION_VERSION" NUMBER(11) NOT NULL DEFAULT 0,
                                              "TASK_DEFINITION_CODE" NUMBER(20) NOT NULL DEFAULT 0,
                                              "TASK_DEFINITION_VERSION" NUMBER(11) NOT NULL DEFAULT 0,
                                              "DEPT_PROJECT_CODE" NUMBER(20) NOT NULL DEFAULT 0,
                                              "DEPT_WORKFLOW_DEFINITION_CODE" NUMBER(20) NOT NULL DEFAULT 0,
                                              "DEPT_TASK_DEFINITION_CODE" NUMBER(20) NOT NULL DEFAULT 0,
                                              "CREATE_TIME" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                              "UPDATE_TIME" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                              PRIMARY KEY ("ID")
);
CREATE INDEX "IDX_WORKFLOW_CODE_VERSION_LINEAGE" ON "T_DS_WORKFLOW_TASK_LINEAGE"("WORKFLOW_DEFINITION_CODE","WORKFLOW_DEFINITION_VERSION");
CREATE INDEX "IDX_TASK_CODE_VERSION_LINEAGE" ON "T_DS_WORKFLOW_TASK_LINEAGE"("TASK_DEFINITION_CODE","TASK_DEFINITION_VERSION");
CREATE INDEX "IDX_DEPT_CODE" ON "T_DS_WORKFLOW_TASK_LINEAGE"("DEPT_PROJECT_CODE","DEPT_WORKFLOW_DEFINITION_CODE","DEPT_TASK_DEFINITION_CODE");

DROP TABLE IF EXISTS "T_DS_JDBC_REGISTRY_DATA";
CREATE TABLE "T_DS_JDBC_REGISTRY_DATA"
(
    "ID" NUMBER(20) IDENTITY(1,1) NOT NULL,
    "DATA_KEY" VARCHAR(256) NOT NULL,
    "DATA_VALUE" CLOB NOT NULL,
    "DATA_TYPE" VARCHAR(64) NOT NULL,
    "CLIENT_ID" NUMBER(20) NOT NULL,
    "CREATE_TIME" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "LAST_UPDATE_TIME" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "UK_T_DS_JDBC_REGISTRY_DATAKEY" ON "T_DS_JDBC_REGISTRY_DATA"("DATA_KEY");

DROP TABLE IF EXISTS "T_DS_JDBC_REGISTRY_LOCK";
CREATE TABLE "T_DS_JDBC_REGISTRY_LOCK"
(
    "ID" NUMBER(20) IDENTITY(1,1) NOT NULL,
    "LOCK_KEY" VARCHAR(256) NOT NULL,
    "LOCK_OWNER" VARCHAR(256) NOT NULL,
    "CLIENT_ID" NUMBER(20) NOT NULL,
    "CREATE_TIME" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("ID")
);
CREATE UNIQUE INDEX "UK_T_DS_JDBC_REGISTRY_LOCKKEY" ON "T_DS_JDBC_REGISTRY_LOCK"("LOCK_KEY");

DROP TABLE IF EXISTS "T_DS_JDBC_REGISTRY_CLIENT_HEARTBEAT";
CREATE TABLE "T_DS_JDBC_REGISTRY_CLIENT_HEARTBEAT"
(
    "ID" NUMBER(20) NOT NULL,
    "CLIENT_NAME" VARCHAR(256) NOT NULL,
    "LAST_HEARTBEAT_TIME" NUMBER(20) NOT NULL,
    "CONNECTION_CONFIG" CLOB NOT NULL,
    "CREATE_TIME" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("ID")
);

DROP TABLE IF EXISTS "T_DS_JDBC_REGISTRY_DATA_CHANGE_EVENT";
CREATE TABLE "T_DS_JDBC_REGISTRY_DATA_CHANGE_EVENT"
(
    "ID" NUMBER(20) IDENTITY(1,1) NOT NULL,
    "EVENT_TYPE" VARCHAR(64) NOT NULL,
    "JDBC_REGISTRY_DATA" CLOB NOT NULL,
    "CREATE_TIME" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("ID")
);

-- ----------------------------
-- 第三部分：插入初始数据（使用 IDENTITY_INSERT 开关）
-- 注意：达梦要求同一时间只能有一个表开启此开关
-- ----------------------------

-- 1. 插入版本信息
SET IDENTITY_INSERT "T_DS_VERSION" ON;
INSERT INTO "T_DS_VERSION" ("ID", "VERSION") VALUES (1, '3.4.1');
SET IDENTITY_INSERT "T_DS_VERSION" OFF;

-- 2. 插入默认租户
SET IDENTITY_INSERT "T_DS_TENANT" ON;
INSERT INTO "T_DS_TENANT" ("ID", "TENANT_CODE", "DESCRIPTION", "QUEUE_ID", "CREATE_TIME", "UPDATE_TIME")
VALUES (-1, 'default', 'default tenant', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
SET IDENTITY_INSERT "T_DS_TENANT" OFF;

-- 3. 插入默认队列
SET IDENTITY_INSERT "T_DS_QUEUE" ON;
INSERT INTO "T_DS_QUEUE" ("ID", "QUEUE_NAME", "QUEUE", "CREATE_TIME", "UPDATE_TIME")
VALUES (1, 'default', 'default', NULL, NULL);
SET IDENTITY_INSERT "T_DS_QUEUE" OFF;

-- 4. 插入默认告警组
SET IDENTITY_INSERT "T_DS_ALERTGROUP" ON;
INSERT INTO "T_DS_ALERTGROUP"("ID", "ALERT_INSTANCE_IDS", "CREATE_USER_ID", "GROUP_NAME", "DESCRIPTION", "CREATE_TIME", "UPDATE_TIME")
VALUES (1, NULL, 1, 'default admin warning group', 'default admin warning group', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
SET IDENTITY_INSERT "T_DS_ALERTGROUP" OFF;

-- 5. 插入默认管理员用户
SET IDENTITY_INSERT "T_DS_USER" ON;
INSERT INTO "T_DS_USER"("ID", "USER_NAME", "USER_PASSWORD", "USER_TYPE", "EMAIL", "PHONE", "TENANT_ID", "CREATE_TIME", "UPDATE_TIME", "STATE")
VALUES (1, 'admin', '7ad2410b2f4c074479a8937a28a22b8f', 0, 'xxx@qq.com', '', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1);
SET IDENTITY_INSERT "T_DS_USER" OFF;