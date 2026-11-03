-- 信息工程学院业绩成果收集系统数据库设计
-- MySQL 5.7+/8.0，InnoDB，utf8mb4
-- 复用若依 sys_user、sys_role、sys_user_role、sys_dept，不重复创建。
-- sys_dept 配置学院及专业。组织权限：教师维护自己的成果；
-- 专业主任/院长/书记同级，全院只读查看和下载；超级管理员全权。
-- 按教师查询/导出时，按 owner_id 或 zs_achievement_member.user_id 联查。
-- 项目经费、合同金额、到账金额统一以万元计（DECIMAL(14,2)）；专利转让费按原始需求以元/项计。

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS zs_teacher_profile (
  user_id BIGINT NOT NULL COMMENT '若依 sys_user.user_id',
  major_dept_id BIGINT NOT NULL COMMENT '所属专业，若依 sys_dept.dept_id',
  real_name VARCHAR(64) NOT NULL COMMENT '教师姓名',
  gender TINYINT NULL COMMENT '1=男 2=女',
  birth_date DATE NULL COMMENT '出生日期',
  ethnicity VARCHAR(32) NULL COMMENT '民族',
  political_status VARCHAR(32) NULL COMMENT '政治面貌',
  highest_education VARCHAR(32) NULL COMMENT '最高学历',
  highest_degree VARCHAR(32) NULL COMMENT '最高学位',
  degree_date DATE NULL COMMENT '学位获取时间',
  position_name VARCHAR(64) NULL COMMENT '职务',
  professional_title VARCHAR(64) NULL COMMENT '职称',
  title_date DATE NULL COMMENT '职称获取时间',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  KEY idx_profile_major (major_dept_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='教师个人资料';

CREATE TABLE IF NOT EXISTS zs_achievement (
  id BIGINT NOT NULL AUTO_INCREMENT,
  category_code VARCHAR(32) NOT NULL COMMENT 'project_major/project_research/project_horizontal/project_student/award_teacher/award_student/course/textbook/paper/patent/patent_transfer/visit/tech_training/study_training/media',
  name VARCHAR(255) NOT NULL COMMENT '成果、项目、奖项或活动名称',
  owner_id BIGINT NOT NULL COMMENT '负责人若依用户ID',
  major_dept_id BIGINT NOT NULL COMMENT '负责人所属专业 sys_dept.dept_id',
  level_code VARCHAR(64) NULL COMMENT '国家/省/市/校等，按类别使用',
  achieved_date DATE NULL COMMENT '主要日期；详细日期保存在类别明细表',
  remark VARCHAR(1000) NULL,
  created_by BIGINT NOT NULL COMMENT '录入人若依用户ID',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除：0=正常 1=已删除',
  PRIMARY KEY (id),
  KEY idx_achievement_owner_date (owner_id, achieved_date, deleted),
  KEY idx_achievement_major_date (major_dept_id, achieved_date, deleted),
  KEY idx_achievement_category_date (category_code, achieved_date, deleted),
  KEY idx_achievement_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='业绩成果主表';

CREATE TABLE IF NOT EXISTS zs_achievement_member (
  id BIGINT NOT NULL AUTO_INCREMENT,
  achievement_id BIGINT NOT NULL COMMENT 'zs_achievement.id',
  user_id BIGINT NULL COMMENT '校内教师若依用户ID；学生/校外人员为空',
  member_name VARCHAR(100) NOT NULL COMMENT '参与人姓名',
  member_role VARCHAR(32) NOT NULL COMMENT 'member/student/supervisor/participant/author/editor/co_editor/inventor/winner/accompany/lecturer',
  sort_num INT NOT NULL DEFAULT 0 COMMENT '成员显示顺序',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_member_user_achievement (user_id, achievement_id),
  KEY idx_member_achievement_role (achievement_id, member_role),
  KEY idx_member_name (member_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='成果参与人员';

CREATE TABLE IF NOT EXISTS zs_detail_project_major (
  achievement_id BIGINT NOT NULL,
  project_type VARCHAR(64) NULL COMMENT '工程中心/实训基地/重点专业/技能平台/紧缺专业/其他',
  issuing_unit VARCHAR(255) NULL COMMENT '下达单位',
  contract_wan DECIMAL(14,2) NULL COMMENT '合同经费，万元',
  received_wan DECIMAL(14,2) NULL COMMENT '到账经费，万元',
  apply_date DATE NULL,
  finish_date DATE NULL COMMENT '结题日期',
  PRIMARY KEY (achievement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='按专业申报项目明细';

CREATE TABLE IF NOT EXISTS zs_detail_project_research (
  achievement_id BIGINT NOT NULL,
  project_type VARCHAR(32) NULL COMMENT '教研/科研/其他',
  issuing_unit VARCHAR(255) NULL,
  contract_wan DECIMAL(14,2) NULL COMMENT '合同经费，万元',
  received_wan DECIMAL(14,2) NULL COMMENT '到账经费，万元',
  apply_date DATE NULL,
  finish_date DATE NULL,
  PRIMARY KEY (achievement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='教科研项目明细';

CREATE TABLE IF NOT EXISTS zs_detail_project_horizontal (
  achievement_id BIGINT NOT NULL,
  company_name VARCHAR(255) NULL COMMENT '合作企业',
  contract_wan DECIMAL(14,2) NULL COMMENT '合同金额，万元',
  received_wan DECIMAL(14,2) NULL COMMENT '到账金额，万元',
  start_date DATE NULL,
  end_date DATE NULL,
  PRIMARY KEY (achievement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='横向项目明细';

CREATE TABLE IF NOT EXISTS zs_detail_project_student (
  achievement_id BIGINT NOT NULL,
  issuing_unit VARCHAR(255) NULL COMMENT '下达单位',
  project_level VARCHAR(64) NULL COMMENT '国家级/省级/市级/校级',
  contract_wan DECIMAL(14,2) NULL COMMENT '合同经费，万元',
  received_wan DECIMAL(14,2) NULL COMMENT '到账经费，万元',
  grant_date DATE NULL COMMENT '下达时间',
  finish_date DATE NULL COMMENT '完成时间',
  PRIMARY KEY (achievement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='指导学生项目明细';

CREATE TABLE IF NOT EXISTS zs_detail_award (
  achievement_id BIGINT NOT NULL,
  award_type VARCHAR(64) NULL COMMENT '教师获奖类型或学生奖项类型',
  award_grade VARCHAR(64) NULL COMMENT '一/二/三等/优秀/金/银/铜/特等/其他',
  issuer VARCHAR(255) NULL COMMENT '授奖单位/发证单位',
  award_level VARCHAR(64) NULL COMMENT '国家/省/市/校/企业等',
  award_date DATE NULL,
  PRIMARY KEY (achievement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='获奖明细';

CREATE TABLE IF NOT EXISTS zs_detail_course (
  achievement_id BIGINT NOT NULL,
  project_name VARCHAR(255) NULL COMMENT '立项项目名称',
  approving_unit VARCHAR(255) NULL COMMENT '立项单位',
  project_level VARCHAR(64) NULL,
  start_date DATE NULL,
  finish_date DATE NULL,
  PRIMARY KEY (achievement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='课程明细';

CREATE TABLE IF NOT EXISTS zs_detail_textbook (
  achievement_id BIGINT NOT NULL,
  isbn VARCHAR(32) NULL,
  editor_in_chief VARCHAR(255) NULL COMMENT '主编；校内人员同时关联成员表',
  publisher VARCHAR(255) NULL COMMENT '出版单位',
  publish_date DATE NULL,
  textbook_type VARCHAR(64) NULL COMMENT '活页式/工作手册式/数字教材/普通教材',
  textbook_level VARCHAR(64) NULL COMMENT '国家规划/省规划/普通/校本教材',
  company_name VARCHAR(255) NULL COMMENT '合作企业',
  PRIMARY KEY (achievement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='教材明细';

CREATE TABLE IF NOT EXISTS zs_detail_paper (
  achievement_id BIGINT NOT NULL,
  paper_type VARCHAR(32) NULL COMMENT '科研/教研',
  paper_level VARCHAR(64) NULL COMMENT '中文核心/SCI/EI/普通',
  journal_name VARCHAR(255) NULL COMMENT '发表期刊',
  publish_date DATE NULL,
  first_author VARCHAR(100) NULL COMMENT '第一作者姓名；校内人员同时关联成员表',
  PRIMARY KEY (achievement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='论文明细';

CREATE TABLE IF NOT EXISTS zs_detail_patent (
  achievement_id BIGINT NOT NULL,
  patent_type VARCHAR(64) NULL COMMENT '专利/实用新型/软件著作权',
  rights_holder VARCHAR(255) NULL COMMENT '权利人/著作权人',
  registration_no VARCHAR(100) NULL COMMENT '专利号/登记号',
  apply_date DATE NULL,
  grant_date DATE NULL COMMENT '授权日期',
  PRIMARY KEY (achievement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='专利及软著明细';

CREATE TABLE IF NOT EXISTS zs_detail_patent_transfer (
  achievement_id BIGINT NOT NULL,
  patent_type VARCHAR(64) NULL,
  patent_no VARCHAR(100) NULL,
  inventors VARCHAR(500) NULL COMMENT '发明人显示文本；校内人员同时关联成员表',
  transfer_fee DECIMAL(14,2) NULL COMMENT '转让费，元/项',
  transferee VARCHAR(255) NULL COMMENT '受让方',
  transfer_date DATE NULL,
  PRIMARY KEY (achievement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='专利转让明细';

CREATE TABLE IF NOT EXISTS zs_detail_visit (
  achievement_id BIGINT NOT NULL,
  visit_unit VARCHAR(255) NULL COMMENT '接待单位',
  contact_name VARCHAR(100) NULL COMMENT '联系人',
  accompany_text VARCHAR(500) NULL COMMENT '陪同人；校内人员同时关联成员表',
  visit_date DATE NULL,
  content VARCHAR(2000) NULL COMMENT '主要内容',
  PRIMARY KEY (achievement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='接待交流明细';

CREATE TABLE IF NOT EXISTS zs_detail_tech_training (
  achievement_id BIGINT NOT NULL,
  audience VARCHAR(500) NULL COMMENT '邀请单位或授课对象',
  lecturer VARCHAR(255) NULL COMMENT '主讲人；校内人员同时关联成员表',
  participant_count INT NULL COMMENT '人数',
  event_date DATE NULL,
  PRIMARY KEY (achievement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='举办技术交流/培训明细';

CREATE TABLE IF NOT EXISTS zs_detail_study_training (
  achievement_id BIGINT NOT NULL,
  training_type VARCHAR(32) NULL COMMENT '培训/会议',
  scope VARCHAR(32) NULL COMMENT '国内/国际',
  training_level VARCHAR(64) NULL COMMENT '省培/国培/其他',
  organizer VARCHAR(255) NULL COMMENT '主办单位',
  issuer VARCHAR(255) NULL COMMENT '发证单位',
  event_date DATE NULL,
  PRIMARY KEY (achievement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='培训进修明细';

CREATE TABLE IF NOT EXISTS zs_detail_media (
  achievement_id BIGINT NOT NULL,
  media_title VARCHAR(255) NULL COMMENT '报道标题',
  media_name VARCHAR(255) NULL COMMENT '媒体名称',
  media_level VARCHAR(64) NULL COMMENT '国家/省/市/镇街/单位',
  media_url VARCHAR(1000) NULL COMMENT '链接',
  publish_date DATE NULL,
  PRIMARY KEY (achievement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='媒体报道明细';

CREATE TABLE IF NOT EXISTS zs_achievement_sort (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NOT NULL COMMENT '排序配置所属教师',
  category_code VARCHAR(32) NOT NULL,
  sort_year SMALLINT NOT NULL COMMENT '0=不区分年度',
  achievement_id BIGINT NOT NULL,
  sort_num INT NOT NULL DEFAULT 0,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_sort (user_id, category_code, sort_year, achievement_id),
  KEY idx_sort_order (user_id, category_code, sort_year, sort_num)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='成果自定义排序';

CREATE TABLE IF NOT EXISTS zs_attachment (
  id BIGINT NOT NULL AUTO_INCREMENT,
  uploader_id BIGINT NOT NULL COMMENT '上传人 sys_user.user_id',
  target_type TINYINT NOT NULL COMMENT '1=成果佐证 2=学历证 3=学位证 4=职称证',
  achievement_id BIGINT NULL COMMENT '成果附件时填写',
  profile_user_id BIGINT NULL COMMENT '个人证件对应教师 user_id',
  original_name VARCHAR(255) NOT NULL,
  storage_key VARCHAR(1000) NOT NULL COMMENT '私有存储对象键；下载走后端鉴权',
  file_size BIGINT NOT NULL COMMENT '字节；由应用层校验业务限制',
  mime_type VARCHAR(128) NULL,
  file_ext VARCHAR(16) NULL,
  content_sha256 CHAR(64) NULL COMMENT '可选完整性/重复检测',
  sort_num INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted TINYINT NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_attachment_achievement (achievement_id, deleted, sort_num),
  KEY idx_attachment_profile (profile_user_id, target_type, deleted),
  KEY idx_attachment_uploader (uploader_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='成果佐证与个人证件附件';

CREATE TABLE IF NOT EXISTS zs_export_task (
  id BIGINT NOT NULL AUTO_INCREMENT,
  requester_id BIGINT NOT NULL COMMENT '发起人 sys_user.user_id',
    task_type TINYINT NOT NULL COMMENT '1=Excel 2=Word佐证材料 3=附件ZIP，适用于成果及教师资料',
    params_json JSON NULL COMMENT '成果筛选条件或教师资料导出范围',
    snapshot_json JSON NULL COMMENT '成果ID顺序或教师ID快照，保证多个输出一致',
  status TINYINT NOT NULL DEFAULT 0 COMMENT '0=排队 1=生成中 2=成功 3=失败',
  storage_key VARCHAR(1000) NULL COMMENT '生成文件私有存储键',
  error_message VARCHAR(1000) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  finished_at DATETIME NULL,
  expires_at DATETIME NULL COMMENT '下载文件过期时间',
  PRIMARY KEY (id),
  KEY idx_export_requester_time (requester_id, created_at),
  KEY idx_export_status_time (status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='导出任务';

CREATE TABLE IF NOT EXISTS zs_audit_log (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NOT NULL COMMENT '操作人',
  action VARCHAR(32) NOT NULL COMMENT 'view/download/export/create/update/delete',
  target_type VARCHAR(32) NULL COMMENT 'achievement/attachment/teacher_profile/export_task',
  target_id BIGINT NULL,
  detail VARCHAR(2000) NULL,
  client_ip VARCHAR(64) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_audit_user_time (user_id, created_at),
  KEY idx_audit_target (target_type, target_id, created_at),
  KEY idx_audit_action_time (action, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='操作审计日志';

SET FOREIGN_KEY_CHECKS = 1;

-- 按教师查成果：负责人或参与人联查；EXISTS 防止重复成果行。
-- SELECT a.id, a.category_code, a.name, a.owner_id, a.achieved_date,
--        CASE WHEN a.owner_id = #{personId} THEN '负责人' ELSE '参与人' END AS relation_type
-- FROM zs_achievement a
-- WHERE a.deleted = 0
--   AND (a.owner_id = #{personId}
--        OR EXISTS (SELECT 1 FROM zs_achievement_member am
--                   WHERE am.achievement_id = a.id AND am.user_id = #{personId}))
--   AND (#{startDate} IS NULL OR a.achieved_date >= #{startDate})
--   AND (#{endDate} IS NULL OR a.achieved_date <= #{endDate})
-- ORDER BY a.achieved_date DESC, a.id DESC;

-- 若依角色建议：teacher=本人维护；dept_head/dean/secretary=同级全院只读查看下载；admin=全权。
-- 列表、详情、导出和附件下载必须在后端执行授权，不能只隐藏前端菜单。
