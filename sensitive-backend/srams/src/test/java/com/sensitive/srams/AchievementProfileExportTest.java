package com.sensitive.srams;

import java.nio.file.*;
import java.util.*;
import java.util.zip.ZipFile;
import javax.imageio.ImageIO;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.h2.jdbcx.JdbcDataSource;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import com.sensitive.common.exception.ServiceException;
import static org.junit.jupiter.api.Assertions.*;

class AchievementProfileExportTest {
    @TempDir Path workspace;

    private AchievementAccess access(boolean admin,boolean collegeRead) {
        return new AchievementAccess() {
            @Override public long userId(){return 1;}
            @Override public boolean admin(){return admin;}
            @Override public boolean collegeRead(){return collegeRead;}
        };
    }

    @Test
    void profileExportsUseExistingQueueFormatsAndReadPermissions() throws Exception {
        var source=new JdbcDataSource();
        source.setURL("jdbc:h2:mem:profile_export_"+UUID.randomUUID()+";MODE=MySQL;DATABASE_TO_LOWER=TRUE;DB_CLOSE_DELAY=-1");
        var admin=access(true,true);
        var service=new AchievementService(source,admin);
        service.db.execute("CREATE TABLE sys_user(user_id BIGINT PRIMARY KEY,nick_name VARCHAR(100),dept_id BIGINT,user_name VARCHAR(100),status VARCHAR(1),del_flag VARCHAR(1))");
        service.db.execute("CREATE TABLE sys_role(role_id BIGINT,role_key VARCHAR(50),status VARCHAR(1),del_flag VARCHAR(1))");
        service.db.execute("CREATE TABLE sys_user_role(user_id BIGINT,role_id BIGINT)");
        service.db.execute("CREATE TABLE sys_role_menu(role_id BIGINT,menu_id BIGINT)");
        service.db.execute("CREATE TABLE sys_menu(menu_id BIGINT,status VARCHAR(1),perms VARCHAR(50))");
        service.db.execute("CREATE TABLE zs_teacher_profile(user_id BIGINT PRIMARY KEY,real_name VARCHAR(100),gender INT,highest_education VARCHAR(100))");
        service.db.execute("CREATE TABLE zs_achievement(id BIGINT PRIMARY KEY,name VARCHAR(100),deleted INT)");
        service.db.execute("CREATE TABLE zs_attachment(id BIGINT PRIMARY KEY,profile_user_id BIGINT,target_type INT,original_name VARCHAR(100),storage_key VARCHAR(100),file_size BIGINT,mime_type VARCHAR(100),file_ext VARCHAR(10),deleted INT)");
        service.db.execute("CREATE TABLE zs_audit_log(user_id BIGINT,action VARCHAR(20),target_type VARCHAR(50),target_id BIGINT,detail VARCHAR(200))");
        service.db.execute("CREATE TABLE zs_export_task(id BIGINT AUTO_INCREMENT PRIMARY KEY,requester_id BIGINT,task_type INT,params_json VARCHAR(4000),snapshot_json VARCHAR(4000),status INT,storage_key VARCHAR(1000),error_message VARCHAR(1000),created_at TIMESTAMP,finished_at TIMESTAMP,expires_at TIMESTAMP)");
        service.db.update("INSERT INTO sys_user VALUES(1,'管理员',10,'admin','0','0'),(2,'教师乙',10,'teacher','0','0')");
        service.db.update("INSERT INTO zs_teacher_profile VALUES(2,'教师乙',2,'本科')");
        service.db.update("INSERT INTO zs_achievement VALUES(10,'课程项目甲',0)");
        Path original=workspace.resolve("certificate.png");
        ImageIO.write(new java.awt.image.BufferedImage(16,16,java.awt.image.BufferedImage.TYPE_INT_RGB),"png",original.toFile());
        service.db.update("INSERT INTO zs_attachment VALUES(1,2,2,'毕业证.png','certificate.png',?, 'image/png','png',0)",Files.size(original));
        var files=new AchievementFiles(service,admin){@Override Path root(){return workspace;}};
        var exports=new AchievementExport(service,files);
        try {
            for(int type=1;type<=3;type++) {
                Map<String,Object> task=exports.create(type,Map.of("scope","profile","profileUserId",2));
                long id=AchievementService.number(task.get("id"));
                String extension=switch(type){case 1->"xlsx";case 2->"docx";default->"zip";};
                String method=switch(type){case 1->"profileExcel";case 2->"profileWord";default->"profileZip";};
                Path output=workspace.resolve("profile-"+id+"."+extension);
                var writer=AchievementExport.class.getDeclaredMethod(method,Path.class,Map.class,List.class);
                writer.setAccessible(true);
                writer.invoke(exports,output,service.profile(2),service.rows("SELECT target_type,original_name,storage_key,mime_type,file_ext FROM zs_attachment WHERE profile_user_id=2"));
                service.db.update("UPDATE zs_export_task SET status=2,storage_key=?,expires_at='2099-01-01' WHERE id=?",output.getFileName().toString(),id);
                Map<String,Object> completed=exports.download(id);
                assertEquals("教师资料_"+id+"."+extension,completed.get("file_name"));
                if(type==1)try(var input=Files.newInputStream(output);var workbook=new XSSFWorkbook(input)) {
                    assertEquals("教师乙",workbook.getSheet("教师资料").getRow(1).getCell(1).getStringCellValue());
                    assertEquals("女",workbook.getSheet("教师资料").getRow(2).getCell(1).getStringCellValue());
                    assertEquals("毕业证.png",workbook.getSheet("证书清单").getRow(1).getCell(1).getStringCellValue());
                }
                if(type==2)try(var input=Files.newInputStream(output);var document=new XWPFDocument(input)) {
                    String text=String.join("\n",document.getParagraphs().stream().map(paragraph->paragraph.getText()).toList());
                    assertTrue(text.contains("姓名：教师乙"));assertTrue(text.contains("学历证：毕业证.png"));
                    assertEquals(1,document.getParagraphs().stream().flatMap(paragraph->paragraph.getRuns().stream()).mapToInt(run->run.getEmbeddedPictures().size()).sum());
                }
                if(type==3)try(var zip=new ZipFile(output.toFile())) {
                    assertNotNull(zip.getEntry("教师资料.xlsx"));assertNotNull(zip.getEntry("教师资料.docx"));
                    assertNotNull(zip.getEntry("证书/学历证_毕业证.png"));
                    assertArrayEquals(Files.readAllBytes(original),zip.getInputStream(zip.getEntry("证书/学历证_毕业证.png")).readAllBytes());
                }
            }
            assertEquals("教师资料 · 教师乙",exports.tasks().get(0).get("content_type"));
            var privateAccess=access(false,false);
            var privateExports=new AchievementExport(new AchievementService(source,privateAccess),files);
            try {
                assertEquals(403,assertThrows(ServiceException.class,()->privateExports.create(1,Map.of("scope","profile","profileUserId",2))).getCode());
                assertEquals(403,assertThrows(ServiceException.class,()->privateExports.download(AchievementService.number(exports.tasks().get(0).get("id")))).getCode());
            } finally {privateExports.stop();}
            var collegeExports=new AchievementExport(new AchievementService(source,access(false,true)),files);
            try {assertEquals(0,collegeExports.create(1,Map.of("scope","profile","profileUserId",2)).get("status"));}
            finally {collegeExports.stop();}
            service.db.update("INSERT INTO zs_export_task(id,requester_id,task_type,params_json,snapshot_json,status) VALUES(100,1,2,'{\"scope\":\"summary\"}','[10,11]',2)");
            service.db.update("INSERT INTO zs_export_task(id,requester_id,task_type,params_json,snapshot_json,status) VALUES(101,1,2,'{\"categoryCode\":\"course\"}','[10]',2)");
            service.db.update("INSERT INTO zs_export_task(id,requester_id,task_type,params_json,snapshot_json,status) VALUES(102,1,2,'{\"scope\":\"profile\"}','[2]',2)");
            var history=exports.tasks();
            assertEquals("教师资料 · 教师乙",history.get(0).get("content_type"));
            assertEquals("课程 · 课程项目甲",history.get(1).get("content_type"));
            assertEquals("成果总览 · 课程项目甲 等 2 条",history.get(2).get("content_type"));
        } finally {exports.stop();}
    }
}
