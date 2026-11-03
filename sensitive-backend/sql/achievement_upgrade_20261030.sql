-- 本次改造增量升级脚本：六个主菜单、十五个子功能及两项独立经费。
-- 在已导入业务表的数据库执行；可重复运行，不删除成果或附件。

-- 已建库增量更新：新增两个独立经费字段，不迁移原单项经费。
-- 原日期列保留，应用显示为立项时间/结项时间。
SET NAMES utf8mb4;
SET @srams_ddl=IF(EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='zs_detail_project_major' AND column_name='contract_wan'),'SELECT 1',"ALTER TABLE zs_detail_project_major ADD COLUMN contract_wan DECIMAL(14,2) NULL COMMENT '合同经费，万元'");
PREPARE srams_stmt FROM @srams_ddl;
EXECUTE srams_stmt;
DEALLOCATE PREPARE srams_stmt;
SET @srams_ddl=IF(EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='zs_detail_project_major' AND column_name='received_wan'),'SELECT 1',"ALTER TABLE zs_detail_project_major ADD COLUMN received_wan DECIMAL(14,2) NULL COMMENT '到账经费，万元'");
PREPARE srams_stmt FROM @srams_ddl;
EXECUTE srams_stmt;
DEALLOCATE PREPARE srams_stmt;
SET @srams_ddl=IF(EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='zs_detail_project_research' AND column_name='contract_wan'),'SELECT 1',"ALTER TABLE zs_detail_project_research ADD COLUMN contract_wan DECIMAL(14,2) NULL COMMENT '合同经费，万元'");
PREPARE srams_stmt FROM @srams_ddl;
EXECUTE srams_stmt;
DEALLOCATE PREPARE srams_stmt;
SET @srams_ddl=IF(EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='zs_detail_project_research' AND column_name='received_wan'),'SELECT 1',"ALTER TABLE zs_detail_project_research ADD COLUMN received_wan DECIMAL(14,2) NULL COMMENT '到账经费，万元'");
PREPARE srams_stmt FROM @srams_ddl;
EXECUTE srams_stmt;
DEALLOCATE PREPARE srams_stmt;
SET @srams_ddl=IF(EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='zs_detail_project_student' AND column_name='contract_wan'),'SELECT 1',"ALTER TABLE zs_detail_project_student ADD COLUMN contract_wan DECIMAL(14,2) NULL COMMENT '合同经费，万元'");
PREPARE srams_stmt FROM @srams_ddl;
EXECUTE srams_stmt;
DEALLOCATE PREPARE srams_stmt;
SET @srams_ddl=IF(EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='zs_detail_project_student' AND column_name='received_wan'),'SELECT 1',"ALTER TABLE zs_detail_project_student ADD COLUMN received_wan DECIMAL(14,2) NULL COMMENT '到账经费，万元'");
PREPARE srams_stmt FROM @srams_ddl;
EXECUTE srams_stmt;
DEALLOCATE PREPARE srams_stmt;

-- 以已有立项日期同步项目的查询和排序时间，重复运行不改变一致的数据。
UPDATE zs_achievement a JOIN zs_detail_project_major d ON d.achievement_id=a.id SET a.achieved_date=d.apply_date WHERE a.category_code='project_major' AND d.apply_date IS NOT NULL AND a.achieved_date<>d.apply_date;
UPDATE zs_achievement a JOIN zs_detail_project_research d ON d.achievement_id=a.id SET a.achieved_date=d.apply_date WHERE a.category_code='project_research' AND d.apply_date IS NOT NULL AND a.achieved_date<>d.apply_date;
UPDATE zs_achievement a JOIN zs_detail_project_horizontal d ON d.achievement_id=a.id SET a.achieved_date=d.start_date WHERE a.category_code='project_horizontal' AND d.start_date IS NOT NULL AND a.achieved_date<>d.start_date;
UPDATE zs_achievement a JOIN zs_detail_project_student d ON d.achievement_id=a.id SET a.achieved_date=d.grant_date WHERE a.category_code='project_student' AND d.grant_date IS NOT NULL AND a.achieved_date<>d.grant_date;

-- 六个业务主菜单及十五个子功能；可重复执行，保留业务数据与现有用户角色。
SET NAMES utf8mb4;
START TRANSACTION;

INSERT INTO sys_role(role_name,role_key,role_sort,data_scope,status,del_flag,create_by,create_time,remark)
SELECT '教师','teacher',10,'5','0','0','admin',NOW(),'维护本人录入且本人负责的成果；本人参与成果只读'
WHERE NOT EXISTS(SELECT 1 FROM sys_role WHERE role_key='teacher' AND del_flag='0');
INSERT INTO sys_role(role_name,role_key,role_sort,data_scope,status,del_flag,create_by,create_time,remark)
SELECT '专业主任','dept_head',11,'1','0','0','admin',NOW(),'与院长、书记同级，全院信息只读查看下载'
WHERE NOT EXISTS(SELECT 1 FROM sys_role WHERE role_key='dept_head' AND del_flag='0');
INSERT INTO sys_role(role_name,role_key,role_sort,data_scope,status,del_flag,create_by,create_time,remark)
SELECT '院长','dean',11,'1','0','0','admin',NOW(),'全院信息只读查看下载'
WHERE NOT EXISTS(SELECT 1 FROM sys_role WHERE role_key='dean' AND del_flag='0');
INSERT INTO sys_role(role_name,role_key,role_sort,data_scope,status,del_flag,create_by,create_time,remark)
SELECT '书记','secretary',11,'1','0','0','admin',NOW(),'全院信息只读查看下载'
WHERE NOT EXISTS(SELECT 1 FROM sys_role WHERE role_key='secretary' AND del_flag='0');

CREATE TEMPORARY TABLE srams_menu_groups (module_key VARCHAR(32), menu_name VARCHAR(64), route_name VARCHAR(64), icon VARCHAR(64), order_num INT);
INSERT INTO srams_menu_groups VALUES
('project','项目','SramsProject','documentation',-6),
('award','获奖','SramsAward','star',-5),
('teaching','教材和课程','SramsTeaching','education',-4),
('research','论文和专利','SramsResearch','documentation',-3),
('cooperation','交流合作','SramsCooperation','peoples',-2),
('media','媒体报道','SramsMedia','message',-1);
INSERT INTO sys_menu(menu_name,parent_id,order_num,path,component,route_name,is_frame,is_cache,menu_type,visible,status,perms,icon,create_by,create_time)
SELECT g.menu_name,0,g.order_num,CONCAT('srams-',g.module_key),'Layout',g.route_name,1,1,'M','0','0','',g.icon,'admin',NOW()
FROM srams_menu_groups g WHERE NOT EXISTS(SELECT 1 FROM sys_menu m WHERE m.parent_id=0 AND m.path=CONCAT('srams-',g.module_key));
CREATE TEMPORARY TABLE srams_menu_pages (module_key VARCHAR(32), page_key VARCHAR(32), menu_name VARCHAR(64), route_name VARCHAR(64), order_num INT);
INSERT INTO srams_menu_pages VALUES
('project','major','按专业申报的项目','SramsProjectMajor',1),
('project','research','教科研项目','SramsProjectResearch',2),
('project','horizontal','横向项目','SramsProjectHorizontal',3),
('project','student','指导学生项目','SramsProjectStudent',4),
('award','teacher','教师获奖及荣誉称号','SramsAwardTeacher',1),
('award','student','指导学生获奖','SramsAwardStudent',2),
('teaching','course','课程','SramsCourse',1),
('teaching','textbook','教材','SramsTextbook',2),
('research','paper','论文','SramsPaper',1),
('research','patent','专利及软件著作权','SramsPatent',2),
('research','transfer','专利转让','SramsPatentTransfer',3),
('cooperation','visit','接待参观与企业洽谈','SramsVisit',1),
('cooperation','hosted','举办技术交流和公开培训','SramsHostedTraining',2),
('cooperation','study','参加培训进修','SramsStudyTraining',3),
('media','report','媒体报道管理','SramsMediaReport',1);
INSERT INTO sys_menu(menu_name,parent_id,order_num,path,component,route_name,is_frame,is_cache,menu_type,visible,status,perms,icon,create_by,create_time)
SELECT p.menu_name,g.menu_id,p.order_num,p.page_key,CONCAT('srams/',p.module_key,'/',p.page_key),p.route_name,1,1,'C','0','0','achievement:list','documentation','admin',NOW()
FROM srams_menu_pages p JOIN sys_menu g ON g.parent_id=0 AND g.path=CONCAT('srams-',p.module_key)
WHERE NOT EXISTS(SELECT 1 FROM sys_menu m WHERE m.parent_id=g.menu_id AND m.path=p.page_key);
-- 同步本模块定义的名称和组件，确保重复运行也得到同一套路由。
UPDATE sys_menu m JOIN srams_menu_groups g ON m.parent_id=0 AND m.path=CONCAT('srams-',g.module_key)
SET m.menu_name=g.menu_name,m.route_name=g.route_name,m.order_num=g.order_num,m.component='Layout',m.menu_type='M',m.status='0',m.visible='0';
UPDATE sys_menu m JOIN sys_menu g ON g.menu_id=m.parent_id
JOIN srams_menu_pages p ON g.path=CONCAT('srams-',p.module_key) AND m.path=p.page_key
SET m.menu_name=p.menu_name,m.route_name=p.route_name,m.component=CONCAT('srams/',p.module_key,'/',p.page_key),m.order_num=p.order_num,m.perms='achievement:list',m.status='0',m.visible='0';
CREATE TEMPORARY TABLE srams_menu_roles (role_id BIGINT PRIMARY KEY);
INSERT IGNORE INTO srams_menu_roles
SELECT role_id FROM sys_role WHERE del_flag='0' AND role_key IN('admin','teacher','dept_head','dean','secretary');
-- 继承原成果菜单已授权的角色，保留原有接入人员。
INSERT IGNORE INTO srams_menu_roles
SELECT rm.role_id FROM sys_role_menu rm JOIN sys_menu m ON m.menu_id=rm.menu_id WHERE m.component='srams/index' AND m.perms='achievement:list';
INSERT INTO sys_role_menu(role_id,menu_id)
SELECT r.role_id,m.menu_id FROM srams_menu_roles r CROSS JOIN sys_menu m
WHERE (EXISTS(SELECT 1 FROM srams_menu_groups g WHERE m.parent_id=0 AND m.path=CONCAT('srams-',g.module_key))
OR EXISTS(SELECT 1 FROM sys_menu parent JOIN srams_menu_pages p ON parent.path=CONCAT('srams-',p.module_key) AND m.path=p.page_key WHERE m.parent_id=parent.menu_id AND parent.parent_id=0))
AND NOT EXISTS(SELECT 1 FROM sys_role_menu existing WHERE existing.role_id=r.role_id AND existing.menu_id=m.menu_id);
UPDATE sys_menu old_page JOIN sys_menu old_parent ON old_parent.menu_id=old_page.parent_id
SET old_page.status='1',old_page.visible='1'
WHERE old_parent.parent_id=0 AND old_parent.path='achievement' AND old_page.component='srams/index';
UPDATE sys_menu SET status='1',visible='1' WHERE parent_id=0 AND path='achievement' AND menu_name='业绩成果';
DROP TEMPORARY TABLE srams_menu_roles;
DROP TEMPORARY TABLE srams_menu_pages;
DROP TEMPORARY TABLE srams_menu_groups;
COMMIT;
