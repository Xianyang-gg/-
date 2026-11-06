package com.sensitive.srams;

import java.util.*;
import java.util.stream.Stream;
import com.sensitive.common.exception.ServiceException;
import org.h2.jdbcx.JdbcDataSource;
import org.junit.jupiter.api.*;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;
import org.springframework.aop.framework.ProxyFactory;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.transaction.annotation.AnnotationTransactionAttributeSource;
import org.springframework.transaction.interceptor.TransactionInterceptor;
import static org.junit.jupiter.api.Assertions.*;

class AchievementDeleteTest {
    private AchievementService service;
    private boolean admin;

    @BeforeEach
    void setUp() {
        var source=new JdbcDataSource();
        source.setURL("jdbc:h2:mem:achievement_delete_"+UUID.randomUUID()+";MODE=MySQL;DATABASE_TO_LOWER=TRUE;DB_CLOSE_DELAY=-1");
        var access=new AchievementAccess() {
            @Override public long userId(){return 1;}
            @Override public boolean admin(){return admin;}
            @Override public boolean teacher(){return true;}
            @Override public boolean collegeRead(){return true;}
        };
        var transactions=new TransactionInterceptor();
        transactions.setTransactionManager(new DataSourceTransactionManager(source));
        transactions.setTransactionAttributeSource(new AnnotationTransactionAttributeSource());
        var proxy=new ProxyFactory(new AchievementService(source,access));
        proxy.setProxyTargetClass(true);proxy.addAdvice(transactions);
        service=(AchievementService)proxy.getProxy();
        var db=service.getJdbcTemplate();
        db.execute("CREATE TABLE sys_user(user_id BIGINT PRIMARY KEY,nick_name VARCHAR(100))");
        db.execute("CREATE TABLE sys_dept(dept_id BIGINT PRIMARY KEY,dept_name VARCHAR(100))");
        db.execute("CREATE TABLE zs_achievement(id BIGINT PRIMARY KEY,category_code VARCHAR(32),name VARCHAR(255),owner_id BIGINT,created_by BIGINT,major_dept_id BIGINT,deleted INT DEFAULT 0)");
        for(String table:List.of("zs_achievement_member","zs_achievement_sort","zs_attachment"))
            db.execute("CREATE TABLE "+table+"(id BIGINT PRIMARY KEY,achievement_id BIGINT REFERENCES zs_achievement(id),deleted INT DEFAULT 0)");
        for(String table:AchievementCatalog.ALL.stream().map(AchievementCatalog.Category::table).distinct().toList())
            db.execute("CREATE TABLE "+table+"(achievement_id BIGINT PRIMARY KEY REFERENCES zs_achievement(id))");
        db.execute("CREATE TABLE zs_audit_log(user_id BIGINT,action VARCHAR(32),target_type VARCHAR(32),target_id BIGINT,detail VARCHAR(2000))");
    }

    @AfterEach
    void close(){service.getJdbcTemplate().execute("SHUTDOWN");}

    static Stream<AchievementCatalog.Category> categories(){return AchievementCatalog.ALL.stream();}

    private void record(long id,String category,long owner,long creator) {
        var db=service.getJdbcTemplate();
        db.update("INSERT INTO zs_achievement(id,category_code,name,owner_id,created_by) VALUES(?,?,?,?,?)",id,category,"成果"+id,owner,creator);
        db.update("INSERT INTO "+AchievementCatalog.get(category).table()+" VALUES(?)",id);
        for(String table:List.of("zs_achievement_member","zs_achievement_sort","zs_attachment"))
            db.update("INSERT INTO "+table+"(id,achievement_id) VALUES(?,?)",id,id);
        // 已逻辑删除的附件和其他用户保存的排序也必须一并清除。
        db.update("INSERT INTO zs_attachment VALUES(?,?,1)",id+100,id);
        db.update("INSERT INTO zs_achievement_sort(id,achievement_id) VALUES(?,?)",id+100,id);
    }

    private void assertRecord(long id,String category,boolean exists) {
        assertEquals(exists,!service.rows("SELECT id FROM zs_achievement WHERE id=?",id).isEmpty());
        for(String table:List.of(AchievementCatalog.get(category).table(),"zs_achievement_member","zs_achievement_sort","zs_attachment"))
            assertEquals(exists,!service.rows("SELECT achievement_id FROM "+table+" WHERE achievement_id=?",id).isEmpty(),table);
    }

    @ParameterizedTest
    @MethodSource("categories")
    void physicallyDeletesEveryCategoryAndItsRelations(AchievementCatalog.Category category) {
        record(1,category.code(),1,1);record(2,category.code(),2,2);
        service.delete(List.of(1L));
        assertRecord(1,category.code(),false);assertRecord(2,category.code(),true);
        assertEquals(404,assertThrows(ServiceException.class,()->service.readable(1)).getCode());
        var audit=service.one("SELECT * FROM zs_audit_log");
        assertEquals("delete",audit.get("action"));assertEquals("achievement",audit.get("target_type"));
        assertEquals(1,AchievementService.number(audit.get("target_id")));assertEquals("成果1",audit.get("detail"));
    }

    @Test
    void forbiddenRecordPreventsEntireBatchDeletion() {
        record(1,"course",1,1);record(2,"paper",2,2);
        assertEquals(403,assertThrows(ServiceException.class,()->service.delete(List.of(1L,2L))).getCode());
        assertRecord(1,"course",true);assertRecord(2,"paper",true);
        assertTrue(service.rows("SELECT * FROM zs_audit_log").isEmpty());
    }

    @Test
    void teacherCannotDeleteRecordCreatedBySomeoneElse() {
        record(1,"course",1,2);
        assertEquals(403,assertThrows(ServiceException.class,()->service.delete(List.of(1L))).getCode());
        assertRecord(1,"course",true);
    }

    @Test
    void administratorCanDeleteAnotherTeachersRecord() {
        admin=true;record(1,"course",2,2);
        service.delete(List.of(1L));assertRecord(1,"course",false);
    }

    @Test
    void mixedCategoryBatchDeletesEachRecordOnce() {
        record(1,"course",1,1);record(2,"paper",1,1);
        service.delete(List.of(2L,1L,1L));
        assertRecord(1,"course",false);assertRecord(2,"paper",false);
        assertEquals(2,service.rows("SELECT * FROM zs_audit_log").size());
    }

    @Test
    void missingRecordPreventsEntireBatchDeletion() {
        record(1,"course",1,1);
        assertEquals(404,assertThrows(ServiceException.class,()->service.delete(List.of(1L,999L))).getCode());
        assertRecord(1,"course",true);
    }

    @Test
    void failureRollsBackDeletedRowsAndAuditForWholeBatch() {
        record(1,"course",1,1);record(2,"paper",1,1);
        service.getJdbcTemplate().execute("ALTER TABLE zs_audit_log ADD CHECK (target_id<>2)");
        assertThrows(DataAccessException.class,()->service.delete(List.of(1L,2L)));
        assertRecord(1,"course",true);assertRecord(2,"paper",true);
        assertTrue(service.rows("SELECT * FROM zs_audit_log").isEmpty());
    }

    @Test
    void emptySelectionIsRejected() {
        assertThrows(ServiceException.class,()->service.delete(List.of()));
    }
}
