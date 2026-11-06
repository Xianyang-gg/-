-- 数据大屏目录（路由 ping）及学院、个人两个大屏；可重复执行。
-- 已在菜单管理中建好 path='ping' 的顶级目录时直接复用，不改动该目录。
SET NAMES utf8mb4;
START TRANSACTION;

INSERT INTO sys_menu(menu_name,parent_id,order_num,path,component,route_name,is_frame,is_cache,menu_type,visible,status,perms,icon,create_by,create_time)
SELECT '数据大屏',0,0,'ping','Layout','SramsDashboard',1,1,'M','0','0','','dashboard','admin',NOW()
WHERE NOT EXISTS(SELECT 1 FROM sys_menu WHERE parent_id=0 AND path='ping');
SET @dashboard_dir=(SELECT MIN(menu_id) FROM sys_menu WHERE parent_id=0 AND path='ping');

CREATE TEMPORARY TABLE srams_dashboard_pages (path VARCHAR(32), menu_name VARCHAR(64), component VARCHAR(128), route_name VARCHAR(64), perms VARCHAR(100), icon VARCHAR(64), order_num INT);
INSERT INTO srams_dashboard_pages VALUES
('college','学院数据大屏','srams/dashboard/college','SramsDashboardCollege','achievement:dashboard:college','chart',1),
('personal','个人数据大屏','srams/dashboard/personal','SramsDashboardPersonal','achievement:dashboard:personal','user',2);
INSERT INTO sys_menu(menu_name,parent_id,order_num,path,component,route_name,is_frame,is_cache,menu_type,visible,status,perms,icon,create_by,create_time)
SELECT p.menu_name,@dashboard_dir,p.order_num,p.path,p.component,p.route_name,1,1,'C','0','0',p.perms,p.icon,'admin',NOW()
FROM srams_dashboard_pages p WHERE NOT EXISTS(SELECT 1 FROM sys_menu m WHERE m.parent_id=@dashboard_dir AND m.path=p.path);
-- 同步本模块定义的组件和权限标识，确保重复运行得到同一套路由。
UPDATE sys_menu m JOIN srams_dashboard_pages p ON m.parent_id=@dashboard_dir AND m.path=p.path
SET m.menu_name=p.menu_name,m.component=p.component,m.route_name=p.route_name,m.perms=p.perms,m.menu_type='C',m.status='0',m.visible='0';

-- 目录和个人页：图3的五个角色及教师；学院页：只授予图3的五个角色。教师需要目录授权，个人页才能挂到菜单树上。
CREATE TEMPORARY TABLE srams_dashboard_grants (role_key VARCHAR(100), path VARCHAR(32));
INSERT INTO srams_dashboard_grants VALUES
('admin',''),('admin1',''),('dept_head',''),('dean',''),('secretary',''),('teacher',''),
('admin','college'),('admin1','college'),('dept_head','college'),('dean','college'),('secretary','college'),
('admin','personal'),('admin1','personal'),('dept_head','personal'),('dean','personal'),('secretary','personal'),('teacher','personal');
INSERT INTO sys_role_menu(role_id,menu_id)
SELECT DISTINCT r.role_id,m.menu_id FROM srams_dashboard_grants g
JOIN sys_role r ON r.role_key=g.role_key AND r.del_flag='0'
JOIN sys_menu m ON (g.path='' AND m.menu_id=@dashboard_dir) OR (g.path<>'' AND m.parent_id=@dashboard_dir AND m.path=g.path)
WHERE NOT EXISTS(SELECT 1 FROM sys_role_menu existing WHERE existing.role_id=r.role_id AND existing.menu_id=m.menu_id);

DROP TEMPORARY TABLE srams_dashboard_grants;
DROP TEMPORARY TABLE srams_dashboard_pages;
COMMIT;
