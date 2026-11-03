package com.sensitive.srams;

import java.util.Map;
import java.util.Set;
import com.sensitive.common.core.domain.entity.SysRole;
import com.sensitive.common.exception.ServiceException;
import com.sensitive.common.utils.SecurityUtils;
import org.springframework.stereotype.Component;

/** 业务数据范围独立于菜单权限；参与人只读，不获得编辑权。 */
@Component
public class AchievementAccess {
    public long userId() { return SecurityUtils.getUserId(); }
    public boolean admin() {
        return SecurityUtils.isAdmin() || SecurityUtils.getLoginUser().getUser().getRoles().stream()
            .anyMatch(r -> "admin".equals(r.getRoleKey()) && "0".equals(r.getStatus()));
    }
    public boolean collegeRead() {
        return admin() || SecurityUtils.getLoginUser().getUser().getRoles().stream()
            .filter(r -> "0".equals(r.getStatus())).map(SysRole::getRoleKey)
            .anyMatch(k -> Set.of("dept_head","dean","secretary").contains(k));
    }
    public boolean teacher() {
        return SecurityUtils.getLoginUser().getUser().getRoles().stream()
            .anyMatch(r -> "teacher".equals(r.getRoleKey()) && "0".equals(r.getStatus()));
    }
    public boolean canCreate() {
        return admin() || teacher();
    }
    public void requireCreate() {
        if (!canCreate()) throw new ServiceException("只有教师或超级管理员可以录入成果",403);
    }
    public boolean canEdit(Map<String,Object> row) {
        return admin() || (teacher() && same(row.get("owner_id")) && same(row.get("created_by")));
    }
    public void requireEdit(Map<String,Object> row) {
        if (!canEdit(row)) throw new ServiceException("只能修改或删除本人录入且本人负责的成果",403);
    }
    public void requireProfileRead(long id) {
        if (!collegeRead() && id != userId()) throw new ServiceException("无权查看该教师资料",403);
    }
    public void requireProfileEdit(long id) {
        if (!admin() && id != userId()) throw new ServiceException("只能修改自己的教师资料",403);
    }
    private boolean same(Object value) { return value != null && Long.parseLong(value.toString()) == userId(); }
}
