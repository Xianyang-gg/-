package com.sensitive.srams;

import java.io.IOException;
import java.nio.file.*;
import java.util.UUID;
import com.sensitive.common.exception.ServiceException;
import org.h2.jdbcx.JdbcDataSource;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.io.TempDir;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.aop.framework.ProxyFactory;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.transaction.annotation.AnnotationTransactionAttributeSource;
import org.springframework.transaction.interceptor.TransactionInterceptor;
import static org.junit.jupiter.api.Assertions.*;

class AchievementExportDeleteTest {
    @TempDir Path workspace;
    private AchievementService service;
    private AchievementExport exports;
    private AchievementFiles files;

    @BeforeEach
    void setUp() throws Exception {
        var source=new JdbcDataSource();
        source.setURL("jdbc:h2:mem:export_delete_"+UUID.randomUUID()+";MODE=MySQL;DATABASE_TO_LOWER=TRUE;DB_CLOSE_DELAY=-1");
        var access=new AchievementAccess() {
            @Override public long userId(){return 1;}
            @Override public boolean admin(){return true;}
        };
        service=new AchievementService(source,access);
        service.db.execute("CREATE TABLE zs_export_task(id BIGINT PRIMARY KEY,requester_id BIGINT,task_type INT DEFAULT 1,params_json VARCHAR(4000),snapshot_json VARCHAR(4000),status INT,storage_key VARCHAR(1000),error_message VARCHAR(1000),created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,finished_at TIMESTAMP,expires_at TIMESTAMP)");
        service.db.execute("CREATE TABLE zs_audit_log(user_id BIGINT,action VARCHAR(32),target_type VARCHAR(32),target_id BIGINT,detail VARCHAR(2000))");
        files=new AchievementFiles(service,access){@Override Path root(){return workspace;}};
        var transactions=new TransactionInterceptor();
        transactions.setTransactionManager(new DataSourceTransactionManager(source));
        transactions.setTransactionAttributeSource(new AnnotationTransactionAttributeSource());
        var proxy=new ProxyFactory(new AchievementExport(service,files));
        proxy.setProxyTargetClass(true);proxy.addAdvice(transactions);
        exports=(AchievementExport)proxy.getProxy();
        Path evidence=files.resolve("evidence/original.pdf");
        Files.createDirectories(evidence.getParent());Files.writeString(evidence,"原始附件");
    }

    @AfterEach
    void close(){exports.stop();service.db.execute("SHUTDOWN");}

    private Path task(long owner,int status,String key) throws Exception {
        service.db.update("INSERT INTO zs_export_task(id,requester_id,status,storage_key,expires_at) VALUES(10,?,?,?,'2099-01-01')",owner,status,key);
        if(key==null) return null;
        Path output=files.resolve(key);Files.createDirectories(output.getParent());Files.writeString(output,"导出文件");return output;
    }

    @ParameterizedTest
    @ValueSource(ints={2,3})
    void deletesOwnFinishedTaskAndGeneratedFile(int status) throws Exception {
        Path output=task(1,status,"exports/result.xlsx");
        exports.delete(10);
        assertTrue(exports.tasks().isEmpty());assertFalse(Files.exists(output));
        assertEquals("原始附件",Files.readString(files.resolve("evidence/original.pdf")));
        var audit=service.one("SELECT * FROM zs_audit_log");
        assertEquals("delete",audit.get("action"));assertEquals("export_task",audit.get("target_type"));
        assertEquals(1,AchievementService.number(audit.get("user_id")));
        assertEquals(10,AchievementService.number(audit.get("target_id")));
        assertEquals(404,assertThrows(ServiceException.class,()->exports.download(10)).getCode());
    }

    @Test
    void deletesExpiredTaskEvenWhenGeneratedFileIsAlreadyMissing() throws Exception {
        Path output=task(1,2,"exports/expired.zip");Files.delete(output);
        service.db.update("UPDATE zs_export_task SET expires_at='2020-01-01' WHERE id=10");
        exports.delete(10);assertTrue(exports.tasks().isEmpty());
    }

    @Test
    void deletesFailedTaskWithoutGeneratedFile() throws Exception {
        task(1,3,null);exports.delete(10);assertTrue(exports.tasks().isEmpty());
    }

    @ParameterizedTest
    @ValueSource(ints={0,1})
    void refusesUnfinishedTasks(int status) throws Exception {
        Path output=task(1,status,"exports/unfinished.xlsx");
        assertTrue(assertThrows(ServiceException.class,()->exports.delete(10)).getMessage().contains("不能删除"));
        assertTrue(Files.exists(output));assertEquals(status,((Number)service.one("SELECT * FROM zs_export_task WHERE id=10").get("status")).intValue());
        assertTrue(service.rows("SELECT * FROM zs_audit_log").isEmpty());
    }

    @ParameterizedTest
    @ValueSource(ints={2,3})
    void evenSuperAdminCannotDeleteAnotherUsersTask(int status) throws Exception {
        Path output=task(2,status,"exports/other.docx");
        assertEquals(403,assertThrows(ServiceException.class,()->exports.delete(10)).getCode());
        assertTrue(Files.exists(output));assertEquals(1,service.rows("SELECT * FROM zs_export_task").size());
        assertTrue(service.rows("SELECT * FROM zs_audit_log").isEmpty());
    }

    @Test
    void missingTaskReturnsNotFound() {
        assertEquals(404,assertThrows(ServiceException.class,()->exports.delete(999)).getCode());
    }

    @Test
    void fileDeletionFailureRollsBackTaskAndAudit() throws Exception {
        task(1,2,null);
        Path blocked=files.resolve("exports/blocked");Files.createDirectories(blocked);Files.writeString(blocked.resolve("child"),"occupied");
        service.db.update("UPDATE zs_export_task SET storage_key='exports/blocked' WHERE id=10");
        assertThrows(IOException.class,()->exports.delete(10));
        assertEquals(1,exports.tasks().size());assertTrue(Files.exists(blocked.resolve("child")));
        assertTrue(service.rows("SELECT * FROM zs_audit_log").isEmpty());
    }
}
