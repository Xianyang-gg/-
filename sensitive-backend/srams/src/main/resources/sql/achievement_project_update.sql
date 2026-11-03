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
