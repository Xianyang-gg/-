/*
 Navicat Premium Data Transfer

 Source Server         : 127.0.0.1
 Source Server Type    : MySQL
 Source Server Version : 80046 (8.0.46)
 Source Host           : localhost:3306
 Source Schema         : srams

 Target Server Type    : MySQL
 Target Server Version : 80046 (8.0.46)
 File Encoding         : 65001

 Date: 03/11/2026 15:26:05
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for gen_table
-- ----------------------------
DROP TABLE IF EXISTS `gen_table`;
CREATE TABLE `gen_table`  (
  `table_id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '表名称',
  `table_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '表描述',
  `sub_table_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联子表的表名',
  `sub_table_fk_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '子表关联的外键名',
  `class_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '实体类名称',
  `tpl_category` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'crud' COMMENT '使用的模板（crud单表操作 tree树表操作）',
  `tpl_web_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '前端模板类型（element-ui模版 element-plus模版）',
  `package_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成包路径',
  `module_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成模块名',
  `business_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成业务名',
  `function_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成功能名',
  `function_author` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成功能作者',
  `form_col_num` int NULL DEFAULT 1 COMMENT '表单布局（单列 双列 三列）',
  `gen_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '生成代码方式（0zip压缩包 1自定义路径）',
  `gen_path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '/' COMMENT '生成路径（不填默认项目路径）',
  `options` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '其它生成选项',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`table_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '代码生成业务表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gen_table
-- ----------------------------

-- ----------------------------
-- Table structure for gen_table_column
-- ----------------------------
DROP TABLE IF EXISTS `gen_table_column`;
CREATE TABLE `gen_table_column`  (
  `column_id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_id` bigint NULL DEFAULT NULL COMMENT '归属表编号',
  `column_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '列名称',
  `column_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '列描述',
  `column_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '列类型',
  `java_type` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'JAVA类型',
  `java_field` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'JAVA字段名',
  `is_pk` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否主键（1是）',
  `is_increment` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否自增（1是）',
  `is_required` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否必填（1是）',
  `is_insert` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否为插入字段（1是）',
  `is_edit` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否编辑字段（1是）',
  `is_list` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否列表字段（1是）',
  `is_query` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否查询字段（1是）',
  `query_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'EQ' COMMENT '查询方式（等于、不等于、大于、小于、范围）',
  `html_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）',
  `dict_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典类型',
  `sort` int NULL DEFAULT NULL COMMENT '排序',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`column_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '代码生成业务表字段' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gen_table_column
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_blob_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_blob_triggers`;
CREATE TABLE `qrtz_blob_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `blob_data` blob NULL COMMENT '存放持久化Trigger对象',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_blob_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Blob类型的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_blob_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_calendars
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_calendars`;
CREATE TABLE `qrtz_calendars`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `calendar_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '日历名称',
  `calendar` blob NOT NULL COMMENT '存放持久化calendar对象',
  PRIMARY KEY (`sched_name`, `calendar_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '日历信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_calendars
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_cron_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_cron_triggers`;
CREATE TABLE `qrtz_cron_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `cron_expression` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'cron表达式',
  `time_zone_id` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '时区',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_cron_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Cron类型的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_cron_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_fired_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_fired_triggers`;
CREATE TABLE `qrtz_fired_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `entry_id` varchar(95) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度器实例id',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `instance_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度器实例名',
  `fired_time` bigint NOT NULL COMMENT '触发的时间',
  `sched_time` bigint NOT NULL COMMENT '定时器制定的时间',
  `priority` int NOT NULL COMMENT '优先级',
  `state` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '任务名称',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '任务组名',
  `is_nonconcurrent` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否并发',
  `requests_recovery` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否接受恢复执行',
  PRIMARY KEY (`sched_name`, `entry_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '已触发的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_fired_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_job_details
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_job_details`;
CREATE TABLE `qrtz_job_details`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务名称',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务组名',
  `description` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '相关介绍',
  `job_class_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '执行任务类名称',
  `is_durable` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '是否持久化',
  `is_nonconcurrent` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '是否并发',
  `is_update_data` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '是否更新数据',
  `requests_recovery` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '是否接受恢复执行',
  `job_data` blob NULL COMMENT '存放持久化job对象',
  PRIMARY KEY (`sched_name`, `job_name`, `job_group`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '任务详细信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_job_details
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_locks
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_locks`;
CREATE TABLE `qrtz_locks`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `lock_name` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '悲观锁名称',
  PRIMARY KEY (`sched_name`, `lock_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '存储的悲观锁信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_locks
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_paused_trigger_grps
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_paused_trigger_grps`;
CREATE TABLE `qrtz_paused_trigger_grps`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  PRIMARY KEY (`sched_name`, `trigger_group`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '暂停的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_paused_trigger_grps
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_scheduler_state
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_scheduler_state`;
CREATE TABLE `qrtz_scheduler_state`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `instance_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '实例名称',
  `last_checkin_time` bigint NOT NULL COMMENT '上次检查时间',
  `checkin_interval` bigint NOT NULL COMMENT '检查间隔时间',
  PRIMARY KEY (`sched_name`, `instance_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '调度器状态表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_scheduler_state
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_simple_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_simple_triggers`;
CREATE TABLE `qrtz_simple_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `repeat_count` bigint NOT NULL COMMENT '重复的次数统计',
  `repeat_interval` bigint NOT NULL COMMENT '重复的间隔时间',
  `times_triggered` bigint NOT NULL COMMENT '已经触发的次数',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_simple_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '简单触发器的信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_simple_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_simprop_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_simprop_triggers`;
CREATE TABLE `qrtz_simprop_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `str_prop_1` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'String类型的trigger的第一个参数',
  `str_prop_2` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'String类型的trigger的第二个参数',
  `str_prop_3` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'String类型的trigger的第三个参数',
  `int_prop_1` int NULL DEFAULT NULL COMMENT 'int类型的trigger的第一个参数',
  `int_prop_2` int NULL DEFAULT NULL COMMENT 'int类型的trigger的第二个参数',
  `long_prop_1` bigint NULL DEFAULT NULL COMMENT 'long类型的trigger的第一个参数',
  `long_prop_2` bigint NULL DEFAULT NULL COMMENT 'long类型的trigger的第二个参数',
  `dec_prop_1` decimal(13, 4) NULL DEFAULT NULL COMMENT 'decimal类型的trigger的第一个参数',
  `dec_prop_2` decimal(13, 4) NULL DEFAULT NULL COMMENT 'decimal类型的trigger的第二个参数',
  `bool_prop_1` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Boolean类型的trigger的第一个参数',
  `bool_prop_2` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Boolean类型的trigger的第二个参数',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_simprop_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '同步机制的行锁表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_simprop_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_triggers`;
CREATE TABLE `qrtz_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发器的名字',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发器所属组的名字',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_job_details表job_name的外键',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_job_details表job_group的外键',
  `description` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '相关介绍',
  `next_fire_time` bigint NULL DEFAULT NULL COMMENT '上一次触发时间（毫秒）',
  `prev_fire_time` bigint NULL DEFAULT NULL COMMENT '下一次触发时间（默认为-1表示不触发）',
  `priority` int NULL DEFAULT NULL COMMENT '优先级',
  `trigger_state` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发器状态',
  `trigger_type` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发器的类型',
  `start_time` bigint NOT NULL COMMENT '开始时间',
  `end_time` bigint NULL DEFAULT NULL COMMENT '结束时间',
  `calendar_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '日程表名称',
  `misfire_instr` smallint NULL DEFAULT NULL COMMENT '补偿执行的策略',
  `job_data` blob NULL COMMENT '存放持久化job对象',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  INDEX `sched_name`(`sched_name` ASC, `job_name` ASC, `job_group` ASC) USING BTREE,
  CONSTRAINT `qrtz_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `job_name`, `job_group`) REFERENCES `qrtz_job_details` (`sched_name`, `job_name`, `job_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '触发器详细信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config`  (
  `config_id` int NOT NULL AUTO_INCREMENT COMMENT '参数主键',
  `config_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '参数名称',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '参数键名',
  `config_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '参数键值',
  `config_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'N' COMMENT '系统内置（Y是 N否）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '参数配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO `sys_config` VALUES (1, '主框架页-默认皮肤样式名称', 'sys.index.skinName', 'skin-blue', 'Y', 'admin', '2026-10-30 17:40:39', '', NULL, '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow');
INSERT INTO `sys_config` VALUES (2, '用户管理-账号初始密码', 'sys.user.initPassword', '123456', 'Y', 'admin', '2026-10-30 17:40:39', '', NULL, '初始化密码 123456');
INSERT INTO `sys_config` VALUES (3, '主框架页-侧边栏主题', 'sys.index.sideTheme', 'theme-dark', 'Y', 'admin', '2026-10-30 17:40:39', '', NULL, '深色主题theme-dark，浅色主题theme-light');
INSERT INTO `sys_config` VALUES (4, '账号自助-验证码开关', 'sys.account.captchaEnabled', 'true', 'Y', 'admin', '2026-10-30 17:40:39', '', NULL, '是否开启验证码功能（true开启，false关闭）');
INSERT INTO `sys_config` VALUES (5, '账号自助-是否开启用户注册功能', 'sys.account.registerUser', 'false', 'Y', 'admin', '2026-10-30 17:40:39', '', NULL, '是否开启注册用户功能（true开启，false关闭）');
INSERT INTO `sys_config` VALUES (6, '用户登录-黑名单列表', 'sys.login.blackIPList', '', 'Y', 'admin', '2026-10-30 17:40:39', '', NULL, '设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）');
INSERT INTO `sys_config` VALUES (7, '用户管理-初始密码修改策略', 'sys.account.initPasswordModify', '1', 'Y', 'admin', '2026-10-30 17:40:39', '', NULL, '0：初始密码修改策略关闭，没有任何提示，1：提醒用户，如果未修改初始密码，则在登录时就会提醒修改密码对话框');
INSERT INTO `sys_config` VALUES (8, '用户管理-账号密码更新周期', 'sys.account.passwordValidateDays', '0', 'Y', 'admin', '2026-10-30 17:40:39', '', NULL, '密码更新周期（填写数字，数据初始化值为0不限制，若修改必须为大于0小于365的正整数），如果超过这个周期登录系统时，则在登录时就会提醒修改密码对话框');
INSERT INTO `sys_config` VALUES (9, '用户管理-密码字符范围', 'sys.account.chrtype', '0', 'Y', 'admin', '2026-10-30 17:40:39', '', NULL, '默认任意字符范围，0任意（密码可以输入任意字符），1数字（密码只能为0-9数字），2英文字母（密码只能为a-z和A-Z字母），3字母和数字（密码必须包含字母，数字）,4字母数字和特殊字符（目前支持的特殊字符包括：~!@#$%^&*()-=_+）');

-- ----------------------------
-- Table structure for sys_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE `sys_dept`  (
  `dept_id` bigint NOT NULL AUTO_INCREMENT COMMENT '部门id',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父部门id',
  `ancestors` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '祖级列表',
  `dept_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '部门名称',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `leader` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '负责人',
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '部门状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`dept_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 224 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '部门表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dept
-- ----------------------------
INSERT INTO `sys_dept` VALUES (100, 0, '0', '超级管理', 0, 'admin', '15888888888', 'ry@163.com', '0', '0', 'admin', '2026-10-30 17:41:01', '', NULL);
INSERT INTO `sys_dept` VALUES (200, 100, '0,100', '信息工程学院', 0, '张三', NULL, NULL, '0', '2', 'admin', '2026-10-30 21:19:18', '', NULL);
INSERT INTO `sys_dept` VALUES (201, 100, '0,100', '中山职业技术学院', 0, NULL, NULL, NULL, '0', '0', 'admin', '2026-10-30 21:20:02', 'admin', '2026-11-03 15:07:07');
INSERT INTO `sys_dept` VALUES (202, 201, '0,100,201', '信息工程学院', 0, NULL, NULL, NULL, '0', '0', 'admin', '2026-10-30 21:20:11', 'admin', '2026-10-30 21:21:20');
INSERT INTO `sys_dept` VALUES (203, 202, '0,100,201,202', '软件教研室', 0, NULL, NULL, NULL, '0', '2', 'admin', '2026-10-30 21:21:49', 'admin', '2026-11-02 14:51:50');
INSERT INTO `sys_dept` VALUES (204, 202, '0,100,201,202', '软件开发技术', 0, NULL, NULL, NULL, '0', '2', 'admin', '2026-10-30 21:22:33', '', NULL);
INSERT INTO `sys_dept` VALUES (205, 202, '0,100,201,202', '信息工程党委院长', 0, NULL, NULL, NULL, '0', '0', 'admin', '2026-11-03 14:37:21', 'admin', '2026-11-03 15:08:28');
INSERT INTO `sys_dept` VALUES (206, 202, '0,100,201,202', '信息工程学院办公室', 10, NULL, NULL, NULL, '0', '0', 'admin', '2026-11-03 15:02:11', 'admin', '2026-11-03 15:08:18');
INSERT INTO `sys_dept` VALUES (207, 202, '0,100,201,202', '信息工程学生工作办公室', 20, NULL, NULL, NULL, '0', '0', 'admin', '2026-11-03 15:02:40', 'admin', '2026-11-03 15:11:00');
INSERT INTO `sys_dept` VALUES (208, 202, '0,100,201,202', '电子信息工程技术教研室', 30, NULL, NULL, NULL, '0', '0', 'admin', '2026-11-03 15:03:24', '', NULL);
INSERT INTO `sys_dept` VALUES (209, 202, '0,100,201,202', '物联网应用技术教研室', 40, NULL, NULL, NULL, '0', '0', 'admin', '2026-11-03 15:03:53', '', NULL);
INSERT INTO `sys_dept` VALUES (210, 202, '0,100,201,202', '软件技术专业教研室', 50, NULL, NULL, NULL, '0', '0', 'admin', '2026-11-03 15:04:19', '', NULL);
INSERT INTO `sys_dept` VALUES (211, 202, '0,100,201,202', '信息安全应用技术教研室', 60, NULL, NULL, NULL, '0', '0', 'admin', '2026-11-03 15:04:45', '', NULL);
INSERT INTO `sys_dept` VALUES (212, 202, '0,100,201,202', '应用化学教研室', 70, NULL, NULL, NULL, '0', '0', 'admin', '2026-11-03 15:05:20', '', NULL);
INSERT INTO `sys_dept` VALUES (213, 202, '0,100,201,202', '人工智能技术应用服务教研室', 80, NULL, NULL, NULL, '0', '0', 'admin', '2026-11-03 15:06:22', 'admin', '2026-11-03 15:16:37');
INSERT INTO `sys_dept` VALUES (214, 201, '0,100,201', '艺术设计学院', 10, NULL, NULL, NULL, '0', '0', 'admin', '2026-11-03 15:07:55', '', NULL);
INSERT INTO `sys_dept` VALUES (215, 214, '0,100,201,214', '艺术设计学院办公室', 10, NULL, NULL, NULL, '0', '0', 'admin', '2026-11-03 15:09:43', '', NULL);
INSERT INTO `sys_dept` VALUES (216, 214, '0,100,201,214', '艺术设计党委院长', 0, NULL, NULL, NULL, '0', '0', 'admin', '2026-11-03 15:10:14', '', NULL);
INSERT INTO `sys_dept` VALUES (217, 214, '0,100,201,214', '艺术设计学生工作办公室', 20, NULL, NULL, NULL, '0', '0', 'admin', '2026-11-03 15:10:47', '', NULL);
INSERT INTO `sys_dept` VALUES (218, 214, '0,100,201,214', '沙溪纺织服装学院', 30, NULL, NULL, NULL, '0', '0', 'admin', '2026-11-03 15:12:01', '', NULL);
INSERT INTO `sys_dept` VALUES (219, 214, '0,100,201,214', '红木家居学院', 40, NULL, NULL, NULL, '0', '0', 'admin', '2026-11-03 15:12:38', 'admin', '2026-11-03 15:12:46');
INSERT INTO `sys_dept` VALUES (220, 214, '0,100,201,214', '产品艺术设计教研室', 50, NULL, NULL, NULL, '0', '0', 'admin', '2026-11-03 15:13:58', '', NULL);
INSERT INTO `sys_dept` VALUES (221, 214, '0,100,201,214', '动漫制作技术教研室', 60, NULL, NULL, NULL, '0', '0', 'admin', '2026-11-03 15:14:53', '', NULL);
INSERT INTO `sys_dept` VALUES (222, 214, '0,100,201,214', '环境艺术设计教研室', 70, NULL, NULL, NULL, '0', '0', 'admin', '2026-11-03 15:15:20', '', NULL);
INSERT INTO `sys_dept` VALUES (223, 214, '0,100,201,214', '数字媒体艺术设计教研室', 80, NULL, NULL, NULL, '0', '0', 'admin', '2026-11-03 15:16:10', 'admin', '2026-11-03 15:16:21');

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data`  (
  `dict_code` bigint NOT NULL AUTO_INCREMENT COMMENT '字典编码',
  `dict_sort` int NULL DEFAULT 0 COMMENT '字典排序',
  `dict_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典标签',
  `dict_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典键值',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典类型',
  `css_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '表格回显样式',
  `is_default` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '字典数据表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_data
-- ----------------------------
INSERT INTO `sys_dict_data` VALUES (1, 1, '男', '0', 'sys_user_sex', '', '', 'Y', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '性别男');
INSERT INTO `sys_dict_data` VALUES (2, 2, '女', '1', 'sys_user_sex', '', '', 'N', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '性别女');
INSERT INTO `sys_dict_data` VALUES (3, 3, '未知', '2', 'sys_user_sex', '', '', 'N', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '性别未知');
INSERT INTO `sys_dict_data` VALUES (4, 1, '显示', '0', 'sys_show_hide', '', 'primary', 'Y', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '显示菜单');
INSERT INTO `sys_dict_data` VALUES (5, 2, '隐藏', '1', 'sys_show_hide', '', 'danger', 'N', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '隐藏菜单');
INSERT INTO `sys_dict_data` VALUES (6, 1, '正常', '0', 'sys_normal_disable', '', 'primary', 'Y', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (7, 2, '停用', '1', 'sys_normal_disable', '', 'danger', 'N', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (8, 1, '正常', '0', 'sys_job_status', '', 'primary', 'Y', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (9, 2, '暂停', '1', 'sys_job_status', '', 'danger', 'N', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (10, 1, '默认', 'DEFAULT', 'sys_job_group', '', '', 'Y', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '默认分组');
INSERT INTO `sys_dict_data` VALUES (11, 2, '系统', 'SYSTEM', 'sys_job_group', '', '', 'N', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '系统分组');
INSERT INTO `sys_dict_data` VALUES (12, 1, '是', 'Y', 'sys_yes_no', '', 'primary', 'Y', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '系统默认是');
INSERT INTO `sys_dict_data` VALUES (13, 2, '否', 'N', 'sys_yes_no', '', 'danger', 'N', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '系统默认否');
INSERT INTO `sys_dict_data` VALUES (14, 1, '通知', '1', 'sys_notice_type', '', 'warning', 'Y', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '通知');
INSERT INTO `sys_dict_data` VALUES (15, 2, '公告', '2', 'sys_notice_type', '', 'success', 'N', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '公告');
INSERT INTO `sys_dict_data` VALUES (16, 1, '正常', '0', 'sys_notice_status', '', 'primary', 'Y', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (17, 2, '关闭', '1', 'sys_notice_status', '', 'danger', 'N', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '关闭状态');
INSERT INTO `sys_dict_data` VALUES (18, 99, '其他', '0', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '其他操作');
INSERT INTO `sys_dict_data` VALUES (19, 1, '新增', '1', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '新增操作');
INSERT INTO `sys_dict_data` VALUES (20, 2, '修改', '2', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '修改操作');
INSERT INTO `sys_dict_data` VALUES (21, 3, '删除', '3', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '删除操作');
INSERT INTO `sys_dict_data` VALUES (22, 4, '授权', '4', 'sys_oper_type', '', 'primary', 'N', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '授权操作');
INSERT INTO `sys_dict_data` VALUES (23, 5, '导出', '5', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '导出操作');
INSERT INTO `sys_dict_data` VALUES (24, 6, '导入', '6', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '导入操作');
INSERT INTO `sys_dict_data` VALUES (25, 7, '强退', '7', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '强退操作');
INSERT INTO `sys_dict_data` VALUES (26, 8, '生成代码', '8', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '生成操作');
INSERT INTO `sys_dict_data` VALUES (27, 9, '清空数据', '9', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '清空操作');
INSERT INTO `sys_dict_data` VALUES (28, 1, '成功', '0', 'sys_common_status', '', 'primary', 'N', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (29, 2, '失败', '1', 'sys_common_status', '', 'danger', 'N', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '停用状态');

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type`  (
  `dict_id` bigint NOT NULL AUTO_INCREMENT COMMENT '字典主键',
  `dict_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典名称',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典类型',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_id`) USING BTREE,
  UNIQUE INDEX `dict_type`(`dict_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '字典类型表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_type
-- ----------------------------
INSERT INTO `sys_dict_type` VALUES (1, '用户性别', 'sys_user_sex', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '用户性别列表');
INSERT INTO `sys_dict_type` VALUES (2, '菜单状态', 'sys_show_hide', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '菜单状态列表');
INSERT INTO `sys_dict_type` VALUES (3, '系统开关', 'sys_normal_disable', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '系统开关列表');
INSERT INTO `sys_dict_type` VALUES (4, '任务状态', 'sys_job_status', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '任务状态列表');
INSERT INTO `sys_dict_type` VALUES (5, '任务分组', 'sys_job_group', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '任务分组列表');
INSERT INTO `sys_dict_type` VALUES (6, '系统是否', 'sys_yes_no', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '系统是否列表');
INSERT INTO `sys_dict_type` VALUES (7, '通知类型', 'sys_notice_type', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '通知类型列表');
INSERT INTO `sys_dict_type` VALUES (8, '通知状态', 'sys_notice_status', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '通知状态列表');
INSERT INTO `sys_dict_type` VALUES (9, '操作类型', 'sys_oper_type', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '操作类型列表');
INSERT INTO `sys_dict_type` VALUES (10, '系统状态', 'sys_common_status', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '登录状态列表');

-- ----------------------------
-- Table structure for sys_job
-- ----------------------------
DROP TABLE IF EXISTS `sys_job`;
CREATE TABLE `sys_job`  (
  `job_id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `job_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '任务名称',
  `job_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'DEFAULT' COMMENT '任务组名',
  `invoke_target` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调用目标字符串',
  `cron_expression` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'cron执行表达式',
  `misfire_policy` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '3' COMMENT '计划执行错误策略（1立即执行 2执行一次 3放弃执行）',
  `concurrent` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '是否并发执行（0允许 1禁止）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1暂停）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注信息',
  PRIMARY KEY (`job_id`, `job_name`, `job_group`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '定时任务调度表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_job
-- ----------------------------
INSERT INTO `sys_job` VALUES (1, '系统默认（无参）', 'DEFAULT', 'ryTask.ryNoParams', '0/10 * * * * ?', '3', '1', '1', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_job` VALUES (2, '系统默认（有参）', 'DEFAULT', 'ryTask.ryParams(\'ry\')', '0/15 * * * * ?', '3', '1', '1', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_job` VALUES (3, '系统默认（多参）', 'DEFAULT', 'ryTask.ryMultipleParams(\'ry\', true, 2000L, 316.50D, 100)', '0/20 * * * * ?', '3', '1', '1', 'admin', '2026-10-30 17:40:39', '', NULL, '');

-- ----------------------------
-- Table structure for sys_job_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_job_log`;
CREATE TABLE `sys_job_log`  (
  `job_log_id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务日志ID',
  `job_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务名称',
  `job_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务组名',
  `invoke_target` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调用目标字符串',
  `job_message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '日志信息',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '执行状态（0正常 1失败）',
  `exception_info` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '异常信息',
  `start_time` datetime NULL DEFAULT NULL COMMENT '执行开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '执行结束时间',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`job_log_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '定时任务调度日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_job_log
-- ----------------------------

-- ----------------------------
-- Table structure for sys_logininfor
-- ----------------------------
DROP TABLE IF EXISTS `sys_logininfor`;
CREATE TABLE `sys_logininfor`  (
  `info_id` bigint NOT NULL AUTO_INCREMENT COMMENT '访问ID',
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '用户账号',
  `ipaddr` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '登录IP地址',
  `login_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '登录地点',
  `browser` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '浏览器类型',
  `os` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作系统',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '登录状态（0成功 1失败）',
  `msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '提示消息',
  `login_time` datetime NULL DEFAULT NULL COMMENT '访问时间',
  PRIMARY KEY (`info_id`) USING BTREE,
  INDEX `idx_sys_logininfor_s`(`status` ASC) USING BTREE,
  INDEX `idx_sys_logininfor_lt`(`login_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 201 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统访问记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_logininfor
-- ----------------------------

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `menu_id` bigint NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '菜单名称',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父菜单ID',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '组件路径',
  `query` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '路由参数',
  `route_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '路由名称',
  `is_frame` int NULL DEFAULT 1 COMMENT '是否为外链（0是 1否）',
  `is_cache` int NULL DEFAULT 0 COMMENT '是否缓存（0缓存 1不缓存）',
  `menu_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `visible` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '菜单状态（0显示 1隐藏）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '菜单状态（0正常 1停用）',
  `perms` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '权限标识',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '#' COMMENT '菜单图标',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2028 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜单权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, '系统管理', 0, 1, 'system', NULL, '', '', 1, 0, 'M', '0', '0', '', 'system', 'admin', '2026-10-30 17:40:39', '', NULL, '系统管理目录');
INSERT INTO `sys_menu` VALUES (2, '系统监控', 0, 2, 'monitor', NULL, '', '', 1, 0, 'M', '0', '0', '', 'monitor', 'admin', '2026-10-30 17:40:39', '', NULL, '系统监控目录');
INSERT INTO `sys_menu` VALUES (3, '系统工具', 0, 3, 'tool', NULL, '', '', 1, 0, 'M', '0', '0', '', 'tool', 'admin', '2026-10-30 17:40:39', '', NULL, '系统工具目录');
INSERT INTO `sys_menu` VALUES (100, '用户管理', 1, 1, 'user', 'system/user/index', '', '', 1, 0, 'C', '0', '0', 'system:user:list', 'user', 'admin', '2026-10-30 17:40:39', '', NULL, '用户管理菜单');
INSERT INTO `sys_menu` VALUES (101, '角色管理', 1, 2, 'role', 'system/role/index', '', '', 1, 0, 'C', '0', '0', 'system:role:list', 'peoples', 'admin', '2026-10-30 17:40:39', '', NULL, '角色管理菜单');
INSERT INTO `sys_menu` VALUES (102, '菜单管理', 1, 3, 'menu', 'system/menu/index', '', '', 1, 0, 'C', '0', '0', 'system:menu:list', 'tree-table', 'admin', '2026-10-30 17:40:39', '', NULL, '菜单管理菜单');
INSERT INTO `sys_menu` VALUES (103, '部门管理', 1, 4, 'dept', 'system/dept/index', '', '', 1, 0, 'C', '0', '0', 'system:dept:list', 'tree', 'admin', '2026-10-30 17:40:39', '', NULL, '部门管理菜单');
INSERT INTO `sys_menu` VALUES (104, '岗位管理', 1, 5, 'post', 'system/post/index', '', '', 1, 0, 'C', '0', '0', 'system:post:list', 'post', 'admin', '2026-10-30 17:40:39', '', NULL, '岗位管理菜单');
INSERT INTO `sys_menu` VALUES (105, '字典管理', 1, 6, 'dict', 'system/dict/index', '', '', 1, 0, 'C', '0', '0', 'system:dict:list', 'dict', 'admin', '2026-10-30 17:40:39', '', NULL, '字典管理菜单');
INSERT INTO `sys_menu` VALUES (106, '参数设置', 1, 7, 'config', 'system/config/index', '', '', 1, 0, 'C', '0', '0', 'system:config:list', 'edit', 'admin', '2026-10-30 17:40:39', '', NULL, '参数设置菜单');
INSERT INTO `sys_menu` VALUES (107, '通知公告', 1, 8, 'notice', 'system/notice/index', '', '', 1, 0, 'C', '0', '0', 'system:notice:list', 'message', 'admin', '2026-10-30 17:40:39', '', NULL, '通知公告菜单');
INSERT INTO `sys_menu` VALUES (108, '日志管理', 1, 9, 'log', '', '', '', 1, 0, 'M', '0', '0', '', 'log', 'admin', '2026-10-30 17:40:39', '', NULL, '日志管理菜单');
INSERT INTO `sys_menu` VALUES (109, '在线用户', 2, 1, 'online', 'monitor/online/index', '', '', 1, 0, 'C', '0', '0', 'monitor:online:list', 'online', 'admin', '2026-10-30 17:40:39', '', NULL, '在线用户菜单');
INSERT INTO `sys_menu` VALUES (110, '定时任务', 2, 2, 'job', 'monitor/job/index', '', '', 1, 0, 'C', '0', '0', 'monitor:job:list', 'job', 'admin', '2026-10-30 17:40:39', '', NULL, '定时任务菜单');
INSERT INTO `sys_menu` VALUES (111, '数据监控', 2, 3, 'druid', 'monitor/druid/index', '', '', 1, 0, 'C', '0', '0', 'monitor:druid:list', 'druid', 'admin', '2026-10-30 17:40:39', '', NULL, '数据监控菜单');
INSERT INTO `sys_menu` VALUES (112, '服务监控', 2, 4, 'server', 'monitor/server/index', '', '', 1, 0, 'C', '0', '0', 'monitor:server:list', 'server', 'admin', '2026-10-30 17:40:39', '', NULL, '服务监控菜单');
INSERT INTO `sys_menu` VALUES (113, '缓存监控', 2, 5, 'cache', 'monitor/cache/index', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis', 'admin', '2026-10-30 17:40:39', '', NULL, '缓存监控菜单');
INSERT INTO `sys_menu` VALUES (114, '缓存列表', 2, 6, 'cacheList', 'monitor/cache/list', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis-list', 'admin', '2026-10-30 17:40:39', '', NULL, '缓存列表菜单');
INSERT INTO `sys_menu` VALUES (116, '代码生成', 3, 2, 'gen', 'tool/gen/index', '', '', 1, 0, 'C', '0', '0', 'tool:gen:list', 'code', 'admin', '2026-10-30 17:40:39', '', NULL, '代码生成菜单');
INSERT INTO `sys_menu` VALUES (500, '操作日志', 108, 1, 'operlog', 'monitor/operlog/index', '', '', 1, 0, 'C', '0', '0', 'monitor:operlog:list', 'form', 'admin', '2026-10-30 17:40:39', '', NULL, '操作日志菜单');
INSERT INTO `sys_menu` VALUES (501, '登录日志', 108, 2, 'logininfor', 'monitor/logininfor/index', '', '', 1, 0, 'C', '0', '0', 'monitor:logininfor:list', 'logininfor', 'admin', '2026-10-30 17:40:39', '', NULL, '登录日志菜单');
INSERT INTO `sys_menu` VALUES (1000, '用户查询', 100, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:query', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1001, '用户新增', 100, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:add', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1002, '用户修改', 100, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:edit', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1003, '用户删除', 100, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:remove', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1004, '用户导出', 100, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:export', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1005, '用户导入', 100, 6, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:import', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1006, '重置密码', 100, 7, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:resetPwd', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1007, '角色查询', 101, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:query', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1008, '角色新增', 101, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:add', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1009, '角色修改', 101, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:edit', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1010, '角色删除', 101, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:remove', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1011, '角色导出', 101, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:export', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1012, '菜单查询', 102, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:query', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1013, '菜单新增', 102, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:add', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1014, '菜单修改', 102, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:edit', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1015, '菜单删除', 102, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:remove', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1016, '部门查询', 103, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:query', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1017, '部门新增', 103, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:add', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1018, '部门修改', 103, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:edit', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1019, '部门删除', 103, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:remove', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1020, '岗位查询', 104, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:query', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1021, '岗位新增', 104, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:add', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1022, '岗位修改', 104, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:edit', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1023, '岗位删除', 104, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:remove', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1024, '岗位导出', 104, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:export', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1025, '字典查询', 105, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:query', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1026, '字典新增', 105, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:add', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1027, '字典修改', 105, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:edit', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1028, '字典删除', 105, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:remove', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1029, '字典导出', 105, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:export', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1030, '参数查询', 106, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:query', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1031, '参数新增', 106, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:add', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1032, '参数修改', 106, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:edit', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1033, '参数删除', 106, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:remove', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1034, '参数导出', 106, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:export', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1035, '公告查询', 107, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:query', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1036, '公告新增', 107, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:add', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1037, '公告修改', 107, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:edit', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1038, '公告删除', 107, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:remove', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1039, '操作查询', 500, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:query', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1040, '操作删除', 500, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:remove', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1041, '日志导出', 500, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:export', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1042, '登录查询', 501, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:query', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1043, '登录删除', 501, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:remove', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1044, '日志导出', 501, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:export', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1045, '账户解锁', 501, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:unlock', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1046, '在线查询', 109, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:query', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1047, '批量强退', 109, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:batchLogout', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1048, '单条强退', 109, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:forceLogout', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1049, '任务查询', 110, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:query', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1050, '任务新增', 110, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:add', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1051, '任务修改', 110, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:edit', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1052, '任务删除', 110, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:remove', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1053, '状态修改', 110, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:changeStatus', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1054, '任务导出', 110, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:export', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1055, '生成查询', 116, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:query', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1056, '生成修改', 116, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:edit', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1057, '生成删除', 116, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:remove', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1058, '导入代码', 116, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:import', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1059, '预览代码', 116, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:preview', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1060, '生成代码', 116, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:code', '#', 'admin', '2026-10-30 17:40:39', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2000, '业绩成果', 0, 0, 'achievement', 'Layout', NULL, '', 1, 1, 'M', '1', '1', '', 'documentation', 'admin', '2026-10-30 19:38:43', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2001, '成果库', 2000, 1, 'index', 'srams/index', NULL, 'AchievementIndex', 1, 1, 'C', '1', '1', 'achievement:list', 'documentation', 'admin', '2026-10-30 19:38:43', 'admin', '2026-10-30 20:06:48', '');
INSERT INTO `sys_menu` VALUES (2002, '项目', 0, -6, 'srams-project', 'Layout', NULL, 'SramsProject', 1, 1, 'M', '0', '0', '', 'documentation', 'admin', '2026-10-30 20:39:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2003, '获奖', 0, -5, 'srams-award', 'Layout', NULL, 'SramsAward', 1, 1, 'M', '0', '0', '', 'star', 'admin', '2026-10-30 20:39:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2004, '教材和课程', 0, -4, 'srams-teaching', 'Layout', NULL, 'SramsTeaching', 1, 1, 'M', '0', '0', '', 'education', 'admin', '2026-10-30 20:39:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2005, '论文和专利', 0, -3, 'srams-research', 'Layout', NULL, 'SramsResearch', 1, 1, 'M', '0', '0', '', 'documentation', 'admin', '2026-10-30 20:39:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2006, '交流合作', 0, -2, 'srams-cooperation', 'Layout', NULL, 'SramsCooperation', 1, 1, 'M', '0', '0', '', 'peoples', 'admin', '2026-10-30 20:39:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2007, '媒体报道', 0, -1, 'srams-media', 'Layout', NULL, 'SramsMedia', 1, 1, 'M', '0', '0', '', 'message', 'admin', '2026-10-30 20:39:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2009, '指导学生项目', 2002, 4, 'student', 'srams/project/student', NULL, 'SramsProjectStudent', 1, 1, 'C', '0', '0', 'achievement:list', 'documentation', 'admin', '2026-10-30 20:39:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2010, '横向项目', 2002, 3, 'horizontal', 'srams/project/horizontal', NULL, 'SramsProjectHorizontal', 1, 1, 'C', '0', '0', 'achievement:list', 'documentation', 'admin', '2026-10-30 20:39:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2011, '教科研项目', 2002, 2, 'research', 'srams/project/research', NULL, 'SramsProjectResearch', 1, 1, 'C', '0', '0', 'achievement:list', 'documentation', 'admin', '2026-10-30 20:39:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2012, '按专业申报的项目', 2002, 1, 'major', 'srams/project/major', NULL, 'SramsProjectMajor', 1, 1, 'C', '0', '0', 'achievement:list', 'documentation', 'admin', '2026-10-30 20:39:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2013, '指导学生获奖', 2003, 2, 'student', 'srams/award/student', NULL, 'SramsAwardStudent', 1, 1, 'C', '0', '0', 'achievement:list', 'documentation', 'admin', '2026-10-30 20:39:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2014, '教师获奖及荣誉称号', 2003, 1, 'teacher', 'srams/award/teacher', NULL, 'SramsAwardTeacher', 1, 1, 'C', '0', '0', 'achievement:list', 'documentation', 'admin', '2026-10-30 20:39:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2015, '教材', 2004, 2, 'textbook', 'srams/teaching/textbook', NULL, 'SramsTextbook', 1, 1, 'C', '0', '0', 'achievement:list', 'documentation', 'admin', '2026-10-30 20:39:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2016, '课程', 2004, 1, 'course', 'srams/teaching/course', NULL, 'SramsCourse', 1, 1, 'C', '0', '0', 'achievement:list', 'documentation', 'admin', '2026-10-30 20:39:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2017, '专利转让', 2005, 3, 'transfer', 'srams/research/transfer', NULL, 'SramsPatentTransfer', 1, 1, 'C', '0', '0', 'achievement:list', 'documentation', 'admin', '2026-10-30 20:39:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2018, '专利及软件著作权', 2005, 2, 'patent', 'srams/research/patent', NULL, 'SramsPatent', 1, 1, 'C', '0', '0', 'achievement:list', 'documentation', 'admin', '2026-10-30 20:39:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2019, '论文', 2005, 1, 'paper', 'srams/research/paper', NULL, 'SramsPaper', 1, 1, 'C', '0', '0', 'achievement:list', 'documentation', 'admin', '2026-10-30 20:39:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2020, '参加培训进修', 2006, 3, 'study', 'srams/cooperation/study', NULL, 'SramsStudyTraining', 1, 1, 'C', '0', '0', 'achievement:list', 'documentation', 'admin', '2026-10-30 20:39:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2021, '举办技术交流和公开培训', 2006, 2, 'hosted', 'srams/cooperation/hosted', NULL, 'SramsHostedTraining', 1, 1, 'C', '0', '0', 'achievement:list', 'documentation', 'admin', '2026-10-30 20:39:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2022, '接待参观与企业洽谈', 2006, 1, 'visit', 'srams/cooperation/visit', NULL, 'SramsVisit', 1, 1, 'C', '0', '0', 'achievement:list', 'documentation', 'admin', '2026-10-30 20:39:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2023, '媒体报道管理', 2007, 1, 'report', 'srams/media/report', NULL, 'SramsMediaReport', 1, 1, 'C', '0', '0', 'achievement:list', 'documentation', 'admin', '2026-10-30 20:39:23', '', NULL, '');

-- ----------------------------
-- Table structure for sys_notice
-- ----------------------------
DROP TABLE IF EXISTS `sys_notice`;
CREATE TABLE `sys_notice`  (
  `notice_id` int NOT NULL AUTO_INCREMENT COMMENT '公告ID',
  `notice_title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公告标题',
  `notice_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公告类型（1通知 2公告）',
  `notice_content` longblob NULL COMMENT '公告内容',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '公告状态（0正常 1关闭）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`notice_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '通知公告表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_notice
-- ----------------------------

-- ----------------------------
-- Table structure for sys_notice_read
-- ----------------------------
DROP TABLE IF EXISTS `sys_notice_read`;
CREATE TABLE `sys_notice_read`  (
  `read_id` bigint NOT NULL AUTO_INCREMENT COMMENT '已读主键',
  `notice_id` int NOT NULL COMMENT '公告id',
  `user_id` bigint NOT NULL COMMENT '用户id',
  `read_time` datetime NOT NULL COMMENT '阅读时间',
  PRIMARY KEY (`read_id`) USING BTREE,
  UNIQUE INDEX `uk_user_notice`(`user_id` ASC, `notice_id` ASC) USING BTREE COMMENT '同一用户同一公告只记录一次'
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '公告已读记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_notice_read
-- ----------------------------

-- ----------------------------
-- Table structure for sys_oper_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE `sys_oper_log`  (
  `oper_id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志主键',
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '模块标题',
  `business_type` int NULL DEFAULT 0 COMMENT '业务类型（0其它 1新增 2修改 3删除）',
  `method` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '方法名称',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求方式',
  `operator_type` int NULL DEFAULT 0 COMMENT '操作类别（0其它 1后台用户 2手机端用户）',
  `oper_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作人员',
  `dept_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '部门名称',
  `oper_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求URL',
  `oper_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '主机地址',
  `oper_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作地点',
  `oper_param` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求参数',
  `json_result` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '返回参数',
  `status` int NULL DEFAULT 0 COMMENT '操作状态（0正常 1异常）',
  `error_msg` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '错误消息',
  `oper_time` datetime NULL DEFAULT NULL COMMENT '操作时间',
  `cost_time` bigint NULL DEFAULT 0 COMMENT '消耗时间',
  PRIMARY KEY (`oper_id`) USING BTREE,
  INDEX `idx_sys_oper_log_bt`(`business_type` ASC) USING BTREE,
  INDEX `idx_sys_oper_log_s`(`status` ASC) USING BTREE,
  INDEX `idx_sys_oper_log_ot`(`oper_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 31 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '操作日志记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_oper_log
-- ----------------------------
INSERT INTO `sys_oper_log` VALUES (1, '操作日志', 9, 'com.sensitive.web.controller.monitor.SysOperlogController.clean()', 'DELETE', 1, 'admin', '超级管理', '/monitor/operlog/clean', '127.0.0.1', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:00:35', 35);
INSERT INTO `sys_oper_log` VALUES (2, '登录日志', 9, 'com.sensitive.web.controller.monitor.SysLogininforController.clean()', 'DELETE', 1, 'admin', '超级管理', '/monitor/logininfor/clean', '127.0.0.1', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:00:38', 31);
INSERT INTO `sys_oper_log` VALUES (3, '部门管理', 3, 'com.sensitive.web.controller.system.SysDeptController.remove()', 'DELETE', 1, 'admin', '超级管理', '/system/dept/203', '127.0.0.1', '内网IP', '203 ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:01:35', 11);
INSERT INTO `sys_oper_log` VALUES (4, '部门管理', 1, 'com.sensitive.web.controller.system.SysDeptController.add()', 'POST', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,202\",\"children\":[],\"createBy\":\"admin\",\"deptName\":\"学院办公室\",\"orderNum\":10,\"params\":{},\"parentId\":202,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:02:11', 10);
INSERT INTO `sys_oper_log` VALUES (5, '部门管理', 1, 'com.sensitive.web.controller.system.SysDeptController.add()', 'POST', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,202\",\"children\":[],\"createBy\":\"admin\",\"deptName\":\"学生工作办公室\",\"orderNum\":20,\"params\":{},\"parentId\":202,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:02:40', 10);
INSERT INTO `sys_oper_log` VALUES (6, '部门管理', 1, 'com.sensitive.web.controller.system.SysDeptController.add()', 'POST', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,202\",\"children\":[],\"createBy\":\"admin\",\"deptName\":\"电子信息工程技术教研室\",\"orderNum\":30,\"params\":{},\"parentId\":202,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:03:24', 9);
INSERT INTO `sys_oper_log` VALUES (7, '部门管理', 1, 'com.sensitive.web.controller.system.SysDeptController.add()', 'POST', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,202\",\"children\":[],\"createBy\":\"admin\",\"deptName\":\"物联网应用技术教研室\",\"orderNum\":40,\"params\":{},\"parentId\":202,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:03:53', 9);
INSERT INTO `sys_oper_log` VALUES (8, '部门管理', 1, 'com.sensitive.web.controller.system.SysDeptController.add()', 'POST', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,202\",\"children\":[],\"createBy\":\"admin\",\"deptName\":\"软件技术专业教研室\",\"orderNum\":50,\"params\":{},\"parentId\":202,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:04:19', 10);
INSERT INTO `sys_oper_log` VALUES (9, '部门管理', 1, 'com.sensitive.web.controller.system.SysDeptController.add()', 'POST', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,202\",\"children\":[],\"createBy\":\"admin\",\"deptName\":\"信息安全应用技术教研室\",\"orderNum\":60,\"params\":{},\"parentId\":202,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:04:45', 10);
INSERT INTO `sys_oper_log` VALUES (10, '部门管理', 1, 'com.sensitive.web.controller.system.SysDeptController.add()', 'POST', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,202\",\"children\":[],\"createBy\":\"admin\",\"deptName\":\"应用化学教研室\",\"orderNum\":70,\"params\":{},\"parentId\":202,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:05:20', 11);
INSERT INTO `sys_oper_log` VALUES (11, '部门管理', 1, 'com.sensitive.web.controller.system.SysDeptController.add()', 'POST', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,202\",\"children\":[],\"createBy\":\"admin\",\"deptName\":\"人工智能技术应用服务教研室\",\"orderNum\":80,\"params\":{},\"parentId\":202,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:06:22', 8);
INSERT INTO `sys_oper_log` VALUES (12, '部门管理', 2, 'com.sensitive.web.controller.system.SysDeptController.edit()', 'PUT', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100\",\"children\":[],\"deptId\":201,\"deptName\":\"中山职业技术学院\",\"orderNum\":0,\"params\":{},\"parentId\":100,\"parentName\":\"超级管理\",\"status\":\"0\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:07:07', 21);
INSERT INTO `sys_oper_log` VALUES (13, '部门管理', 2, 'com.sensitive.web.controller.system.SysDeptController.edit()', 'PUT', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,202\",\"children\":[],\"deptId\":213,\"deptName\":\"人工智能技术应用服务教研室\",\"orderNum\":80,\"params\":{},\"parentId\":202,\"parentName\":\"信息工程学院\",\"status\":\"0\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:07:15', 15);
INSERT INTO `sys_oper_log` VALUES (14, '部门管理', 2, 'com.sensitive.web.controller.system.SysDeptController.edit()', 'PUT', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,202\",\"children\":[],\"deptId\":213,\"deptName\":\"人工智能技术应用服务教研\",\"orderNum\":80,\"params\":{},\"parentId\":202,\"parentName\":\"信息工程学院\",\"status\":\"0\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:07:23', 15);
INSERT INTO `sys_oper_log` VALUES (15, '部门管理', 1, 'com.sensitive.web.controller.system.SysDeptController.add()', 'POST', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201\",\"children\":[],\"createBy\":\"admin\",\"deptName\":\"艺术设计学院\",\"orderNum\":10,\"params\":{},\"parentId\":201,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:07:55', 10);
INSERT INTO `sys_oper_log` VALUES (16, '部门管理', 2, 'com.sensitive.web.controller.system.SysDeptController.edit()', 'PUT', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,202\",\"children\":[],\"deptId\":206,\"deptName\":\"信息工程学院办公室\",\"orderNum\":10,\"params\":{},\"parentId\":202,\"parentName\":\"信息工程学院\",\"status\":\"0\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:08:18', 14);
INSERT INTO `sys_oper_log` VALUES (17, '部门管理', 2, 'com.sensitive.web.controller.system.SysDeptController.edit()', 'PUT', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,202\",\"children\":[],\"deptId\":205,\"deptName\":\"信息工程党委院长\",\"orderNum\":0,\"params\":{},\"parentId\":202,\"parentName\":\"信息工程学院\",\"status\":\"0\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:08:28', 14);
INSERT INTO `sys_oper_log` VALUES (18, '部门管理', 1, 'com.sensitive.web.controller.system.SysDeptController.add()', 'POST', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,214\",\"children\":[],\"createBy\":\"admin\",\"deptName\":\"艺术设计学院办公室\",\"orderNum\":10,\"params\":{},\"parentId\":214,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:09:43', 8);
INSERT INTO `sys_oper_log` VALUES (19, '部门管理', 1, 'com.sensitive.web.controller.system.SysDeptController.add()', 'POST', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,214\",\"children\":[],\"createBy\":\"admin\",\"deptName\":\"艺术设计党委院长\",\"orderNum\":0,\"params\":{},\"parentId\":214,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:10:14', 12);
INSERT INTO `sys_oper_log` VALUES (20, '部门管理', 1, 'com.sensitive.web.controller.system.SysDeptController.add()', 'POST', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,214\",\"children\":[],\"createBy\":\"admin\",\"deptName\":\"艺术设计学生工作办公室\",\"orderNum\":20,\"params\":{},\"parentId\":214,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:10:47', 12);
INSERT INTO `sys_oper_log` VALUES (21, '部门管理', 2, 'com.sensitive.web.controller.system.SysDeptController.edit()', 'PUT', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,202\",\"children\":[],\"deptId\":207,\"deptName\":\"信息工程学生工作办公室\",\"orderNum\":20,\"params\":{},\"parentId\":202,\"parentName\":\"信息工程学院\",\"status\":\"0\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:11:00', 20);
INSERT INTO `sys_oper_log` VALUES (22, '部门管理', 1, 'com.sensitive.web.controller.system.SysDeptController.add()', 'POST', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,214\",\"children\":[],\"createBy\":\"admin\",\"deptName\":\"沙溪纺织服装学院\",\"orderNum\":30,\"params\":{},\"parentId\":214,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:12:01', 10);
INSERT INTO `sys_oper_log` VALUES (23, '部门管理', 1, 'com.sensitive.web.controller.system.SysDeptController.add()', 'POST', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,214\",\"children\":[],\"createBy\":\"admin\",\"deptName\":\"红木家居学院\",\"orderNum\":0,\"params\":{},\"parentId\":214,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:12:38', 9);
INSERT INTO `sys_oper_log` VALUES (24, '部门管理', 2, 'com.sensitive.web.controller.system.SysDeptController.edit()', 'PUT', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,214\",\"children\":[],\"deptId\":219,\"deptName\":\"红木家居学院\",\"orderNum\":40,\"params\":{},\"parentId\":214,\"parentName\":\"艺术设计学院\",\"status\":\"0\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:12:46', 15);
INSERT INTO `sys_oper_log` VALUES (25, '部门管理', 1, 'com.sensitive.web.controller.system.SysDeptController.add()', 'POST', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,214\",\"children\":[],\"createBy\":\"admin\",\"deptName\":\"产品艺术设计教研室\",\"orderNum\":50,\"params\":{},\"parentId\":214,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:13:58', 7);
INSERT INTO `sys_oper_log` VALUES (26, '部门管理', 1, 'com.sensitive.web.controller.system.SysDeptController.add()', 'POST', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,214\",\"children\":[],\"createBy\":\"admin\",\"deptName\":\"动漫制作技术教研室\",\"orderNum\":60,\"params\":{},\"parentId\":214,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:14:53', 9);
INSERT INTO `sys_oper_log` VALUES (27, '部门管理', 1, 'com.sensitive.web.controller.system.SysDeptController.add()', 'POST', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,214\",\"children\":[],\"createBy\":\"admin\",\"deptName\":\"环境艺术设计教研室\",\"orderNum\":70,\"params\":{},\"parentId\":214,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:15:20', 9);
INSERT INTO `sys_oper_log` VALUES (28, '部门管理', 1, 'com.sensitive.web.controller.system.SysDeptController.add()', 'POST', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,214\",\"children\":[],\"createBy\":\"admin\",\"deptName\":\"数字媒体艺术设计教研室\",\"orderNum\":0,\"params\":{},\"parentId\":214,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:16:10', 10);
INSERT INTO `sys_oper_log` VALUES (29, '部门管理', 2, 'com.sensitive.web.controller.system.SysDeptController.edit()', 'PUT', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,214\",\"children\":[],\"deptId\":223,\"deptName\":\"数字媒体艺术设计教研室\",\"orderNum\":80,\"params\":{},\"parentId\":214,\"parentName\":\"艺术设计学院\",\"status\":\"0\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:16:21', 20);
INSERT INTO `sys_oper_log` VALUES (30, '部门管理', 2, 'com.sensitive.web.controller.system.SysDeptController.edit()', 'PUT', 1, 'admin', '超级管理', '/system/dept', '127.0.0.1', '内网IP', '{\"ancestors\":\"0,100,201,202\",\"children\":[],\"deptId\":213,\"deptName\":\"人工智能技术应用服务教研室\",\"orderNum\":80,\"params\":{},\"parentId\":202,\"parentName\":\"信息工程学院\",\"status\":\"0\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-11-03 15:16:37', 14);

-- ----------------------------
-- Table structure for sys_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_post`;
CREATE TABLE `sys_post`  (
  `post_id` bigint NOT NULL AUTO_INCREMENT COMMENT '岗位ID',
  `post_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '岗位编码',
  `post_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '岗位名称',
  `post_sort` int NOT NULL COMMENT '显示顺序',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`post_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '岗位信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_post
-- ----------------------------
INSERT INTO `sys_post` VALUES (1, 'ceo', '超级管理员', 0, '0', 'admin', '2026-10-30 17:40:39', 'admin', '2026-10-30 21:26:39', '');
INSERT INTO `sys_post` VALUES (2, 'se', '专业主任', 2, '0', 'admin', '2026-10-30 17:40:39', 'admin', '2026-10-30 21:25:42', '');
INSERT INTO `sys_post` VALUES (3, 'hr', '院长', 3, '0', 'admin', '2026-10-30 17:40:39', 'admin', '2026-10-30 21:26:04', '');
INSERT INTO `sys_post` VALUES (4, 'user', '教师', 4, '0', 'admin', '2026-10-30 17:40:39', 'admin', '2026-11-03 14:59:32', '');
INSERT INTO `sys_post` VALUES (5, 'ji', '书记', 1, '0', 'admin', '2026-10-30 21:26:35', '', NULL, NULL);

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称',
  `role_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色权限字符串',
  `role_sort` int NOT NULL COMMENT '显示顺序',
  `data_scope` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）',
  `menu_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '菜单树选择项是否关联显示',
  `dept_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '部门树选择项是否关联显示',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`role_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 113 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '超级管理员', 'admin', 1, '1', 1, 1, '0', '0', 'admin', '2026-10-30 17:40:39', '', NULL, '超级管理员');
INSERT INTO `sys_role` VALUES (100, '个人', 'teacher', 16, '5', 1, 1, '0', '0', 'admin', '2026-10-30 19:38:43', 'admin', '2026-11-03 14:59:17', '维护本人录入且本人负责的成果；本人参与成果只读');
INSERT INTO `sys_role` VALUES (101, '专业主任', 'dept_head', 11, '1', 1, 1, '0', '0', 'admin', '2026-10-30 19:38:43', 'admin', '2026-10-30 21:33:55', '与院长、书记同级，全院信息只读查看下载');
INSERT INTO `sys_role` VALUES (102, '院长', 'dean', 11, '1', 1, 1, '0', '0', 'admin', '2026-10-30 19:38:43', 'admin', '2026-10-30 21:33:59', '全院信息只读查看下载');
INSERT INTO `sys_role` VALUES (103, '书记', 'secretary', 11, '1', 1, 1, '0', '0', 'admin', '2026-10-30 19:38:43', '', NULL, '全院信息只读查看下载');
INSERT INTO `sys_role` VALUES (112, '管理员', 'admin1', 2, '1', 1, 1, '0', '0', 'admin', '2026-11-03 14:57:54', 'admin', '2026-11-03 14:58:03', NULL);

-- ----------------------------
-- Table structure for sys_role_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_dept`;
CREATE TABLE `sys_role_dept`  (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `dept_id` bigint NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`role_id`, `dept_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色和部门关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_dept
-- ----------------------------

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu`  (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `menu_id` bigint NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色和菜单关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------
INSERT INTO `sys_role_menu` VALUES (1, 2000);
INSERT INTO `sys_role_menu` VALUES (1, 2001);
INSERT INTO `sys_role_menu` VALUES (1, 2002);
INSERT INTO `sys_role_menu` VALUES (1, 2003);
INSERT INTO `sys_role_menu` VALUES (1, 2004);
INSERT INTO `sys_role_menu` VALUES (1, 2005);
INSERT INTO `sys_role_menu` VALUES (1, 2006);
INSERT INTO `sys_role_menu` VALUES (1, 2007);
INSERT INTO `sys_role_menu` VALUES (1, 2009);
INSERT INTO `sys_role_menu` VALUES (1, 2010);
INSERT INTO `sys_role_menu` VALUES (1, 2011);
INSERT INTO `sys_role_menu` VALUES (1, 2012);
INSERT INTO `sys_role_menu` VALUES (1, 2013);
INSERT INTO `sys_role_menu` VALUES (1, 2014);
INSERT INTO `sys_role_menu` VALUES (1, 2015);
INSERT INTO `sys_role_menu` VALUES (1, 2016);
INSERT INTO `sys_role_menu` VALUES (1, 2017);
INSERT INTO `sys_role_menu` VALUES (1, 2018);
INSERT INTO `sys_role_menu` VALUES (1, 2019);
INSERT INTO `sys_role_menu` VALUES (1, 2020);
INSERT INTO `sys_role_menu` VALUES (1, 2021);
INSERT INTO `sys_role_menu` VALUES (1, 2022);
INSERT INTO `sys_role_menu` VALUES (1, 2023);
INSERT INTO `sys_role_menu` VALUES (100, 2000);
INSERT INTO `sys_role_menu` VALUES (100, 2001);
INSERT INTO `sys_role_menu` VALUES (100, 2002);
INSERT INTO `sys_role_menu` VALUES (100, 2003);
INSERT INTO `sys_role_menu` VALUES (100, 2004);
INSERT INTO `sys_role_menu` VALUES (100, 2005);
INSERT INTO `sys_role_menu` VALUES (100, 2006);
INSERT INTO `sys_role_menu` VALUES (100, 2007);
INSERT INTO `sys_role_menu` VALUES (100, 2009);
INSERT INTO `sys_role_menu` VALUES (100, 2010);
INSERT INTO `sys_role_menu` VALUES (100, 2011);
INSERT INTO `sys_role_menu` VALUES (100, 2012);
INSERT INTO `sys_role_menu` VALUES (100, 2013);
INSERT INTO `sys_role_menu` VALUES (100, 2014);
INSERT INTO `sys_role_menu` VALUES (100, 2015);
INSERT INTO `sys_role_menu` VALUES (100, 2016);
INSERT INTO `sys_role_menu` VALUES (100, 2017);
INSERT INTO `sys_role_menu` VALUES (100, 2018);
INSERT INTO `sys_role_menu` VALUES (100, 2019);
INSERT INTO `sys_role_menu` VALUES (100, 2020);
INSERT INTO `sys_role_menu` VALUES (100, 2021);
INSERT INTO `sys_role_menu` VALUES (100, 2022);
INSERT INTO `sys_role_menu` VALUES (100, 2023);
INSERT INTO `sys_role_menu` VALUES (101, 2000);
INSERT INTO `sys_role_menu` VALUES (101, 2001);
INSERT INTO `sys_role_menu` VALUES (101, 2002);
INSERT INTO `sys_role_menu` VALUES (101, 2003);
INSERT INTO `sys_role_menu` VALUES (101, 2004);
INSERT INTO `sys_role_menu` VALUES (101, 2005);
INSERT INTO `sys_role_menu` VALUES (101, 2006);
INSERT INTO `sys_role_menu` VALUES (101, 2007);
INSERT INTO `sys_role_menu` VALUES (101, 2009);
INSERT INTO `sys_role_menu` VALUES (101, 2010);
INSERT INTO `sys_role_menu` VALUES (101, 2011);
INSERT INTO `sys_role_menu` VALUES (101, 2012);
INSERT INTO `sys_role_menu` VALUES (101, 2013);
INSERT INTO `sys_role_menu` VALUES (101, 2014);
INSERT INTO `sys_role_menu` VALUES (101, 2015);
INSERT INTO `sys_role_menu` VALUES (101, 2016);
INSERT INTO `sys_role_menu` VALUES (101, 2017);
INSERT INTO `sys_role_menu` VALUES (101, 2018);
INSERT INTO `sys_role_menu` VALUES (101, 2019);
INSERT INTO `sys_role_menu` VALUES (101, 2020);
INSERT INTO `sys_role_menu` VALUES (101, 2021);
INSERT INTO `sys_role_menu` VALUES (101, 2022);
INSERT INTO `sys_role_menu` VALUES (101, 2023);
INSERT INTO `sys_role_menu` VALUES (102, 2000);
INSERT INTO `sys_role_menu` VALUES (102, 2001);
INSERT INTO `sys_role_menu` VALUES (102, 2002);
INSERT INTO `sys_role_menu` VALUES (102, 2003);
INSERT INTO `sys_role_menu` VALUES (102, 2004);
INSERT INTO `sys_role_menu` VALUES (102, 2005);
INSERT INTO `sys_role_menu` VALUES (102, 2006);
INSERT INTO `sys_role_menu` VALUES (102, 2007);
INSERT INTO `sys_role_menu` VALUES (102, 2009);
INSERT INTO `sys_role_menu` VALUES (102, 2010);
INSERT INTO `sys_role_menu` VALUES (102, 2011);
INSERT INTO `sys_role_menu` VALUES (102, 2012);
INSERT INTO `sys_role_menu` VALUES (102, 2013);
INSERT INTO `sys_role_menu` VALUES (102, 2014);
INSERT INTO `sys_role_menu` VALUES (102, 2015);
INSERT INTO `sys_role_menu` VALUES (102, 2016);
INSERT INTO `sys_role_menu` VALUES (102, 2017);
INSERT INTO `sys_role_menu` VALUES (102, 2018);
INSERT INTO `sys_role_menu` VALUES (102, 2019);
INSERT INTO `sys_role_menu` VALUES (102, 2020);
INSERT INTO `sys_role_menu` VALUES (102, 2021);
INSERT INTO `sys_role_menu` VALUES (102, 2022);
INSERT INTO `sys_role_menu` VALUES (102, 2023);
INSERT INTO `sys_role_menu` VALUES (103, 2000);
INSERT INTO `sys_role_menu` VALUES (103, 2001);
INSERT INTO `sys_role_menu` VALUES (103, 2002);
INSERT INTO `sys_role_menu` VALUES (103, 2003);
INSERT INTO `sys_role_menu` VALUES (103, 2004);
INSERT INTO `sys_role_menu` VALUES (103, 2005);
INSERT INTO `sys_role_menu` VALUES (103, 2006);
INSERT INTO `sys_role_menu` VALUES (103, 2007);
INSERT INTO `sys_role_menu` VALUES (103, 2009);
INSERT INTO `sys_role_menu` VALUES (103, 2010);
INSERT INTO `sys_role_menu` VALUES (103, 2011);
INSERT INTO `sys_role_menu` VALUES (103, 2012);
INSERT INTO `sys_role_menu` VALUES (103, 2013);
INSERT INTO `sys_role_menu` VALUES (103, 2014);
INSERT INTO `sys_role_menu` VALUES (103, 2015);
INSERT INTO `sys_role_menu` VALUES (103, 2016);
INSERT INTO `sys_role_menu` VALUES (103, 2017);
INSERT INTO `sys_role_menu` VALUES (103, 2018);
INSERT INTO `sys_role_menu` VALUES (103, 2019);
INSERT INTO `sys_role_menu` VALUES (103, 2020);
INSERT INTO `sys_role_menu` VALUES (103, 2021);
INSERT INTO `sys_role_menu` VALUES (103, 2022);
INSERT INTO `sys_role_menu` VALUES (103, 2023);
INSERT INTO `sys_role_menu` VALUES (112, 1);
INSERT INTO `sys_role_menu` VALUES (112, 2);
INSERT INTO `sys_role_menu` VALUES (112, 3);
INSERT INTO `sys_role_menu` VALUES (112, 100);
INSERT INTO `sys_role_menu` VALUES (112, 101);
INSERT INTO `sys_role_menu` VALUES (112, 102);
INSERT INTO `sys_role_menu` VALUES (112, 103);
INSERT INTO `sys_role_menu` VALUES (112, 104);
INSERT INTO `sys_role_menu` VALUES (112, 105);
INSERT INTO `sys_role_menu` VALUES (112, 106);
INSERT INTO `sys_role_menu` VALUES (112, 107);
INSERT INTO `sys_role_menu` VALUES (112, 108);
INSERT INTO `sys_role_menu` VALUES (112, 109);
INSERT INTO `sys_role_menu` VALUES (112, 110);
INSERT INTO `sys_role_menu` VALUES (112, 111);
INSERT INTO `sys_role_menu` VALUES (112, 112);
INSERT INTO `sys_role_menu` VALUES (112, 113);
INSERT INTO `sys_role_menu` VALUES (112, 114);
INSERT INTO `sys_role_menu` VALUES (112, 116);
INSERT INTO `sys_role_menu` VALUES (112, 500);
INSERT INTO `sys_role_menu` VALUES (112, 501);
INSERT INTO `sys_role_menu` VALUES (112, 1000);
INSERT INTO `sys_role_menu` VALUES (112, 1001);
INSERT INTO `sys_role_menu` VALUES (112, 1002);
INSERT INTO `sys_role_menu` VALUES (112, 1003);
INSERT INTO `sys_role_menu` VALUES (112, 1004);
INSERT INTO `sys_role_menu` VALUES (112, 1005);
INSERT INTO `sys_role_menu` VALUES (112, 1006);
INSERT INTO `sys_role_menu` VALUES (112, 1007);
INSERT INTO `sys_role_menu` VALUES (112, 1008);
INSERT INTO `sys_role_menu` VALUES (112, 1009);
INSERT INTO `sys_role_menu` VALUES (112, 1010);
INSERT INTO `sys_role_menu` VALUES (112, 1011);
INSERT INTO `sys_role_menu` VALUES (112, 1012);
INSERT INTO `sys_role_menu` VALUES (112, 1013);
INSERT INTO `sys_role_menu` VALUES (112, 1014);
INSERT INTO `sys_role_menu` VALUES (112, 1015);
INSERT INTO `sys_role_menu` VALUES (112, 1016);
INSERT INTO `sys_role_menu` VALUES (112, 1017);
INSERT INTO `sys_role_menu` VALUES (112, 1018);
INSERT INTO `sys_role_menu` VALUES (112, 1019);
INSERT INTO `sys_role_menu` VALUES (112, 1020);
INSERT INTO `sys_role_menu` VALUES (112, 1021);
INSERT INTO `sys_role_menu` VALUES (112, 1022);
INSERT INTO `sys_role_menu` VALUES (112, 1023);
INSERT INTO `sys_role_menu` VALUES (112, 1024);
INSERT INTO `sys_role_menu` VALUES (112, 1025);
INSERT INTO `sys_role_menu` VALUES (112, 1026);
INSERT INTO `sys_role_menu` VALUES (112, 1027);
INSERT INTO `sys_role_menu` VALUES (112, 1028);
INSERT INTO `sys_role_menu` VALUES (112, 1029);
INSERT INTO `sys_role_menu` VALUES (112, 1030);
INSERT INTO `sys_role_menu` VALUES (112, 1031);
INSERT INTO `sys_role_menu` VALUES (112, 1032);
INSERT INTO `sys_role_menu` VALUES (112, 1033);
INSERT INTO `sys_role_menu` VALUES (112, 1034);
INSERT INTO `sys_role_menu` VALUES (112, 1035);
INSERT INTO `sys_role_menu` VALUES (112, 1036);
INSERT INTO `sys_role_menu` VALUES (112, 1037);
INSERT INTO `sys_role_menu` VALUES (112, 1038);
INSERT INTO `sys_role_menu` VALUES (112, 1039);
INSERT INTO `sys_role_menu` VALUES (112, 1040);
INSERT INTO `sys_role_menu` VALUES (112, 1041);
INSERT INTO `sys_role_menu` VALUES (112, 1042);
INSERT INTO `sys_role_menu` VALUES (112, 1043);
INSERT INTO `sys_role_menu` VALUES (112, 1044);
INSERT INTO `sys_role_menu` VALUES (112, 1045);
INSERT INTO `sys_role_menu` VALUES (112, 1046);
INSERT INTO `sys_role_menu` VALUES (112, 1047);
INSERT INTO `sys_role_menu` VALUES (112, 1048);
INSERT INTO `sys_role_menu` VALUES (112, 1049);
INSERT INTO `sys_role_menu` VALUES (112, 1050);
INSERT INTO `sys_role_menu` VALUES (112, 1051);
INSERT INTO `sys_role_menu` VALUES (112, 1052);
INSERT INTO `sys_role_menu` VALUES (112, 1053);
INSERT INTO `sys_role_menu` VALUES (112, 1054);
INSERT INTO `sys_role_menu` VALUES (112, 1055);
INSERT INTO `sys_role_menu` VALUES (112, 1056);
INSERT INTO `sys_role_menu` VALUES (112, 1057);
INSERT INTO `sys_role_menu` VALUES (112, 1058);
INSERT INTO `sys_role_menu` VALUES (112, 1059);
INSERT INTO `sys_role_menu` VALUES (112, 1060);
INSERT INTO `sys_role_menu` VALUES (112, 2000);
INSERT INTO `sys_role_menu` VALUES (112, 2001);
INSERT INTO `sys_role_menu` VALUES (112, 2002);
INSERT INTO `sys_role_menu` VALUES (112, 2003);
INSERT INTO `sys_role_menu` VALUES (112, 2004);
INSERT INTO `sys_role_menu` VALUES (112, 2005);
INSERT INTO `sys_role_menu` VALUES (112, 2006);
INSERT INTO `sys_role_menu` VALUES (112, 2007);
INSERT INTO `sys_role_menu` VALUES (112, 2009);
INSERT INTO `sys_role_menu` VALUES (112, 2010);
INSERT INTO `sys_role_menu` VALUES (112, 2011);
INSERT INTO `sys_role_menu` VALUES (112, 2012);
INSERT INTO `sys_role_menu` VALUES (112, 2013);
INSERT INTO `sys_role_menu` VALUES (112, 2014);
INSERT INTO `sys_role_menu` VALUES (112, 2015);
INSERT INTO `sys_role_menu` VALUES (112, 2016);
INSERT INTO `sys_role_menu` VALUES (112, 2017);
INSERT INTO `sys_role_menu` VALUES (112, 2018);
INSERT INTO `sys_role_menu` VALUES (112, 2019);
INSERT INTO `sys_role_menu` VALUES (112, 2020);
INSERT INTO `sys_role_menu` VALUES (112, 2021);
INSERT INTO `sys_role_menu` VALUES (112, 2022);
INSERT INTO `sys_role_menu` VALUES (112, 2023);

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `user_id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `dept_id` bigint NULL DEFAULT NULL COMMENT '部门ID',
  `user_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户账号',
  `nick_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户昵称',
  `user_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '00' COMMENT '用户类型（00系统用户）',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '用户邮箱',
  `phonenumber` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '手机号码',
  `sex` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
  `avatar` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '头像地址',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '密码',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '账号状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `login_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '最后登录IP',
  `login_date` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `pwd_update_date` datetime NULL DEFAULT NULL COMMENT '密码最后更新时间',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 146 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 100, 'admin', 'xain', '00', 'ry@163.com', '15888888888', '0', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2026-11-03 14:35:49', '2026-10-30 17:40:39', 'admin', '2026-10-30 17:40:39', '', '2026-11-01 23:15:29', '管理员');

-- ----------------------------
-- Table structure for sys_user_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_post`;
CREATE TABLE `sys_user_post`  (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `post_id` bigint NOT NULL COMMENT '岗位ID',
  PRIMARY KEY (`user_id`, `post_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户与岗位关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_post
-- ----------------------------
INSERT INTO `sys_user_post` VALUES (1, 1);

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户和角色关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (1, 1);

-- ----------------------------
-- Table structure for zs_achievement
-- ----------------------------
DROP TABLE IF EXISTS `zs_achievement`;
CREATE TABLE `zs_achievement`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `category_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'project_major/project_research/project_horizontal/project_student/award_teacher/award_student/course/textbook/paper/patent/patent_transfer/visit/tech_training/study_training/media',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '成果、项目、奖项或活动名称',
  `owner_id` bigint NOT NULL COMMENT '负责人若依用户ID',
  `major_dept_id` bigint NOT NULL COMMENT '负责人所属专业 sys_dept.dept_id',
  `level_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '国家/省/市/校等，按类别使用',
  `achieved_date` date NULL DEFAULT NULL COMMENT '主要日期；详细日期保存在类别明细表',
  `remark` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `created_by` bigint NOT NULL COMMENT '录入人若依用户ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除：0=正常 1=已删除',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_achievement_owner_date`(`owner_id` ASC, `achieved_date` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_achievement_major_date`(`major_dept_id` ASC, `achieved_date` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_achievement_category_date`(`category_code` ASC, `achieved_date` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_achievement_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2229 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '业绩成果主表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of zs_achievement
-- ----------------------------

-- ----------------------------
-- Table structure for zs_achievement_member
-- ----------------------------
DROP TABLE IF EXISTS `zs_achievement_member`;
CREATE TABLE `zs_achievement_member`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `achievement_id` bigint NOT NULL COMMENT 'zs_achievement.id',
  `user_id` bigint NULL DEFAULT NULL COMMENT '校内教师若依用户ID；学生/校外人员为空',
  `member_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '参与人姓名',
  `member_role` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'member/student/supervisor/participant/author/editor/co_editor/inventor/winner/accompany/lecturer',
  `sort_num` int NOT NULL DEFAULT 0 COMMENT '成员显示顺序',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_member_user_achievement`(`user_id` ASC, `achievement_id` ASC) USING BTREE,
  INDEX `idx_member_achievement_role`(`achievement_id` ASC, `member_role` ASC) USING BTREE,
  INDEX `idx_member_name`(`member_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 69 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '成果参与人员' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of zs_achievement_member
-- ----------------------------

-- ----------------------------
-- Table structure for zs_achievement_sort
-- ----------------------------
DROP TABLE IF EXISTS `zs_achievement_sort`;
CREATE TABLE `zs_achievement_sort`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '排序配置所属教师',
  `category_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `sort_year` smallint NOT NULL COMMENT '0=不区分年度',
  `achievement_id` bigint NOT NULL,
  `sort_num` int NOT NULL DEFAULT 0,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_sort`(`user_id` ASC, `category_code` ASC, `sort_year` ASC, `achievement_id` ASC) USING BTREE,
  INDEX `idx_sort_order`(`user_id` ASC, `category_code` ASC, `sort_year` ASC, `sort_num` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 104 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '成果自定义排序' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of zs_achievement_sort
-- ----------------------------

-- ----------------------------
-- Table structure for zs_attachment
-- ----------------------------
DROP TABLE IF EXISTS `zs_attachment`;
CREATE TABLE `zs_attachment`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `uploader_id` bigint NOT NULL COMMENT '上传人 sys_user.user_id',
  `target_type` tinyint NOT NULL COMMENT '1=成果佐证 2=学历证 3=学位证 4=职称证',
  `achievement_id` bigint NULL DEFAULT NULL COMMENT '成果附件时填写',
  `profile_user_id` bigint NULL DEFAULT NULL COMMENT '个人证件对应教师 user_id',
  `original_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `storage_key` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '私有存储对象键；下载走后端鉴权',
  `file_size` bigint NOT NULL COMMENT '字节；由应用层校验业务限制',
  `mime_type` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `file_ext` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `content_sha256` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '可选完整性/重复检测',
  `sort_num` int NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_attachment_achievement`(`achievement_id` ASC, `deleted` ASC, `sort_num` ASC) USING BTREE,
  INDEX `idx_attachment_profile`(`profile_user_id` ASC, `target_type` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_attachment_uploader`(`uploader_id` ASC, `created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2104 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '成果佐证与个人证件附件' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of zs_attachment
-- ----------------------------

-- ----------------------------
-- Table structure for zs_audit_log
-- ----------------------------
DROP TABLE IF EXISTS `zs_audit_log`;
CREATE TABLE `zs_audit_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '操作人',
  `action` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'view/download/export/create/update/delete',
  `target_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'achievement/attachment/teacher_profile/export_task',
  `target_id` bigint NULL DEFAULT NULL,
  `detail` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `client_ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_audit_user_time`(`user_id` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_audit_target`(`target_type` ASC, `target_id` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_audit_action_time`(`action` ASC, `created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 993 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '操作审计日志' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of zs_audit_log
-- ----------------------------

-- ----------------------------
-- Table structure for zs_detail_award
-- ----------------------------
DROP TABLE IF EXISTS `zs_detail_award`;
CREATE TABLE `zs_detail_award`  (
  `achievement_id` bigint NOT NULL,
  `award_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '教师获奖类型或学生奖项类型',
  `award_grade` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '一/二/三等/优秀/金/银/铜/特等/其他',
  `issuer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '授奖单位/发证单位',
  `award_level` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '国家/省/市/校/企业等',
  `award_date` date NULL DEFAULT NULL,
  PRIMARY KEY (`achievement_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '获奖明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of zs_detail_award
-- ----------------------------

-- ----------------------------
-- Table structure for zs_detail_course
-- ----------------------------
DROP TABLE IF EXISTS `zs_detail_course`;
CREATE TABLE `zs_detail_course`  (
  `achievement_id` bigint NOT NULL,
  `project_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '立项项目名称',
  `approving_unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '立项单位',
  `project_level` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `start_date` date NULL DEFAULT NULL,
  `finish_date` date NULL DEFAULT NULL,
  PRIMARY KEY (`achievement_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '课程明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of zs_detail_course
-- ----------------------------

-- ----------------------------
-- Table structure for zs_detail_media
-- ----------------------------
DROP TABLE IF EXISTS `zs_detail_media`;
CREATE TABLE `zs_detail_media`  (
  `achievement_id` bigint NOT NULL,
  `media_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '报道标题',
  `media_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '媒体名称',
  `media_level` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '国家/省/市/镇街/单位',
  `media_url` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '链接',
  `publish_date` date NULL DEFAULT NULL,
  PRIMARY KEY (`achievement_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '媒体报道明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of zs_detail_media
-- ----------------------------

-- ----------------------------
-- Table structure for zs_detail_paper
-- ----------------------------
DROP TABLE IF EXISTS `zs_detail_paper`;
CREATE TABLE `zs_detail_paper`  (
  `achievement_id` bigint NOT NULL,
  `paper_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '科研/教研',
  `paper_level` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '中文核心/SCI/EI/普通',
  `journal_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发表期刊',
  `publish_date` date NULL DEFAULT NULL,
  `first_author` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '第一作者姓名；校内人员同时关联成员表',
  PRIMARY KEY (`achievement_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '论文明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of zs_detail_paper
-- ----------------------------

-- ----------------------------
-- Table structure for zs_detail_patent
-- ----------------------------
DROP TABLE IF EXISTS `zs_detail_patent`;
CREATE TABLE `zs_detail_patent`  (
  `achievement_id` bigint NOT NULL,
  `patent_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '专利/实用新型/软件著作权',
  `rights_holder` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '权利人/著作权人',
  `registration_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '专利号/登记号',
  `apply_date` date NULL DEFAULT NULL,
  `grant_date` date NULL DEFAULT NULL COMMENT '授权日期',
  PRIMARY KEY (`achievement_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '专利及软著明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of zs_detail_patent
-- ----------------------------

-- ----------------------------
-- Table structure for zs_detail_patent_transfer
-- ----------------------------
DROP TABLE IF EXISTS `zs_detail_patent_transfer`;
CREATE TABLE `zs_detail_patent_transfer`  (
  `achievement_id` bigint NOT NULL,
  `patent_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `patent_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `inventors` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发明人显示文本；校内人员同时关联成员表',
  `transfer_fee` decimal(14, 2) NULL DEFAULT NULL COMMENT '转让费，元/项',
  `transferee` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '受让方',
  `transfer_date` date NULL DEFAULT NULL,
  PRIMARY KEY (`achievement_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '专利转让明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of zs_detail_patent_transfer
-- ----------------------------

-- ----------------------------
-- Table structure for zs_detail_project_horizontal
-- ----------------------------
DROP TABLE IF EXISTS `zs_detail_project_horizontal`;
CREATE TABLE `zs_detail_project_horizontal`  (
  `achievement_id` bigint NOT NULL,
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '合作企业',
  `contract_wan` decimal(14, 2) NULL DEFAULT NULL COMMENT '合同金额，万元',
  `received_wan` decimal(14, 2) NULL DEFAULT NULL COMMENT '到账金额，万元',
  `start_date` date NULL DEFAULT NULL,
  `end_date` date NULL DEFAULT NULL,
  PRIMARY KEY (`achievement_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '横向项目明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of zs_detail_project_horizontal
-- ----------------------------

-- ----------------------------
-- Table structure for zs_detail_project_major
-- ----------------------------
DROP TABLE IF EXISTS `zs_detail_project_major`;
CREATE TABLE `zs_detail_project_major`  (
  `achievement_id` bigint NOT NULL,
  `project_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '工程中心/实训基地/重点专业/技能平台/紧缺专业/其他',
  `issuing_unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '下达单位',
  `fund_wan` decimal(14, 2) NULL DEFAULT NULL COMMENT '经费，万元',
  `apply_date` date NULL DEFAULT NULL,
  `finish_date` date NULL DEFAULT NULL COMMENT '结题日期',
  `contract_wan` decimal(14, 2) NULL DEFAULT NULL COMMENT '合同经费，万元',
  `received_wan` decimal(14, 2) NULL DEFAULT NULL COMMENT '到账经费，万元',
  PRIMARY KEY (`achievement_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '按专业申报项目明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of zs_detail_project_major
-- ----------------------------

-- ----------------------------
-- Table structure for zs_detail_project_research
-- ----------------------------
DROP TABLE IF EXISTS `zs_detail_project_research`;
CREATE TABLE `zs_detail_project_research`  (
  `achievement_id` bigint NOT NULL,
  `project_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '教研/科研/其他',
  `issuing_unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `fund_wan` decimal(14, 2) NULL DEFAULT NULL COMMENT '经费，万元',
  `apply_date` date NULL DEFAULT NULL,
  `finish_date` date NULL DEFAULT NULL,
  `contract_wan` decimal(14, 2) NULL DEFAULT NULL COMMENT '合同经费，万元',
  `received_wan` decimal(14, 2) NULL DEFAULT NULL COMMENT '到账经费，万元',
  PRIMARY KEY (`achievement_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '教科研项目明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of zs_detail_project_research
-- ----------------------------

-- ----------------------------
-- Table structure for zs_detail_project_student
-- ----------------------------
DROP TABLE IF EXISTS `zs_detail_project_student`;
CREATE TABLE `zs_detail_project_student`  (
  `achievement_id` bigint NOT NULL,
  `issuing_unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '下达单位',
  `project_level` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '国家级/省级/市级/校级',
  `fund_wan` decimal(14, 2) NULL DEFAULT NULL COMMENT '经费，万元',
  `grant_date` date NULL DEFAULT NULL COMMENT '下达时间',
  `finish_date` date NULL DEFAULT NULL COMMENT '完成时间',
  `contract_wan` decimal(14, 2) NULL DEFAULT NULL COMMENT '合同经费，万元',
  `received_wan` decimal(14, 2) NULL DEFAULT NULL COMMENT '到账经费，万元',
  PRIMARY KEY (`achievement_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '指导学生项目明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of zs_detail_project_student
-- ----------------------------

-- ----------------------------
-- Table structure for zs_detail_study_training
-- ----------------------------
DROP TABLE IF EXISTS `zs_detail_study_training`;
CREATE TABLE `zs_detail_study_training`  (
  `achievement_id` bigint NOT NULL,
  `training_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '培训/会议',
  `scope` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '国内/国际',
  `training_level` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '省培/国培/其他',
  `organizer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '主办单位',
  `issuer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发证单位',
  `event_date` date NULL DEFAULT NULL,
  PRIMARY KEY (`achievement_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '培训进修明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of zs_detail_study_training
-- ----------------------------

-- ----------------------------
-- Table structure for zs_detail_tech_training
-- ----------------------------
DROP TABLE IF EXISTS `zs_detail_tech_training`;
CREATE TABLE `zs_detail_tech_training`  (
  `achievement_id` bigint NOT NULL,
  `audience` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邀请单位或授课对象',
  `lecturer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '主讲人；校内人员同时关联成员表',
  `participant_count` int NULL DEFAULT NULL COMMENT '人数',
  `event_date` date NULL DEFAULT NULL,
  PRIMARY KEY (`achievement_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '举办技术交流/培训明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of zs_detail_tech_training
-- ----------------------------

-- ----------------------------
-- Table structure for zs_detail_textbook
-- ----------------------------
DROP TABLE IF EXISTS `zs_detail_textbook`;
CREATE TABLE `zs_detail_textbook`  (
  `achievement_id` bigint NOT NULL,
  `isbn` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `editor_in_chief` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '主编；校内人员同时关联成员表',
  `publisher` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '出版单位',
  `publish_date` date NULL DEFAULT NULL,
  `textbook_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '活页式/工作手册式/数字教材/普通教材',
  `textbook_level` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '国家规划/省规划/普通/校本教材',
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '合作企业',
  PRIMARY KEY (`achievement_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '教材明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of zs_detail_textbook
-- ----------------------------

-- ----------------------------
-- Table structure for zs_detail_visit
-- ----------------------------
DROP TABLE IF EXISTS `zs_detail_visit`;
CREATE TABLE `zs_detail_visit`  (
  `achievement_id` bigint NOT NULL,
  `visit_unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '接待单位',
  `contact_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系人',
  `accompany_text` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '陪同人；校内人员同时关联成员表',
  `visit_date` date NULL DEFAULT NULL,
  `content` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '主要内容',
  PRIMARY KEY (`achievement_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '接待交流明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of zs_detail_visit
-- ----------------------------

-- ----------------------------
-- Table structure for zs_export_task
-- ----------------------------
DROP TABLE IF EXISTS `zs_export_task`;
CREATE TABLE `zs_export_task`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `requester_id` bigint NOT NULL COMMENT '发起人 sys_user.user_id',
  `task_type` tinyint NOT NULL COMMENT '1=Excel 2=Word佐证材料 3=附件ZIP',
  `params_json` json NULL COMMENT 'personId/startDate/endDate/categoryCode等筛选条件',
  `snapshot_json` json NULL COMMENT '成果ID及导出顺序快照，保证多个输出顺序一致',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '0=排队 1=生成中 2=成功 3=失败',
  `storage_key` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '生成文件私有存储键',
  `error_message` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `finished_at` datetime NULL DEFAULT NULL,
  `expires_at` datetime NULL DEFAULT NULL COMMENT '下载文件过期时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_export_requester_time`(`requester_id` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_export_status_time`(`status` ASC, `created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 136 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '导出任务' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of zs_export_task
-- ----------------------------

-- ----------------------------
-- Table structure for zs_teacher_profile
-- ----------------------------
DROP TABLE IF EXISTS `zs_teacher_profile`;
CREATE TABLE `zs_teacher_profile`  (
  `user_id` bigint NOT NULL COMMENT '若依 sys_user.user_id',
  `major_dept_id` bigint NOT NULL COMMENT '所属专业，若依 sys_dept.dept_id',
  `real_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '教师姓名',
  `gender` tinyint NULL DEFAULT NULL COMMENT '1=男 2=女',
  `birth_date` date NULL DEFAULT NULL COMMENT '出生日期',
  `ethnicity` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '民族',
  `political_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '政治面貌',
  `highest_education` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '最高学历',
  `highest_degree` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '最高学位',
  `degree_date` date NULL DEFAULT NULL COMMENT '学位获取时间',
  `position_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '职务',
  `professional_title` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '职称',
  `title_date` date NULL DEFAULT NULL COMMENT '职称获取时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`) USING BTREE,
  INDEX `idx_profile_major`(`major_dept_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '教师个人资料' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of zs_teacher_profile
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
