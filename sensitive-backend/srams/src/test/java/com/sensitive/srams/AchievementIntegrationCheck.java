package com.sensitive.srams;

import java.io.*;
import java.nio.file.*;
import java.sql.Connection;
import java.util.*;
import java.util.zip.ZipFile;
import com.sensitive.common.config.SensitiveConfig;
import com.sensitive.common.core.domain.entity.*;
import com.sensitive.common.core.domain.model.LoginUser;
import com.sensitive.common.exception.ServiceException;
import org.springframework.jdbc.datasource.SingleConnectionDataSource;
import org.springframework.aop.framework.ProxyFactory;
import org.aopalliance.intercept.MethodInterceptor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.multipart.MultipartFile;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.xwpf.usermodel.XWPFDocument;

/** 独立的集成检查：所有数据库数据均处于同一个最终回滚的事务内。 */
public class AchievementIntegrationCheck {
    private static int checks;
    static void check(boolean ok,String message){if(!ok)throw new AssertionError(message);checks++;}
    static void denied(Runnable action){try{action.run();throw new AssertionError("Expected authorization denial");}catch(ServiceException ex){check(Integer.valueOf(403).equals(ex.getCode()),"Expected 403");}}
    static void login(long id,long dept,String role){SysRole r=new SysRole();r.setRoleKey(role);r.setStatus("0");SysUser user=new SysUser(id);user.setUserName("check");user.setNickName("Check");user.setDeptId(dept);user.setRoles(List.of(r));LoginUser principal=new LoginUser(id,dept,user,Set.of());SecurityContextHolder.getContext().setAuthentication(new UsernamePasswordAuthenticationToken(principal,null,List.of()));}
    static Map<String,Object> completed(AchievementExport exports,int type,Map<String,Object> params) throws Exception {
        Map<String,Object> task=exports.create(type,params);long id=AchievementService.number(task.get("id"));
        check(((Number)task.get("status")).intValue()==0,"Submission returns queued task");
        exports.processTask(id);
        Map<String,Object> state=exports.tasks().stream().filter(t->AchievementService.number(t.get("id"))==id).findFirst().orElseThrow();
        if(((Number)state.get("status")).intValue()!=2)throw new ServiceException(String.valueOf(state.get("error_message")));
        return task;
    }
    public static void main(String[] args) throws Exception {
        Properties properties=new Properties();
        try(InputStream input=Files.newInputStream(Path.of(args[0]))){properties.load(input);}
        String config=Files.readString(Path.of(args[1]));
        String url=find(config,"url"),username=find(config,"username"),password=find(config,"password");
        Path workspace=Path.of(properties.getProperty("workspace")).toAbsolutePath();Files.createDirectories(workspace);
        new SensitiveConfig().setProfile(workspace.resolve("public").toString());
        try(Connection connection=java.sql.DriverManager.getConnection(url,username,password)) {
            connection.setAutoCommit(false);
            try {
                AchievementAccess access=new AchievementAccess();ProxyFactory proxy=new ProxyFactory(new AchievementService(new SingleConnectionDataSource(connection,true),access));
                proxy.setProxyTargetClass(true);proxy.addAdvice((MethodInterceptor)invocation->invocation.proceed());AchievementService service=(AchievementService)proxy.getProxy();
                check(service.getAccess()==access && service.getJdbcTemplate()!=null,"Dependencies available through Spring proxy");
                long dept=AchievementService.number(service.one("SELECT dept_id FROM sys_dept WHERE del_flag='0' LIMIT 1").get("dept_id"));
                long owner=service.insert("INSERT INTO sys_user(dept_id,user_name,nick_name,status,del_flag) VALUES(?,?,?,'0','0')",dept,"check_o_"+UUID.randomUUID().toString().substring(0,8),"集成检查负责人");
                long participant=service.insert("INSERT INTO sys_user(dept_id,user_name,nick_name,status,del_flag) VALUES(?,?,?,'0','0')",dept,"check_m_"+UUID.randomUUID().toString().substring(0,8),"集成检查参与人");
                long other=service.insert("INSERT INTO sys_user(dept_id,user_name,nick_name,status,del_flag) VALUES(?,?,?,'0','0')",dept,"check_x_"+UUID.randomUUID().toString().substring(0,8),"集成检查无关人员");
                long adminUser=service.insert("INSERT INTO sys_user(dept_id,user_name,nick_name,status,del_flag) VALUES(?,?,?,'0','0')",dept,"check_a_"+UUID.randomUUID().toString().substring(0,8),"集成检查管理员");
                long teacherRole=service.insert("INSERT INTO sys_role(role_name,role_key,role_sort,status,del_flag) VALUES(?,'teacher',999,'0','0')","check_"+UUID.randomUUID().toString().substring(0,8));
                long adminRole=service.insert("INSERT INTO sys_role(role_name,role_key,role_sort,status,del_flag) VALUES(?,'admin',999,'0','0')","check_"+UUID.randomUUID().toString().substring(0,8));
                long menu=service.insert("INSERT INTO sys_menu(menu_name,menu_type,status,perms) VALUES(?,'F','0','achievement:list')","导出集成检查");
                service.getJdbcTemplate().update("INSERT INTO sys_role_menu(role_id,menu_id) VALUES(?,?)",teacherRole,menu);
                for(long uid:List.of(owner,participant,other))service.getJdbcTemplate().update("INSERT INTO sys_user_role(user_id,role_id) VALUES(?,?)",uid,teacherRole);
                service.getJdbcTemplate().update("INSERT INTO sys_user_role(user_id,role_id) VALUES(?,?)",adminUser,adminRole);
                login(owner,dept,"teacher");Map<String,Object> body=new LinkedHashMap<>();body.put("category_code","course");body.put("name","集成检查_课程");body.put("owner_id",owner);body.put("achieved_date","2026-10-30");body.put("detail",Map.of("project_name","课程项目","start_date","2026-01-01","finish_date","2026-10-30"));body.put("members",List.of(Map.of("user_id",participant,"member_role","participant"),Map.of("user_id",participant,"member_role","supervisor")));
                long id=service.save(body,null);
                check(service.detail(id).get("name").equals(body.get("name")),"Saved achievement");
                check(!service.departmentTree().isEmpty(),"Department tree is available with achievement access");
                Map<String,Object> departmentFilter=Map.of("categoryCode","course","majorDeptId",dept,"keyword","集成检查_");
                check(recordIds(service.list(departmentFilter,1,20)).equals(List.of(id)),"Department-filtered list uses the stored major department");
                check(service.exportIds(departmentFilter).equals(List.of(id)),"Department-filtered export matches the list on MySQL");
                Map<String,Object> ownFilter=Map.of("personId",participant,"keyword","集成检查_");
                check(((Number)service.list(ownFilter,1,20).get("total")).intValue()==1,"EXISTS returns one achievement for two member roles");
                login(participant,dept,"teacher");check(!(Boolean)service.detail(id).get("can_edit"),"Participant is read-only");denied(()->service.save(body,id));denied(()->service.delete(List.of(id)));
                login(other,dept,"teacher");denied(()->service.detail(id));check(((Number)service.list(ownFilter,1,20).get("total")).intValue()==0,"Person filter cannot bypass caller scope");
                for(String role:List.of("dept_head","dean","secretary")){login(other,dept,role);check(service.detail(id)!=null,"College read "+role);denied(()->service.delete(List.of(id)));denied(()->service.save(body,null));}
                login(owner,dept,"teacher");AchievementFiles files=new AchievementFiles(service,access);var root=AchievementFiles.class.getDeclaredField("storageRoot");root.setAccessible(true);root.set(files,workspace.resolve("private").toString());
                AchievementExport exports=new AchievementExport(service,files);
                try {completed(exports,1,Map.of("ids",List.of(id)));throw new AssertionError("Export without evidence accepted");}catch(ServiceException expected){checks++;}
                java.awt.image.BufferedImage image=new java.awt.image.BufferedImage(100,100,java.awt.image.BufferedImage.TYPE_INT_RGB);ByteArrayOutputStream buffer=new ByteArrayOutputStream();javax.imageio.ImageIO.write(image,"png",buffer);
                long attachment=AchievementService.number(files.upload(new BytesFile("evidence.png",buffer.toByteArray()),1,id,null).get("id"));check(files.readable(attachment).get("mime_type").equals("image/jpeg"),"Evidence compressed to JPEG");
                files.upload(new BytesFile("evidence2.png",buffer.toByteArray()),1,id,null);
                try{files.upload(new BytesFile("third.png",buffer.toByteArray()),1,id,null);throw new AssertionError("Third image accepted");}catch(ServiceException expected){checks++;}
                login(other,dept,"teacher");denied(()->files.readable(attachment));denied(()->service.profile(owner));
                login(participant,dept,"teacher");denied(()->files.delete(attachment));
                login(owner,dept,"teacher");service.saveProfile(owner,Map.of("real_name","检查姓名","gender",1,"birth_date","1990-01-01","highest_education","本科"));check(service.profile(owner).get("real_name").equals("检查姓名"),"Profile roundtrip");
                service.sort("course",List.of(id));
                for(int type=1;type<=3;type++) {
                    Map<String,Object> task=completed(exports,type,Map.of("ids",List.of(id),"sort","custom","majorDeptId",dept));long taskId=AchievementService.number(task.get("id"));Map<String,Object> stored=exports.download(taskId);Path path=files.resolve(stored.get("storage_key").toString());check(Files.size(path)>0,"Generated export "+type);
                    if(type==1)try(var stream=Files.newInputStream(path);var workbook=new XSSFWorkbook(stream)){check(workbook.getNumberOfSheets()==15,"15 module sheets");check(workbook.getSheet("课程").getPhysicalNumberOfRows()==2,"Export has exactly one data row");}
                    if(type==2)try(var stream=Files.newInputStream(path);var doc=new XWPFDocument(stream)){long pictures=doc.getParagraphs().stream().flatMap(p->p.getRuns().stream()).mapToLong(run->run.getEmbeddedPictures().size()).sum();check(pictures==2,"Word contains both evidence images");}
                    if(type==3)try(var zip=new ZipFile(path.toFile())){check(zip.stream().filter(e->!e.isDirectory()).count()==4,"ZIP includes Excel, Word and both images");check(zip.getEntry("集成检查_课程.xlsx")!=null && zip.getEntry("集成检查_课程.docx")!=null && zip.getEntry("附件/集成检查_课程/evidence.jpg")!=null,"ZIP reports and named attachment folder");}
                    login(other,dept,"teacher");denied(()->exports.download(taskId));
                    for(String role:List.of("admin","dept_head","dean","secretary")) {
                        login(other,dept,role);
                        check(exports.tasks().stream().noneMatch(t->AchievementService.number(t.get("id"))==taskId),"Task list isolates role "+role);
                        denied(()->exports.download(taskId));
                    }
                    login(1,dept,"admin");
                    check(exports.tasks().stream().noneMatch(t->AchievementService.number(t.get("id"))==taskId),"Superadmin task list is personal");
                    denied(()->exports.download(taskId));
                    login(owner,dept,"teacher");
                }
                files.upload(new BytesFile("single-page.pdf",pdfBytes(1)),1,id,null);
                files.upload(new BytesFile("three-pages.pdf",pdfBytes(3)),1,id,null);
                for(boolean summaryExport:List.of(false,true)) {
                    Map<String,Object> params=new LinkedHashMap<>(Map.of("ids",List.of(id),"sort","custom"));if(summaryExport)params.put("scope","summary");
                    Map<String,Object> task=completed(exports,2,params);Path wordFile=files.resolve(exports.download(AchievementService.number(task.get("id"))).get("storage_key").toString());
                    try(var stream=Files.newInputStream(wordFile);var doc=new XWPFDocument(stream)) {
                        var pictures=doc.getParagraphs().stream().flatMap(p->p.getRuns().stream()).flatMap(run->run.getEmbeddedPictures().stream()).toList();
                        check(pictures.size()==5,"Word embeds existing images plus one single-page PDF page and first two three-page PDF pages "+summaryExport);
                        List<String> captions=doc.getParagraphs().stream().map(p->p.getText()).filter(t->t.startsWith("PDF第")).toList();
                        check(captions.equals(List.of("PDF第1页（共1页，展示前1页）","PDF第1页（共3页，展示前2页）","PDF第2页（共3页，展示前2页）")),"Word PDF captions preserve attachment and page order "+summaryExport);
                        check(pictures.stream().allMatch(p->p.getCTPicture().getSpPr().getXfrm().getExt().getCx()<=org.apache.poi.util.Units.toEMU(450)),"Evidence images fit printable Word width");
                        for(int index=2;index<5;index++) {
                            var rendered=javax.imageio.ImageIO.read(new ByteArrayInputStream(pictures.get(index).getPictureData().getData()));
                            int color=rendered.getRGB(rendered.getWidth()/2,rendered.getHeight()/2)&0xFFFFFF;
                            check(color==(index==4?0x00FF00:0xFF0000),"Word contains rendered PDF page content, excluding blue third page");
                        }
                    }
                }
                Map<String,Object> pdfZip=completed(exports,3,Map.of("ids",List.of(id)));Path zipPath=files.resolve(exports.download(AchievementService.number(pdfZip.get("id"))).get("storage_key").toString());
                try(var zip=new ZipFile(zipPath.toFile())) {
                    var entry=zip.stream().filter(e->e.getName().endsWith("three-pages.pdf")).findFirst().orElseThrow();
                    try(var pdf=org.apache.pdfbox.Loader.loadPDF(zip.getInputStream(entry).readAllBytes())){check(pdf.getNumberOfPages()==3,"ZIP preserves complete original PDF");}
                }
                long invalidPdf=AchievementService.number(files.upload(new BytesFile("invalid.pdf","%PDF-invalid".getBytes(java.nio.charset.StandardCharsets.US_ASCII)),1,id,null).get("id"));
                try{completed(exports,2,Map.of("ids",List.of(id)));throw new AssertionError("Invalid PDF silently omitted");}catch(ServiceException expected){check(expected.getMessage().contains("invalid.pdf"),"Invalid PDF export names failing attachment");}
                files.delete(invalidPdf);
                for(var category:AchievementCatalog.ALL) {
                    Map<String,Object> record=new LinkedHashMap<>();record.put("category_code",category.code());record.put("name","类型检查_"+category.label());record.put("owner_id",owner);record.put("achieved_date","2026-10-30");
                    boolean project=category.code().startsWith("project_");
                    Map<String,Object> values=new LinkedHashMap<>();
                    if(project){values.put("contract_wan","2.50");values.put("received_wan","1.25");category.fields().stream().filter(field->field.type().equals("date")).forEach(field->values.put(field.key(),field.label().equals("立项时间")?"2026-01-01":"2026-10-30"));}
                    record.put("detail",values);
                    long recordId=service.save(record,null);check(service.detail(recordId).get("category_code").equals(category.code()),"Category roundtrip "+category.code());
                    @SuppressWarnings("unchecked") List<Map<String,Object>> list=(List<Map<String,Object>>)service.list(Map.of("categoryCode",category.code(),"ids",List.of(recordId)),1,20).get("rows");
                    check(list.size()==1 && list.get(0).get("detail") instanceof Map,"Category list joins detail "+category.code());
                    if(project) {
                        @SuppressWarnings("unchecked") Map<String,Object> stored=(Map<String,Object>)list.get(0).get("detail");
                        check(new java.math.BigDecimal("2.50").compareTo((java.math.BigDecimal)stored.get("contract_wan"))==0 && new java.math.BigDecimal("1.25").compareTo((java.math.BigDecimal)stored.get("received_wan"))==0,"Two independent project funds");
                        check(list.get(0).get("achieved_date").equals("2026-01-01"),"Project time uses establishment date");
                        check(!stored.containsKey("fund_wan"),"Legacy single funding field removed");
                        service.getJdbcTemplate().update("INSERT INTO zs_achievement_member(achievement_id,user_id,member_name,member_role,sort_num) VALUES(?,?,?,'member',0)",recordId,participant,"历史成员");
                        login(participant,dept,"teacher");denied(()->service.readable(recordId));
                        login(owner,dept,"teacher");check(((Number)service.list(Map.of("ids",List.of(recordId),"personId",participant),1,20).get("total")).intValue()==0,"Project person filter only matches owner");
                        record.put("members",List.of(Map.of("user_id",participant,"member_role","member")));
                        try{service.save(record,recordId);throw new AssertionError("Project members accepted");}catch(ServiceException expected){checks++;}record.remove("members");
                        service.save(record,recordId);check(service.detail(recordId).get("name").equals(record.get("name")),"Project can be edited without member field");
                        if(category.code().equals("project_research")) {
                            files.upload(new BytesFile("project.png",buffer.toByteArray()),1,recordId,null);
                            Map<String,Object> task=completed(exports,1,Map.of("ids",List.of(recordId),"categoryCode",category.code()));Map<String,Object> storedTask=exports.download(AchievementService.number(task.get("id")));
                            try(var stream=Files.newInputStream(files.resolve(storedTask.get("storage_key").toString()));var workbook=new XSSFWorkbook(stream)) {
                                List<String> labels=new ArrayList<>();workbook.getSheet("教科研项目").getRow(0).forEach(cell->labels.add(cell.getStringCellValue()));
                                check(labels.containsAll(List.of("合同经费（万元）","到账经费（万元）","立项时间","结项时间")) && !labels.contains("参与人员") && !labels.contains("申请日期") && !labels.contains("经费（万元）"),"Project export matches revised form");
                            }
                        }
                    }
                    service.delete(List.of(recordId));
                }
                check(AchievementCatalog.get("project_research").fields().stream().filter(f->f.key().equals("received_wan")).findFirst().orElseThrow().label().contains("万元"),"Funding unit is ten thousand yuan");
                login(adminUser,dept,"admin");
                List<Long> summaryIds=new ArrayList<>();
                String[] summaryCategories={"course","paper","course","paper"};long[] summaryOwners={owner,participant,other,owner};
                for(int i=0;i<4;i++) {
                    Map<String,Object> record=new LinkedHashMap<>();record.put("category_code",summaryCategories[i]);record.put("name","汇总检查_"+(char)('A'+i));record.put("owner_id",summaryOwners[i]);record.put("achieved_date","2026-10-"+(29-i));record.put("detail",Map.of());
                    if(i==0) record.put("members",List.of(Map.of("user_id",participant,"member_role","participant")));
                    long recordId=service.save(record,null);summaryIds.add(recordId);files.upload(new BytesFile("summary.png",buffer.toByteArray()),1,recordId,null);
                }
                Map<String,Object> summaryFilter=new LinkedHashMap<>(Map.of("scope","summary","keyword","汇总检查_","sort","custom","majorDeptId",dept));
                check(recordIds(service.list(summaryFilter,1,20)).equals(summaryIds),"Summary without selections includes all authorized records");
                summaryFilter.put("ownerIds",List.of(owner,participant));summaryFilter.put("categoryCodes",List.of("course","paper"));
                check(recordIds(service.list(summaryFilter,1,20)).equals(List.of(summaryIds.get(0),summaryIds.get(1),summaryIds.get(3))),"Multiple owners and categories use union within and intersection between filters");
                summaryFilter.put("ownerIds",owner+","+participant);summaryFilter.put("categoryCodes","course,paper");
                check(((Number)service.list(summaryFilter,1,20).get("total")).intValue()==3,"Comma separated GET filters match JSON array filters");
                summaryFilter.put("ownerIds",List.of(participant));summaryFilter.put("categoryCodes",List.of("course"));
                check(recordIds(service.list(summaryFilter,1,20)).isEmpty(),"Summary owner selection excludes participant-only matches");
                summaryFilter.remove("ownerIds");
                check(recordIds(service.list(summaryFilter,1,20)).equals(List.of(summaryIds.get(0),summaryIds.get(2))),"Business scope alone works");
                summaryFilter.remove("categoryCodes");summaryFilter.put("ownerIds",List.of(owner));
                check(recordIds(service.list(summaryFilter,1,20)).equals(List.of(summaryIds.get(0),summaryIds.get(3))),"Owner alone works");
                summaryFilter.remove("ownerIds");summaryFilter.put("startDate","2026-10-27");summaryFilter.put("endDate","2026-10-28");
                check(recordIds(service.list(summaryFilter,1,20)).equals(List.of(summaryIds.get(1),summaryIds.get(2))),"Summary date boundaries are inclusive");
                summaryFilter.remove("startDate");summaryFilter.remove("endDate");
                service.sort("summary",List.of(summaryIds.get(3),summaryIds.get(0),summaryIds.get(1),summaryIds.get(2)));
                check(recordIds(service.list(summaryFilter,1,20)).equals(List.of(summaryIds.get(3),summaryIds.get(0),summaryIds.get(1),summaryIds.get(2))),"Summary custom sort supports interleaved categories");
                service.sort("course",List.of(summaryIds.get(2),summaryIds.get(0)));
                check(recordIds(service.list(Map.of("keyword","汇总检查_","categoryCode","course","sort","custom"),1,20)).equals(List.of(summaryIds.get(2),summaryIds.get(0))),"Business category retains independent custom order");
                check(recordIds(service.list(summaryFilter,1,20)).get(0).equals(summaryIds.get(3)),"Business sort does not overwrite summary order");
                service.sort("summary",List.of(summaryIds.get(1),summaryIds.get(3)));
                check(recordIds(service.list(summaryFilter,1,20)).equals(List.of(summaryIds.get(1),summaryIds.get(0),summaryIds.get(3),summaryIds.get(2))),"Filtered sort preserves unselected positions");
                summaryFilter.put("ownerIds",List.of(owner,participant));summaryFilter.put("categoryCodes",List.of("course","paper"));
                List<Long> exportOrder=List.of(summaryIds.get(1),summaryIds.get(0),summaryIds.get(3));
                for(int type=1;type<=3;type++) {
                    Map<String,Object> task=completed(exports,type,summaryFilter);Map<String,Object> stored=exports.download(AchievementService.number(task.get("id")));Path path=files.resolve(stored.get("storage_key").toString());
                    check(com.alibaba.fastjson2.JSON.parseArray(stored.get("snapshot_json").toString(),Long.class).equals(exportOrder),"Summary export snapshot matches filtered list order "+type);
                    if(type==1)try(var stream=Files.newInputStream(path);var workbook=new XSSFWorkbook(stream)) {
                        var sheet=workbook.getSheetAt(0);check(sheet.getSheetName().equals("成果汇总") && sheet.getPhysicalNumberOfRows()==4,"Excel starts with summary sheet containing filtered rows");
                        check(sheet.getRow(1).getCell(3).getStringCellValue().equals("汇总检查_B") && sheet.getRow(2).getCell(3).getStringCellValue().equals("汇总检查_A") && sheet.getRow(3).getCell(3).getStringCellValue().equals("汇总检查_D"),"Excel summary preserves cross category order");
                    }
                    if(type==2)try(var stream=Files.newInputStream(path);var doc=new XWPFDocument(stream)) {
                        List<String> titles=doc.getParagraphs().stream().map(p->p.getText()).filter(t->t.matches("\\d+\\. 汇总检查_.*")).toList();check(titles.equals(List.of("1. 汇总检查_B","2. 汇总检查_A","3. 汇总检查_D")),"Word preserves cross category order");
                    }
                    if(type==3)try(var zip=new ZipFile(path.toFile())) {
                        List<String> folders=zip.stream().filter(e->e.isDirectory()).map(e->e.getName()).toList();check(folders.equals(List.of("附件/","附件/汇总检查_B/","附件/汇总检查_A/","附件/汇总检查_D/")),"ZIP named folders preserve cross category order");
                    }
                }
                summaryFilter.put("ids",List.of(summaryIds.get(3),summaryIds.get(1)));
                Map<String,Object> selectedTask=completed(exports,1,summaryFilter);
                check(com.alibaba.fastjson2.JSON.parseArray(exports.download(AchievementService.number(selectedTask.get("id"))).get("snapshot_json").toString(),Long.class).equals(List.of(summaryIds.get(1),summaryIds.get(3))),"Selected export uses list order rather than checkbox order");
                summaryFilter.remove("ids");
                login(other,dept,"teacher");
                check(recordIds(service.list(summaryFilter,1,20)).isEmpty(),"Multi-select filters cannot bypass teacher visibility");
                denied(()->service.sort("summary",List.of(summaryIds.get(1))));
                for(String role:List.of("dept_head","dean","secretary")){login(other,dept,role);check(recordIds(service.list(summaryFilter,1,20)).size()==3,"Summary college read "+role);}
                login(adminUser,dept,"admin");
                try{service.list(Map.of("categoryCodes","course,invalid_category"),1,20);throw new AssertionError("Invalid category accepted");}catch(ServiceException expected){checks++;}
                service.delete(summaryIds);
                login(owner,dept,"teacher");
                service.delete(List.of(id));try{service.readable(id);throw new AssertionError("Deleted row visible");}catch(ServiceException expected){checks++;}
                // Queue state, duplicate submission, persistence and failure isolation.
                long queueRecord=service.save(body,null);files.upload(new BytesFile("queue.png",buffer.toByteArray()),1,queueRecord,null);
                Map<String,Object> queued=exports.create(1,Map.of("ids",List.of(queueRecord)));
                long queuedId=AchievementService.number(queued.get("id"));
                check(((Number)exports.tasks().get(0).get("status")).intValue()==0,"Queue status is persisted");
                try{exports.create(1,Map.of("ids",List.of(queueRecord)));throw new AssertionError("Duplicate active task accepted");}catch(ServiceException expected){checks++;}
                try{exports.download(queuedId);throw new AssertionError("Unfinished download accepted");}catch(ServiceException expected){checks++;}
                login(other,dept,"teacher");check(exports.tasks().stream().noneMatch(t->AchievementService.number(t.get("id"))==queuedId),"Task list isolates users");denied(()->exports.download(queuedId));
                // Fresh instance consumes persisted task without relying on submitter's thread context.
                AchievementExport restarted=new AchievementExport(service,files);restarted.processTask(queuedId);
                check(access.userId()==other,"Worker restores caller security context");
                login(owner,dept,"teacher");check(exports.download(queuedId)!=null,"Persisted queue is consumed after restart");
                Map<String,Object> revoked=exports.create(1,Map.of("ids",List.of(queueRecord)));long revokedId=AchievementService.number(revoked.get("id"));
                service.getJdbcTemplate().update("UPDATE sys_user SET status='1' WHERE user_id=?",owner);exports.processTask(revokedId);
                check(((Number)exports.tasks().get(0).get("status")).intValue()==3,"Disabled requester fails task");
                service.getJdbcTemplate().update("UPDATE sys_user SET status='0' WHERE user_id=?",owner);
                Map<String,Object> deleted=exports.create(1,Map.of("ids",List.of(queueRecord)));long deletedId=AchievementService.number(deleted.get("id"));service.delete(List.of(queueRecord));exports.processTask(deletedId);
                check(((Number)exports.tasks().get(0).get("status")).intValue()==3,"Deleted record fails queued task");
                denied(()->exports.download(queuedId));
                // Exercise the 500-record batch boundary and count SQL calls.
                List<Long> batchIds=new ArrayList<>();
                for(int i=0;i<501;i++) {
                    long batchId=service.insert("INSERT INTO zs_achievement(category_code,name,owner_id,major_dept_id,achieved_date,created_by) VALUES('course',?,?,?,'2026-10-30',?)","批量检查_"+i,owner,dept,owner);batchIds.add(batchId);
                    service.getJdbcTemplate().update("INSERT INTO zs_detail_course(achievement_id,project_name) VALUES(?,?)",batchId,"批量课程");
                    service.getJdbcTemplate().update("INSERT INTO zs_attachment(achievement_id,target_type,original_name,storage_key,file_size,mime_type,file_ext,uploader_id) VALUES(?,1,'batch.jpg','test/batch.jpg',1,'image/jpeg','jpg',?)",batchId,owner);
                }
                int[] queries={0};ProxyFactory counting=new ProxyFactory(new SingleConnectionDataSource(connection,true));counting.setInterfaces(javax.sql.DataSource.class);
                counting.addAdvice((MethodInterceptor)invocation->{if(invocation.getMethod().getName().equals("getConnection"))queries[0]++;return invocation.proceed();});
                AchievementService batched=new AchievementService((javax.sql.DataSource)counting.getProxy(),access);
                Collections.reverse(batchIds);List<Map<String,Object>> batchRecords=batched.exportRecords(batchIds);
                check(batchRecords.size()==501 && batchRecords.stream().map(r->AchievementService.number(r.get("id"))).toList().equals(batchIds),"Batch boundary preserves all records and snapshot order");
                check(queries[0]==8,"501 records use eight batch queries instead of per-record queries");
                queries[0]=0;batched.requireExportReadable(batchIds);check(queries[0]==2,"Download permissions use two batch queries");
                exports.stop();restarted.stop();
                System.out.println("PASS: "+checks+" integration checks; database transaction rolled back.");
            } finally {connection.rollback();SecurityContextHolder.clearContext();}
        }
    }
    @SuppressWarnings("unchecked")
    private static List<Long> recordIds(Map<String,Object> result){return ((List<Map<String,Object>>)result.get("rows")).stream().map(row->AchievementService.number(row.get("id"))).toList();}
    private static byte[] pdfBytes(int pages) throws Exception {
        try(var pdf=new org.apache.pdfbox.pdmodel.PDDocument();var output=new ByteArrayOutputStream()) {
            for(int index=0;index<pages;index++) {
                var page=new org.apache.pdfbox.pdmodel.PDPage(new org.apache.pdfbox.pdmodel.common.PDRectangle(300,400));pdf.addPage(page);
                try(var stream=new org.apache.pdfbox.pdmodel.PDPageContentStream(pdf,page)) {
                    stream.setNonStrokingColor(index==0?java.awt.Color.RED:index==1?java.awt.Color.GREEN:java.awt.Color.BLUE);stream.addRect(20,20,260,300);stream.fill();
                    stream.setNonStrokingColor(java.awt.Color.BLACK);stream.beginText();stream.setFont(new org.apache.pdfbox.pdmodel.font.PDType1Font(org.apache.pdfbox.pdmodel.font.Standard14Fonts.FontName.HELVETICA),18);stream.newLineAtOffset(30,350);stream.showText("PDF preview page "+(index+1));stream.endText();
                }
            }
            pdf.save(output);return output.toByteArray();
        }
    }
    private static String find(String text,String key){var matcher=java.util.regex.Pattern.compile("(?m)^\\s+"+key+":\\s*(.*?)\\s*$").matcher(text);if(!matcher.find())throw new IllegalArgumentException("Missing database config");String value=matcher.group(1).trim();if((value.startsWith("\"")&&value.endsWith("\""))||(value.startsWith("'")&&value.endsWith("'")))value=value.substring(1,value.length()-1);return value;}
    record BytesFile(String name,byte[] bytes) implements MultipartFile {
        public String getName(){return "file";}public String getOriginalFilename(){return name;}public String getContentType(){return "image/png";}public boolean isEmpty(){return bytes.length==0;}public long getSize(){return bytes.length;}public byte[] getBytes(){return bytes;}public InputStream getInputStream(){return new ByteArrayInputStream(bytes);}public void transferTo(File destination)throws IOException{Files.write(destination.toPath(),bytes);}
    }
}
