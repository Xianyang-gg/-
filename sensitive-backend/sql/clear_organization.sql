-- 清空组织机构数据
-- 目标库参考 sensitive-admin/src/main/resources/application-druid.yml: jdbc:mysql://localhost:3306/cool
-- 执行前建议先备份数据库。

START TRANSACTION;

DELETE FROM sys_role_dept;
DELETE FROM sys_dept;
INSERT INTO sys_dept (dept_id, parent_id, ancestors, dept_name, order_num, leader, phone, email, status, del_flag, create_by, create_time, update_by, update_time)
VALUES (100, 0, '0', '超级管理', 0, 'admin', '15888888888', 'ry@163.com', '0', '0', 'admin', SYSDATE(), '', NULL);
UPDATE sys_user SET dept_id = 100;

COMMIT;

SELECT COUNT(*) AS dept_count FROM sys_dept;
SELECT COUNT(*) AS role_dept_count FROM sys_role_dept;
SELECT COUNT(*) AS users_with_dept_count FROM sys_user WHERE dept_id IS NOT NULL;
