package com.sensitive.srams;

import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.zip.*;
import javax.imageio.ImageIO;
import com.alibaba.fastjson2.JSON;
import com.sensitive.common.exception.ServiceException;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.xwpf.usermodel.*;
import org.apache.poi.util.Units;
import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.rendering.PDFRenderer;
import org.apache.pdfbox.rendering.ImageType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import com.sensitive.common.core.domain.entity.SysUser;
import com.sensitive.common.core.domain.entity.SysRole;
import com.sensitive.common.core.domain.model.LoginUser;
import jakarta.annotation.PreDestroy;
import java.util.concurrent.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class AchievementExport {
    private final AchievementService service;
    private final AchievementFiles files;
    public AchievementExport(AchievementService service,AchievementFiles files) {this.service=service;this.files=files;}
    private static final Logger log=LoggerFactory.getLogger(AchievementExport.class);
    // 当前部署为单应用实例：数据库持久化排队，单工作线程限制大型导出并发。
    private final ScheduledExecutorService worker=Executors.newSingleThreadScheduledExecutor(r->{Thread t=new Thread(r,"achievement-export");t.setDaemon(true);return t;});
    @EventListener(ApplicationReadyEvent.class)
    public void start() {
        recoverInterrupted();
        worker.scheduleWithFixedDelay(()->{try{processNext();}catch(Exception ex){log.error("导出队列处理失败，下次轮询重试",ex);}},0,2,TimeUnit.SECONDS);
    }
    void recoverInterrupted() {
        service.getJdbcTemplate().update("UPDATE zs_export_task SET status=3,error_message='服务重启导致生成中断，请重新提交导出',finished_at=NOW() WHERE status=1");
    }
    @PreDestroy
    public void stop() {
        worker.shutdown();
        try{if(!worker.awaitTermination(30,TimeUnit.SECONDS))worker.shutdownNow();}
        catch(InterruptedException ex){worker.shutdownNow();Thread.currentThread().interrupt();}
    }
    public synchronized Map<String,Object> create(int type,Map<String,Object> params) {
        if(type<1 || type>3) throw new ServiceException("无效的导出类型");
        long userId=service.getAccess().userId();
        if(!service.rows("SELECT id FROM zs_export_task WHERE requester_id=? AND status IN (0,1) LIMIT 1",userId).isEmpty())
            throw new ServiceException("您已有未完成的导出任务，请在导出任务列表中查看");
        long pending=Objects.requireNonNull(service.getJdbcTemplate().queryForObject("SELECT COUNT(*) FROM zs_export_task WHERE status IN (0,1)",Long.class));
        if(pending>=100) throw new ServiceException("导出队列已满，请稍后再试");
        boolean profileExport="profile".equals(params.get("scope"));
        List<Long> ids;
        String description;
        if(profileExport) {
            long profileId=AchievementService.number(params.get("profileUserId"));
            Map<String,Object> profile=service.profile(profileId);
            ids=List.of(profileId);
            String name=AchievementService.text(profile.get("real_name"));
            description="教师资料 · "+(name.isEmpty()?"教师 #"+profileId:name);
        } else {
            ids=service.exportIds(params);
            if(ids.isEmpty()) throw new ServiceException("没有符合条件的成果");
            String name=AchievementService.text(service.one("SELECT name FROM zs_achievement WHERE id=?",ids.get(0)).get("name"));
            description=achievementSection(params)+" · "+name+(ids.size()>1?" 等 "+ids.size()+" 条":"");
        }
        Map<String,Object> taskParams=new LinkedHashMap<>(params);taskParams.put("_taskLabel",description);
        long taskId=service.insert("INSERT INTO zs_export_task(requester_id,task_type,params_json,snapshot_json,status) VALUES(?,?,?,?,0)",userId,type,JSON.toJSONString(taskParams),JSON.toJSONString(ids));
        return Map.of("id",taskId,"status",0,"file_name",fileName(taskId,type,profileExport));
    }
    private String achievementSection(Map<String,Object> params) {
        if("summary".equals(params.get("scope"))) return "成果总览";
        String code=AchievementService.text(params.get("categoryCode"));
        return AchievementCatalog.ALL.stream().filter(c->c.code().equals(code)).map(AchievementCatalog.Category::label).findFirst().orElse("成果材料");
    }
    private String taskDescription(Map<String,Object> task) {
        Object raw=task.get("params_json"),snapshot=task.get("snapshot_json");
        Map<String,Object> params=raw==null?Map.of():JSON.parseObject(raw.toString());
        String stored=AchievementService.text(params.get("_taskLabel"));
        if(!stored.isEmpty()) return stored;
        List<Long> ids=snapshot==null?List.of():JSON.parseArray(snapshot.toString(),Long.class);
        if("profile".equals(params.get("scope"))) {
            if(ids.isEmpty()) return "教师资料";
            long id=ids.get(0);
            try {
                service.getAccess().requireProfileRead(id);
                var names=service.rows("SELECT COALESCE(NULLIF(p.real_name,''),u.nick_name) AS name FROM sys_user u LEFT JOIN zs_teacher_profile p ON p.user_id=u.user_id WHERE u.user_id=?",id);
                if(!names.isEmpty() && !AchievementService.text(names.get(0).get("name")).isEmpty())
                    return "教师资料 · "+names.get(0).get("name");
            } catch(ServiceException ignored) { /* 权限已变更时不显示姓名。 */ }
            return "教师资料 · 教师 #"+id;
        }
        String section=achievementSection(params);
        if(ids.isEmpty()) return section;
        try {
            service.requireExportReadable(List.of(ids.get(0)));
            var names=service.rows("SELECT name FROM zs_achievement WHERE id=?",ids.get(0));
            if(!names.isEmpty())return section+" · "+names.get(0).get("name")+(ids.size()>1?" 等 "+ids.size()+" 条":"");
        } catch(ServiceException ignored) { /* 权限已变更时只显示类别和数量。 */ }
        return section+" · "+ids.size()+" 条";
    }
    private boolean profileTask(Map<String,Object> task) {
        Object params=task.get("params_json");
        return params!=null && "profile".equals(JSON.parseObject(params.toString()).getString("scope"));
    }
    private String fileName(long id,int type,boolean profile) {return (profile?"教师资料_":"成果材料_")+id+"."+extension(type);}
    private String extension(int type) {return switch(type){case 1->"xlsx";case 2->"docx";default->"zip";};}
    public List<Map<String,Object>> tasks() {
        List<Map<String,Object>> tasks=service.rows("SELECT id,task_type,params_json,snapshot_json,status,error_message,created_at,finished_at,expires_at,"
            +"CASE WHEN expires_at<=NOW() THEN 1 ELSE 0 END AS expired,"
            +"CASE WHEN status=0 THEN (SELECT COUNT(*) FROM zs_export_task q WHERE q.status IN (0,1) AND q.id<t.id) ELSE 0 END AS ahead "
            +"FROM zs_export_task t WHERE requester_id=? ORDER BY id DESC LIMIT 10",service.getAccess().userId());
        for(var task:tasks) {
            boolean profile=profileTask(task);
            task.put("file_name",fileName(AchievementService.number(task.get("id")),((Number)task.get("task_type")).intValue(),profile));
            task.put("content_type",taskDescription(task));task.remove("params_json");task.remove("snapshot_json");
        }
        return tasks;
    }
    /** 每次只领取一个任务；定时器使用唯一工作线程，生成时不占用提交锁。 */
    void processNext() throws Exception {
        List<Map<String,Object>> pending=service.rows("SELECT * FROM zs_export_task WHERE status=0 ORDER BY id LIMIT 1");
        if(pending.isEmpty()) return;
        processTask(AchievementService.number(pending.get(0).get("id")));
    }
    void processTask(long taskId) throws Exception {
        Map<String,Object> task=service.one("SELECT * FROM zs_export_task WHERE id=?",taskId);
        if(service.getJdbcTemplate().update("UPDATE zs_export_task SET status=1 WHERE id=? AND status=0",taskId)!=1)return;
        var previous=SecurityContextHolder.getContext();Path output=null;
        try {
            loginRequester(AchievementService.number(task.get("requester_id")));
            List<Long> ids=JSON.parseArray(task.get("snapshot_json").toString(),Long.class);
            boolean profileExport=profileTask(task);
            int type=((Number)task.get("task_type")).intValue();
            String key="exports/"+UUID.randomUUID()+"."+extension(type);
            output=files.resolve(key);Files.createDirectories(output.getParent());
            if(profileExport) {
                long profileId=ids.get(0);
                Map<String,Object> profile=service.profile(profileId);
                List<Map<String,Object>> certificates=profileCertificates(profileId);
                if(type==1)profileExcel(output,profile,certificates);
                else if(type==2)profileWord(output,profile,certificates);
                else profileZip(output,profile,certificates);
                service.profile(profileId);
                service.audit("export","export_task",taskId,"教师资料："+profileId);
            } else {
                List<Map<String,Object>> records=service.exportRecords(ids);
                boolean summaryExport=AchievementService.summary(JSON.parseObject(task.get("params_json").toString()));
                if(type==1)excel(output,records,summaryExport);else if(type==2)word(output,records,summaryExport);else zip(output,records,summaryExport);
                service.requireExportReadable(ids);
                service.audit("export","export_task",taskId,"成果数量："+records.size());
            }
            service.getJdbcTemplate().update("UPDATE zs_export_task SET status=2,storage_key=?,finished_at=NOW(),expires_at=DATE_ADD(NOW(),INTERVAL 7 DAY) WHERE id=?",key,taskId);
        } catch(Exception ex) {
            log.error("导出任务 {} 生成失败",taskId,ex);
            if(output!=null)try{Files.deleteIfExists(output);}catch(IOException cleanup){log.warn("清理失败的导出文件失败",cleanup);}
            String message=ex instanceof ServiceException?ex.getMessage():"生成失败，请联系管理员查看服务日志";
            service.getJdbcTemplate().update("UPDATE zs_export_task SET status=3,error_message=?,finished_at=NOW() WHERE id=?",message,taskId);
        } finally {SecurityContextHolder.setContext(previous);}
    }
    /** 后台重新读取账号及角色，不跨线程复用过期的登录权限。 */
    private void loginRequester(long id) {
        List<Map<String,Object>> users=service.rows("SELECT user_id,dept_id,user_name FROM sys_user WHERE user_id=? AND status='0' AND del_flag='0'",id);
        if(users.isEmpty())throw new ServiceException("账号已停用或删除，无法生成导出",403);
        Map<String,Object> row=users.get(0);SysUser user=new SysUser(id);user.setUserName(row.get("user_name").toString());
        user.setDeptId(row.get("dept_id")==null?null:((Number)row.get("dept_id")).longValue());
        List<SysRole> roles=new ArrayList<>();
        for(var role:service.rows("SELECT r.role_key FROM sys_role r JOIN sys_user_role ur ON ur.role_id=r.role_id WHERE ur.user_id=? AND r.status='0' AND r.del_flag='0'",id)) {
            SysRole r=new SysRole();r.setRoleKey(role.get("role_key").toString());r.setStatus("0");roles.add(r);
        }
        user.setRoles(roles);
        if(id!=1 && roles.stream().noneMatch(r->AchievementAccess.ADMIN_ROLES.contains(r.getRoleKey())) && service.rows("SELECT 1 FROM sys_user_role ur JOIN sys_role r ON r.role_id=ur.role_id "
            +"JOIN sys_role_menu rm ON rm.role_id=r.role_id JOIN sys_menu m ON m.menu_id=rm.menu_id WHERE ur.user_id=? AND r.status='0' AND r.del_flag='0' AND m.status='0' AND m.perms IN ('achievement:list','*:*:*') LIMIT 1",id).isEmpty())
            throw new ServiceException("成果访问权限已撤销，无法生成导出",403);
        var context=SecurityContextHolder.createEmptyContext();
        context.setAuthentication(new UsernamePasswordAuthenticationToken(new LoginUser(id,user.getDeptId(),user,Set.of()),null,List.of()));
        SecurityContextHolder.setContext(context);
    }
    public Map<String,Object> download(long taskId) {
        Map<String,Object> task=service.one("SELECT * FROM zs_export_task WHERE id=?",taskId);
        if(AchievementService.number(task.get("requester_id"))!=service.getAccess().userId()) throw new ServiceException("无权下载他人的导出文件",403);
        if(((Number)task.get("status")).intValue()!=2)throw new ServiceException("导出尚未完成或已失败，请查看导出任务列表");
        if(service.rows("SELECT id FROM zs_export_task WHERE id=? AND expires_at>NOW()",taskId).isEmpty())throw new ServiceException("导出文件已过期，请重新提交导出");
        List<Long> ids=JSON.parseArray(task.get("snapshot_json").toString(),Long.class);
        if(profileTask(task)) service.profile(ids.get(0));else service.requireExportReadable(ids);
        task.put("file_name",fileName(taskId,((Number)task.get("task_type")).intValue(),profileTask(task)));
        return task;
    }
    @Transactional(rollbackFor=Exception.class)
    public void delete(long taskId) throws IOException {
        Map<String,Object> task=service.one("SELECT * FROM zs_export_task WHERE id=? FOR UPDATE",taskId);
        if(AchievementService.number(task.get("requester_id"))!=service.getAccess().userId()) throw new ServiceException("无权删除他人的导出任务",403);
        int status=((Number)task.get("status")).intValue();
        if(status!=2 && status!=3) throw new ServiceException("排队或生成中的导出任务不能删除，请等待任务结束");
        service.audit("delete","export_task",taskId,"删除导出任务及生成文件");
        service.getJdbcTemplate().update("DELETE FROM zs_export_task WHERE id=?",taskId);
        String key=AchievementService.text(task.get("storage_key"));
        if(!key.isBlank()) Files.deleteIfExists(files.resolve(key));
    }
    private Map<String,List<Map<String,Object>>> groups(List<Map<String,Object>> records) {
        Map<String,List<Map<String,Object>>> grouped=new LinkedHashMap<>();
        for(AchievementCatalog.Category c:AchievementCatalog.ALL) grouped.put(c.code(),new ArrayList<>());
        records.forEach(r->grouped.get(r.get("category_code").toString()).add(r));return grouped;
    }
    @SuppressWarnings("unchecked")
    private String members(Map<String,Object> row) {
        return ((List<Map<String,Object>>)row.get("members")).stream().map(m->m.get("member_name")+"（"+role(m.get("member_role").toString())+"）").collect(java.util.stream.Collectors.joining("、"));
    }
    static String role(String key) {
        return switch(key){case "member"->"成员";case "student"->"学生";case "supervisor"->"指导教师";case "author"->"其他作者";case "first_author"->"第一作者";case "editor"->"主编";case "co_editor"->"参编";case "inventor"->"发明人";case "winner"->"获奖人";case "accompany"->"陪同人";case "lecturer"->"主讲人";default->"参与人";};
    }
    private List<Map<String,Object>> profileCertificates(long userId) {
        return service.rows("SELECT target_type,original_name,storage_key,mime_type,file_ext FROM zs_attachment WHERE profile_user_id=? AND target_type IN (2,3,4) AND deleted=0 ORDER BY target_type,id",userId);
    }
    private String certificateType(Object type) {
        return switch(((Number)type).intValue()){case 2->"学历证";case 3->"学位证";case 4->"职称证";default->"证书";};
    }
    private String profileValue(String key,Object value) {
        if(value==null)return "";
        if("gender".equals(key))return switch(value.toString()){case "1"->"男";case "2"->"女";default->value.toString();};
        return value.toString();
    }
    private void profileExcel(Path output,Map<String,Object> profile,List<Map<String,Object>> certificates) throws IOException {
        try(XSSFWorkbook workbook=new XSSFWorkbook()) {
            CellStyle header=workbook.createCellStyle();Font font=workbook.createFont();font.setBold(true);header.setFont(font);
            Sheet sheet=workbook.createSheet("教师资料");sheet.setColumnWidth(0,5500);sheet.setColumnWidth(1,11000);
            Row title=sheet.createRow(0);title.createCell(0).setCellValue("字段");title.createCell(1).setCellValue("内容");
            for(Cell cell:title)cell.setCellStyle(header);
            int n=1;
            for(var field:AchievementCatalog.PROFILE) {
                Row row=sheet.createRow(n++);row.createCell(0).setCellValue(field.label());
                row.createCell(1).setCellValue(profileValue(field.key(),profile.get(field.key())));
            }
            sheet.createFreezePane(0,1);
            Sheet list=workbook.createSheet("证书清单");list.setColumnWidth(0,5500);list.setColumnWidth(1,11000);
            Row listTitle=list.createRow(0);listTitle.createCell(0).setCellValue("证书类型");listTitle.createCell(1).setCellValue("文件名");
            for(Cell cell:listTitle)cell.setCellStyle(header);
            n=1;
            for(var certificate:certificates) {
                Row row=list.createRow(n++);row.createCell(0).setCellValue(certificateType(certificate.get("target_type")));
                row.createCell(1).setCellValue(certificate.get("original_name").toString());
            }
            list.createFreezePane(0,1);
            try(OutputStream stream=Files.newOutputStream(output)){workbook.write(stream);}
        }
    }
    private void profileWord(Path output,Map<String,Object> profile,List<Map<String,Object>> certificates) throws Exception {
        try(XWPFDocument doc=new XWPFDocument()) {
            paragraph(doc,"教师资料与证书："+profileValue("real_name",profile.get("real_name")),true,18);
            for(var field:AchievementCatalog.PROFILE) wordField(doc,field.label(),profileValue(field.key(),profile.get(field.key())));
            paragraph(doc,"学历、学位和职称证书",true,14);
            if(certificates.isEmpty())paragraph(doc,"暂无证书",false,11);
            for(var certificate:certificates) {
                String name=certificate.get("original_name").toString();
                paragraph(doc,certificateType(certificate.get("target_type"))+"："+name,false,11);
                Path source=files.resolve(certificate.get("storage_key").toString());
                if(certificate.get("mime_type").toString().startsWith("image/")) {
                    var image=ImageIO.read(source.toFile());
                    if(image==null)throw new ServiceException("证书图片无法读取");
                    try(InputStream input=Files.newInputStream(source)) {
                        evidenceImage(doc,input,"png".equals(certificate.get("file_ext"))?Document.PICTURE_TYPE_PNG:Document.PICTURE_TYPE_JPEG,name,image.getWidth(),image.getHeight());
                    }
                } else if("application/pdf".equals(certificate.get("mime_type"))) pdfEvidence(doc,source,name);
                else throw new ServiceException("不支持的证书文件类型");
            }
            try(OutputStream stream=Files.newOutputStream(output)){doc.write(stream);}
        }
    }
    private void profileZip(Path output,Map<String,Object> profile,List<Map<String,Object>> certificates) throws Exception {
        Path temporary=Files.createTempDirectory(output.getParent(),"profile-export-");
        Path spreadsheet=temporary.resolve("profile.xlsx"),document=temporary.resolve("profile.docx");
        try {
            profileExcel(spreadsheet,profile,certificates);profileWord(document,profile,certificates);
            try(ZipOutputStream zip=new ZipOutputStream(Files.newOutputStream(output))) {
                zipFile(zip,"教师资料.xlsx",spreadsheet);zipFile(zip,"教师资料.docx",document);
                zip.putNextEntry(new ZipEntry("证书/"));zip.closeEntry();
                Set<String> names=new HashSet<>();
                for(var certificate:certificates) {
                    String name=certificate.get("original_name").toString();
                    if("image/jpeg".equals(certificate.get("mime_type"))) name=name.replaceFirst("(?i)\\.(png|jpeg|jpg)$","")+".jpg";
                    zipFile(zip,"证书/"+uniqueName(certificateType(certificate.get("target_type"))+"_"+name,names,true),files.resolve(certificate.get("storage_key").toString()));
                }
            }
        } finally {
            for(Path path:List.of(spreadsheet,document,temporary)) {
                try{Files.deleteIfExists(path);}catch(IOException ex){log.warn("清理教师资料导出临时文件失败：{}",path,ex);}
            }
        }
    }
    @SuppressWarnings("unchecked")
    private void excel(Path output,List<Map<String,Object>> records,boolean summaryExport) throws IOException {
        SXSSFWorkbook workbook=new SXSSFWorkbook(100);
        workbook.setCompressTempFiles(true);
        try(workbook) {
            CellStyle header=workbook.createCellStyle();Font font=workbook.createFont();font.setBold(true);header.setFont(font);
            if(summaryExport) {
                Sheet sheet=workbook.createSheet("成果汇总");
                String[] labels={"序号","业务模块","业务范围","成果名称","负责人","成果日期","级别","佐证份数","备注"};
                Row title=sheet.createRow(0);
                for(int i=0;i<labels.length;i++){Cell cell=title.createCell(i);cell.setCellValue(labels[i]);cell.setCellStyle(header);sheet.setColumnWidth(i,i==0?2000:6000);}
                int n=1;
                for(Map<String,Object> row:records) {
                    var category=AchievementCatalog.get(row.get("category_code").toString());
                    Row line=sheet.createRow(n);line.createCell(0).setCellValue(n++);
                    Object[] values={category.group(),category.label(),row.get("name"),row.get("owner_name"),row.get("achieved_date"),row.get("level_code"),((List<?>)row.get("attachments")).size(),row.get("remark")};
                    for(int i=0;i<values.length;i++){Cell cell=line.createCell(i+1);Object v=values[i];if(v instanceof Number num)cell.setCellValue(num.doubleValue());else cell.setCellValue(v==null?"":v.toString());}
                }
                sheet.createFreezePane(0,1);sheet.setAutoFilter(new org.apache.poi.ss.util.CellRangeAddress(0,n-1,0,labels.length-1));
            }
            for(var group:groups(records).entrySet()) {
                AchievementCatalog.Category c=AchievementCatalog.get(group.getKey());
                Sheet sheet=workbook.createSheet(c.label());
                boolean project=c.code().startsWith("project_");
                boolean level=Set.of("project_major","project_research").contains(c.code());
                List<String> labels=new ArrayList<>(List.of("序号",project?"项目名称":"成果名称","负责人"));
                if(level) labels.add("级别");
                if(!project) labels.add("参与人员");
                c.fields().forEach(f->labels.add(f.label())); labels.add("备注");
                Row title=sheet.createRow(0);
                for(int i=0;i<labels.size();i++){Cell cell=title.createCell(i);cell.setCellValue(labels.get(i));cell.setCellStyle(header);sheet.setColumnWidth(i,i==0?2000:6000);}
                int n=1;
                for(Map<String,Object> row:group.getValue()) {
                    Row line=sheet.createRow(n);line.createCell(0).setCellValue(n++);
                    List<Object> values=new ArrayList<>(Arrays.asList(row.get("name"),row.get("owner_name")));
                    if(level) values.add(row.get("level_code"));
                    if(!project) values.add(members(row));
                    Map<String,Object> detail=(Map<String,Object>)row.get("detail");
                    for(var f:c.fields()) values.add(detail.get(f.key())); values.add(row.get("remark"));
                    for(int i=0;i<values.size();i++) {
                        Cell cell=line.createCell(i+1);Object v=values.get(i);
                        if(v instanceof Number num) cell.setCellValue(num.doubleValue());
                        else cell.setCellValue(v==null?"":v.toString());
                    }
                }
                sheet.createFreezePane(0,1);
                sheet.setAutoFilter(new org.apache.poi.ss.util.CellRangeAddress(0,Math.max(0,n-1),0,labels.size()-1));
            }
            try(OutputStream stream=Files.newOutputStream(output)){workbook.write(stream);}
        } finally {workbook.dispose();}
    }
    @SuppressWarnings("unchecked")
    private void word(Path output,List<Map<String,Object>> records,boolean summaryExport) throws Exception {
        try(XWPFDocument doc=new XWPFDocument()) {
            paragraph(doc,"信息工程学院业绩成果佐证材料",true,18);
            paragraph(doc,"图片佐证随正文列出；每份PDF佐证展示前两页，不足两页时展示全部页面，完整原件可通过附件压缩包获取。",false,10);
            // 汇总导出按列表逐条输出，允许不同类别交错排列。
            Map<String,List<Map<String,Object>>> sections=summaryExport?Collections.singletonMap("summary",records):groups(records);
            for(var group:sections.entrySet()) {
                if(group.getValue().isEmpty()) continue;
                if(!summaryExport) paragraph(doc,AchievementCatalog.get(group.getKey()).label(),true,16);int n=0;
                for(Map<String,Object> row:group.getValue()) {
                    var category=AchievementCatalog.get(row.get("category_code").toString());
                    paragraph(doc,(++n)+". "+row.get("name"),true,13);
                    if(summaryExport) paragraph(doc,"业务范围："+category.group()+" / "+category.label(),false,11);
                    paragraph(doc,"负责人："+row.get("owner_name")+"    时间："+row.get("achieved_date"),false,11);
                    if(Set.of("project_major","project_research").contains(category.code())) wordField(doc,"级别",row.get("level_code"));
                    if(!category.code().startsWith("project_")) wordField(doc,"参与人员",members(row));
                    Map<String,Object> detail=(Map<String,Object>)row.get("detail");
                    for(var field:category.fields()) wordField(doc,field.label(),detail.get(field.key()));
                    wordField(doc,"备注",row.get("remark"));
                    for(Map<String,Object> attachment:(List<Map<String,Object>>)row.get("attachments")) {
                        Map<String,Object> file=attachment;
                        paragraph(doc,"佐证："+file.get("original_name"),false,10);
                        Path source=files.resolve(file.get("storage_key").toString());
                        if(file.get("mime_type").toString().startsWith("image/")) {
                            var image=ImageIO.read(source.toFile());
                            if(image==null) throw new ServiceException("佐证图片无法读取");
                            try(InputStream input=Files.newInputStream(source)){evidenceImage(doc,input,file.get("file_ext").toString().equals("png")?Document.PICTURE_TYPE_PNG:Document.PICTURE_TYPE_JPEG,file.get("original_name").toString(),image.getWidth(),image.getHeight());}
                        } else if("application/pdf".equals(file.get("mime_type"))) {
                            pdfEvidence(doc,source,file.get("original_name").toString());
                        }
                    }
                }
            }
            try(OutputStream stream=Files.newOutputStream(output)){doc.write(stream);}
        }
    }
    private void pdfEvidence(XWPFDocument doc,Path source,String name) throws Exception {
        try(PDDocument pdf=Loader.loadPDF(source.toFile())) {
            if(pdf.getNumberOfPages()==0) throw new ServiceException("PDF佐证“"+name+"”没有可展示的页面");
            PDFRenderer renderer=new PDFRenderer(pdf);
            renderer.setSubsamplingAllowed(true);
            int count=Math.min(pdf.getNumberOfPages(),2);
            for(int index=0;index<count;index++) {
                var box=pdf.getPage(index).getCropBox();
                float scale=Math.min(2f,2000f/Math.max(box.getWidth(),box.getHeight()));
                var image=renderer.renderImage(index,scale,ImageType.RGB);
                try {
                    XWPFParagraph caption=doc.createParagraph();caption.getCTP().addNewPPr();caption.setKeepNext(true);
                    XWPFRun label=caption.createRun();label.setText("PDF第"+(index+1)+"页（共"+pdf.getNumberOfPages()+"页，展示前"+count+"页）");label.setFontFamily("宋体");label.setFontSize(10);
                    ByteArrayOutputStream bytes=new ByteArrayOutputStream();ImageIO.write(image,"png",bytes);
                    try(InputStream input=new ByteArrayInputStream(bytes.toByteArray())){evidenceImage(doc,input,Document.PICTURE_TYPE_PNG,name+"_"+(index+1)+".png",image.getWidth(),image.getHeight());}
                } finally {image.flush();}
            }
        } catch(IOException ex) {
            throw new ServiceException("PDF佐证“"+name+"”无法读取，请检查文件是否损坏或需要密码");
        }
    }
    private void evidenceImage(XWPFDocument doc,InputStream input,int type,String name,int width,int height) throws Exception {
        double scale=Math.min(450.0/width,600.0/height);
        XWPFRun run=doc.createParagraph().createRun();
        run.addPicture(input,type,name,Units.toEMU(width*scale),Units.toEMU(height*scale));
    }
    private void paragraph(XWPFDocument doc,String text,boolean bold,int size) {
        XWPFParagraph p=doc.createParagraph();p.setSpacingAfter(120);XWPFRun run=p.createRun();run.setText(text);run.setBold(bold);run.setFontFamily("宋体");run.setFontSize(size);
    }
    private void wordField(XWPFDocument doc,String label,Object value) {
        String text=AchievementService.text(value);
        paragraph(doc,label+"："+(text.isEmpty()?"—":text),false,11);
    }
    private static String safe(String name) {
        String clean=name.replaceAll("[\\\\/:*?\"<>|\\p{Cntrl}]","_").trim();
        clean=clean.substring(0,Math.min(clean.length(),90)).replaceAll("[. ]+$","");
        if(clean.matches("(?i)(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\\..*)?")) clean="_"+clean;
        return clean.isEmpty()?"附件":clean;
    }
    private static String uniqueName(String name,Set<String> used,boolean file) {
        int dot=file?name.lastIndexOf('.'):-1;
        String stem=safe(dot>0?name.substring(0,dot):name),ext=dot>0?"."+safe(name.substring(dot+1)):"";
        String result=stem+ext;int suffix=2;
        while(!used.add(result.toLowerCase(Locale.ROOT))) result=stem+" ("+(suffix++)+")"+ext;
        return result;
    }
    private void zipFile(ZipOutputStream zip,String name,Path source) throws IOException {
        zip.putNextEntry(new ZipEntry(name));Files.copy(source,zip);zip.closeEntry();
    }
    @SuppressWarnings("unchecked")
    private void zip(Path output,List<Map<String,Object>> records,boolean summaryExport) throws Exception {
        Path temporary=Files.createTempDirectory(output.getParent(),"export-bundle-");
        Path spreadsheet=temporary.resolve("report.xlsx"),document=temporary.resolve("report.docx");
        try {
            // 三种内容共用同一批授权数据及顺序；使用临时文件，避免将整个包加载到内存。
            excel(spreadsheet,records,summaryExport);word(document,records,summaryExport);
            String title=records.size()==1?safe(records.get(0).get("name").toString()):"成果汇总";
            try(ZipOutputStream zip=new ZipOutputStream(Files.newOutputStream(output))) {
                zipFile(zip,title+".xlsx",spreadsheet);zipFile(zip,title+".docx",document);
                zip.putNextEntry(new ZipEntry("附件/"));zip.closeEntry();
                Set<String> folders=new HashSet<>();
                Map<String,List<Map<String,Object>>> sections=summaryExport?Collections.singletonMap("summary",records):groups(records);
                for(var group:sections.values()) for(Map<String,Object> row:group) {
                    String folder="附件/"+uniqueName(row.get("name").toString(),folders,false)+"/";
                    zip.putNextEntry(new ZipEntry(folder));zip.closeEntry();
                    Set<String> names=new HashSet<>();
                    for(Map<String,Object> file:(List<Map<String,Object>>)row.get("attachments")) {
                        String name=file.get("original_name").toString();
                        // 上传时压缩后的图片实际为 JPEG，保留原名并修正扩展名。
                        if("image/jpeg".equals(file.get("mime_type"))) name=name.replaceFirst("(?i)\\.(png|jpeg|jpg)$","")+".jpg";
                        zipFile(zip,folder+uniqueName(name,names,true),files.resolve(file.get("storage_key").toString()));
                    }
                }
            }
        } finally {
            for(Path path:List.of(spreadsheet,document,temporary)) {
                try{Files.deleteIfExists(path);}catch(IOException ex){log.warn("清理导出压缩包临时文件失败：{}",path,ex);}
            }
        }
    }
}
