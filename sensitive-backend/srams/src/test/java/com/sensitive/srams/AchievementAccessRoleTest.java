package com.sensitive.srams;

import java.util.*;
import org.junit.jupiter.api.*;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import com.sensitive.common.core.domain.entity.SysRole;
import com.sensitive.common.core.domain.entity.SysUser;
import com.sensitive.common.core.domain.model.LoginUser;
import static org.junit.jupiter.api.Assertions.*;

/** 按真实登录角色验证成果权限口径；用户ID不为1，避免走超级管理员账号判断。 */
class AchievementAccessRoleTest {
    private final AchievementAccess access=new AchievementAccess();
    private final Map<String,Object> others=Map.of("owner_id",99L,"created_by",99L);

    private void login(long id,String roleKey,String status) {
        SysUser user=new SysUser(id);
        SysRole role=new SysRole();role.setRoleKey(roleKey);role.setStatus(status);
        user.setRoles(List.of(role));
        var context=SecurityContextHolder.createEmptyContext();
        context.setAuthentication(new UsernamePasswordAuthenticationToken(new LoginUser(id,10L,user,Set.of()),null,List.of()));
        SecurityContextHolder.setContext(context);
    }

    @AfterEach void clear() { SecurityContextHolder.clearContext(); }

    @Test
    void admin1HasTheSameRightsAsSuperAdmin() {
        for(String key:List.of("admin","admin1")) {
            login(5,key,"0");
            assertTrue(access.admin(),key);
            assertTrue(access.collegeRead(),key);
            assertTrue(access.canCreate(),key);
            assertTrue(access.canEdit(others),key);
            assertDoesNotThrow(()->access.requireProfileEdit(99),key);
        }
    }

    @Test
    void disabledAdmin1RoleGrantsNothing() {
        login(5,"admin1","1");
        assertFalse(access.admin());
        assertFalse(access.collegeRead());
        assertFalse(access.canEdit(others));
    }

    @Test
    void collegeRolesReadOnlyAndTeacherOwnOnly() {
        for(String key:List.of("dept_head","dean","secretary")) {
            login(5,key,"0");
            assertFalse(access.admin(),key);
            assertTrue(access.collegeRead(),key);
            assertFalse(access.canCreate(),key);
            assertFalse(access.canEdit(others),key);
        }
        login(5,"teacher","0");
        assertFalse(access.admin());
        assertFalse(access.collegeRead());
        assertFalse(access.canEdit(others));
        assertTrue(access.canEdit(Map.of("owner_id",5L,"created_by",5L)));
    }
}
