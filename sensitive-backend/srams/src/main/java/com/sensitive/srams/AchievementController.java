package com.sensitive.srams;

import java.nio.file.*;
import java.util.*;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import com.sensitive.common.core.domain.AjaxResult;
import com.sensitive.common.utils.file.FileUtils;
import com.sensitive.common.exception.ServiceException;

/** 所有入口均需登录，数据授权在业务服务中统一执行。 */
@RestController
@RequestMapping("/achievement")
@PreAuthorize("@ss.hasPermi('achievement:list')")
public class AchievementController {
    private final AchievementService service;
    private final AchievementFiles files;
    private final AchievementExport exports;
    private final AchievementRecognition recognition;
    public AchievementController(AchievementService service,AchievementFiles files,AchievementExport exports,AchievementRecognition recognition) {
        this.service=service;this.files=files;this.exports=exports;this.recognition=recognition;
    }
    @GetMapping("/metadata")
    public AjaxResult metadata(){return AjaxResult.success(Map.of("categories",AchievementCatalog.ALL,"profileFields",AchievementCatalog.PROFILE,"userId",service.getAccess().userId(),"admin",service.getAccess().admin(),"collegeRead",service.getAccess().collegeRead(),"canCreate",service.getAccess().canCreate(),"recognitionEnabled",recognition.enabled()));}
    @GetMapping("/people") public AjaxResult people(){return AjaxResult.success(service.people());}
    @GetMapping("/deptTree") public AjaxResult deptTree(){return AjaxResult.success(service.departmentTree());}
    @GetMapping("/list")
    public AjaxResult list(@RequestParam Map<String,String> params) {
        int page=integer(params.get("pageNum"),1),size=integer(params.get("pageSize"),20);
        if(page<1 || page>1000000 || size<1 || size>5000) throw new ServiceException("分页范围不正确");
        return AjaxResult.success(service.list(params,page,size));
    }
    private int integer(String value,int fallback){try{return value==null?fallback:Integer.parseInt(value);}catch(NumberFormatException e){throw new ServiceException("分页参数不正确");}}
    @GetMapping("/{id:\\d+}")
    public AjaxResult detail(@PathVariable long id){Map<String,Object> result=service.detail(id);service.audit("view","achievement",id,"");return AjaxResult.success(result);}
    @PostMapping public AjaxResult create(@RequestBody Map<String,Object> body){return AjaxResult.success(Map.of("id",service.save(body,null)));}
    @PutMapping("/{id:\\d+}") public AjaxResult update(@PathVariable long id,@RequestBody Map<String,Object> body){return AjaxResult.success(Map.of("id",service.save(body,id)));}
    @DeleteMapping public AjaxResult delete(@RequestBody Map<String,Object> body){service.delete(AchievementService.ids(body.get("ids")));return AjaxResult.success();}
    @PutMapping("/sort") public AjaxResult sort(@RequestBody Map<String,Object> body){service.sort(AchievementService.text(body.get("categoryCode")),AchievementService.ids(body.get("ids")));return AjaxResult.success();}
    @GetMapping("/profile/{userId}") public AjaxResult profile(@PathVariable long userId){return AjaxResult.success(service.profile(userId));}
    @PutMapping("/profile/{userId}") public AjaxResult profileSave(@PathVariable long userId,@RequestBody Map<String,Object> body){service.saveProfile(userId,body);return AjaxResult.success();}
    @PostMapping("/attachments")
    public AjaxResult upload(@RequestParam MultipartFile file,@RequestParam int targetType,@RequestParam(required=false) Long achievementId,@RequestParam(required=false) Long profileUserId) throws Exception {
        return AjaxResult.success(files.upload(file,targetType,achievementId,profileUserId));
    }
    @DeleteMapping("/attachments/{id}") public AjaxResult attachmentDelete(@PathVariable long id){files.delete(id);return AjaxResult.success();}
    @GetMapping("/attachments/{id}/download") public void download(@PathVariable long id,HttpServletResponse response) throws Exception {
        Map<String,Object> file=files.readable(id);service.audit("download","attachment",id,"");
        String name=file.get("original_name").toString();
        if("image/jpeg".equals(file.get("mime_type"))) name=name.replaceFirst("(?i)\\.(png|jpg|jpeg)$","")+".jpg";
        stream(response,file.get("storage_key").toString(),name,file.get("mime_type").toString());
    }
    @PostMapping("/export/{type}") public AjaxResult export(@PathVariable int type,@RequestBody Map<String,Object> body) throws Exception {return AjaxResult.success(exports.create(type,body));}
    @GetMapping("/export/tasks") public AjaxResult exportTasks(){return AjaxResult.success(exports.tasks());}
    @DeleteMapping("/export/tasks/{id}") public AjaxResult exportTaskDelete(@PathVariable long id) throws Exception {exports.delete(id);return AjaxResult.success();}
    @GetMapping("/export/{id}/download") public void exportDownload(@PathVariable long id,HttpServletResponse response) throws Exception {
        Map<String,Object> task=exports.download(id);String key=task.get("storage_key").toString();
        service.audit("download","export_task",id,"");stream(response,key,task.get("file_name").toString(),"application/octet-stream");
    }
    @PostMapping("/recognize") public AjaxResult recognize(@RequestParam String categoryCode,@RequestParam MultipartFile file) throws Exception {
        var result=recognition.recognize(categoryCode,file);service.audit("create","recognition",service.getAccess().userId(),categoryCode);return AjaxResult.success(result);
    }
    private void stream(HttpServletResponse response,String key,String name,String mime) throws Exception {
        Path path=files.resolve(key);
        if(!Files.isRegularFile(path)) throw new ServiceException("附件文件不存在，请联系管理员",404);
        response.setContentType(mime);response.setHeader("X-Content-Type-Options","nosniff");response.setHeader("Cache-Control","no-store");
        FileUtils.setAttachmentResponseHeader(response,name);response.setContentLengthLong(Files.size(path));Files.copy(path,response.getOutputStream());
    }
}
