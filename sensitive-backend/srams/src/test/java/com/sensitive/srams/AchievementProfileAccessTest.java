package com.sensitive.srams;

import java.util.Map;
import org.h2.jdbcx.JdbcDataSource;
import org.junit.jupiter.api.Test;
import com.sensitive.common.exception.ServiceException;
import static org.junit.jupiter.api.Assertions.*;

class AchievementProfileAccessTest {
    private AchievementAccess access(long userId,boolean admin,boolean collegeRead) {
        return new AchievementAccess() {
            @Override public long userId(){return userId;}
            @Override public boolean admin(){return admin;}
            @Override public boolean collegeRead(){return collegeRead;}
        };
    }

    @Test
    void collegeReadersCanViewOthersButOnlyEditTheirOwnProfile() {
        var source=new JdbcDataSource();
        source.setURL("jdbc:h2:mem:achievement_profile_access;MODE=MySQL;DATABASE_TO_LOWER=TRUE;DB_CLOSE_DELAY=-1");
        var college=access(1,false,true);
        var service=new AchievementService(source,college);
        service.db.execute("CREATE TABLE sys_user(user_id BIGINT PRIMARY KEY,nick_name VARCHAR(100),dept_id BIGINT,del_flag VARCHAR(1))");
        service.db.execute("CREATE TABLE zs_teacher_profile(user_id BIGINT PRIMARY KEY)");
        service.db.execute("CREATE TABLE zs_attachment(id BIGINT,profile_user_id BIGINT,target_type INT,original_name VARCHAR(100),file_size BIGINT,mime_type VARCHAR(100),file_ext VARCHAR(10),deleted INT)");
        service.db.execute("CREATE TABLE zs_audit_log(user_id BIGINT,action VARCHAR(20),target_type VARCHAR(50),target_id BIGINT,detail VARCHAR(200))");
        service.db.update("INSERT INTO sys_user VALUES(1,'本人',10,'0'),(2,'其他教师',10,'0')");

        assertEquals(false,service.profile(2).get("can_edit"));
        assertEquals(true,service.profile(1).get("can_edit"));
        ServiceException denied=assertThrows(ServiceException.class,()->service.saveProfile(2,Map.of("real_name","越权修改")));
        assertEquals(403,denied.getCode());
        assertDoesNotThrow(()->college.requireProfileEdit(1));

        var admin=access(1,true,true);
        assertEquals(true,new AchievementService(source,admin).profile(2).get("can_edit"));
        assertDoesNotThrow(()->admin.requireProfileEdit(2));
    }
}
