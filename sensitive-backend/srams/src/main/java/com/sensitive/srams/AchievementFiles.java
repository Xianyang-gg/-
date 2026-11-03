package com.sensitive.srams;

import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.*;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;
import javax.imageio.*;
import javax.imageio.stream.ImageInputStream;
import com.sensitive.common.config.SensitiveConfig;
import com.sensitive.common.exception.ServiceException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
public class AchievementFiles {
    private final AchievementService service;
    private final AchievementAccess access;
    @Value("${achievement.storage-root:}") private String storageRoot;
    public AchievementFiles(AchievementService service,AchievementAccess access) { this.service=service;this.access=access; }
    Path root() throws IOException {
        Path publicRoot=Path.of(SensitiveConfig.getProfile()).toAbsolutePath().normalize();
        Path root=storageRoot.isBlank()?publicRoot.resolveSibling(publicRoot.getFileName()+"-achievement-private"):Path.of(storageRoot).toAbsolutePath().normalize();
        if(root.startsWith(publicRoot)) throw new ServiceException("成果私有目录不能位于公开上传目录内");
        Files.createDirectories(root);return root;
    }
    public Path resolve(String key) throws IOException {
        Path root=root(),file=root.resolve(key).normalize();
        if(!file.startsWith(root) || file.equals(root)) throw new ServiceException("无效文件路径");
        return file;
    }
    public Map<String,Object> readable(long id) {
        Map<String,Object> row=service.one("SELECT * FROM zs_attachment WHERE id=? AND deleted=0",id);
        if(((Number)row.get("target_type")).intValue()==1) service.readable(AchievementService.number(row.get("achievement_id")));
        else access.requireProfileRead(AchievementService.number(row.get("profile_user_id")));
        return row;
    }
    @Transactional(rollbackFor=Exception.class)
    public Map<String,Object> upload(MultipartFile file,int type,Long achievementId,Long profileId) throws Exception {
        if(type<1 || type>4) throw new ServiceException("无效的附件类型");
        if(file.isEmpty() || file.getSize()>10L*1024*1024) throw new ServiceException("请选择不超过10MB的图片或PDF");
        String original=Objects.requireNonNullElse(file.getOriginalFilename(),"附件").replace('\\','/');
        original=original.substring(original.lastIndexOf('/')+1);
        if(original.isBlank() || original.length()>255) throw new ServiceException("附件名称无效或超过255个字符");
        String ext=original.substring(original.lastIndexOf('.')+1).toLowerCase(Locale.ROOT);
        boolean image=Set.of("jpg","jpeg","png").contains(ext);
        if(!image && !ext.equals("pdf")) throw new ServiceException("仅支持 JPG、PNG 和 PDF");
        if(type==1) {
            if(achievementId==null) throw new ServiceException("请先保存成果");
            service.one("SELECT id FROM zs_achievement WHERE id=? AND deleted=0 FOR UPDATE",achievementId);
            access.requireEdit(service.readable(achievementId)); profileId=null;
            long count=Objects.requireNonNull(service.getJdbcTemplate().queryForObject("SELECT COUNT(*) FROM zs_attachment WHERE achievement_id=? AND deleted=0",Long.class,achievementId));
            if(count>=20) throw new ServiceException("每条成果最多20个附件");
            if(image && Objects.requireNonNull(service.getJdbcTemplate().queryForObject("SELECT COUNT(*) FROM zs_attachment WHERE achievement_id=? AND deleted=0 AND mime_type LIKE 'image/%'",Long.class,achievementId))>=2) throw new ServiceException("每条成果最多2张佐证图片");
        } else {
            if(profileId==null) profileId=access.userId();
            access.requireProfileEdit(profileId);
            service.one("SELECT user_id FROM sys_user WHERE user_id=? AND del_flag='0' FOR UPDATE",profileId);
            achievementId=null;
            if(Objects.requireNonNull(service.getJdbcTemplate().queryForObject("SELECT COUNT(*) FROM zs_attachment WHERE profile_user_id=? AND deleted=0",Long.class,profileId))>=20) throw new ServiceException("个人证件附件最多20个");
        }
        byte[] bytes=file.getBytes();
        String mime;
        if(image) {bytes=compress(bytes);ext="jpg";mime="image/jpeg";}
        else {if(bytes.length<5 || !new String(bytes,0,5,java.nio.charset.StandardCharsets.US_ASCII).equals("%PDF-")) throw new ServiceException("PDF文件格式不正确");mime="application/pdf";}
        if(bytes.length>3*1024*1024) throw new ServiceException("附件处理后仍超过3MB，请压缩后重试");
        String key="evidence/"+java.time.LocalDate.now()+"/"+UUID.randomUUID()+"."+ext;
        Path target=resolve(key);Files.createDirectories(target.getParent());Files.write(target,bytes,StandardOpenOption.CREATE_NEW);
        try {
            long id=service.insert("INSERT INTO zs_attachment(uploader_id,target_type,achievement_id,profile_user_id,original_name,storage_key,file_size,mime_type,file_ext,content_sha256) VALUES(?,?,?,?,?,?,?,?,?,?)",access.userId(),type,achievementId,profileId,original,key,bytes.length,mime,ext,HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(bytes)));
            service.audit("create","attachment",id,original);
            return Map.of("id",id,"original_name",original,"file_size",bytes.length);
        } catch(Exception ex){Files.deleteIfExists(target);throw ex;}
    }
    private byte[] compress(byte[] bytes) throws IOException {
        try(ImageInputStream input=ImageIO.createImageInputStream(new ByteArrayInputStream(bytes))) {
            Iterator<ImageReader> readers=ImageIO.getImageReaders(input);
            if(!readers.hasNext()) throw new ServiceException("无法解析图片");
            ImageReader reader=readers.next();
            try {
                reader.setInput(input);
                int w=reader.getWidth(0),h=reader.getHeight(0);
                if(w<=0 || h<=0 || (long)w*h>40_000_000) throw new ServiceException("图片分辨率过高，请缩小后重试");
                BufferedImage source=reader.read(0);
                double scale=Math.min(1.0,2400.0/Math.max(w,h));
                BufferedImage output=new BufferedImage(Math.max(1,(int)(w*scale)),Math.max(1,(int)(h*scale)),BufferedImage.TYPE_INT_RGB);
                Graphics2D graphics=output.createGraphics();
                try {graphics.setColor(Color.WHITE);graphics.fillRect(0,0,output.getWidth(),output.getHeight());graphics.setRenderingHint(RenderingHints.KEY_INTERPOLATION,RenderingHints.VALUE_INTERPOLATION_BICUBIC);graphics.drawImage(source,0,0,output.getWidth(),output.getHeight(),null);}finally{graphics.dispose();}
                ByteArrayOutputStream result=new ByteArrayOutputStream();ImageIO.write(output,"jpg",result);return result.toByteArray();
            } finally {reader.dispose();}
        }
    }
    @Transactional(rollbackFor=Exception.class)
    public void delete(long id) {
        Map<String,Object> row=readable(id);
        if(((Number)row.get("target_type")).intValue()==1) {
            long achievementId=AchievementService.number(row.get("achievement_id"));
            service.one("SELECT id FROM zs_achievement WHERE id=? FOR UPDATE",achievementId);
            access.requireEdit(service.readable(achievementId));
        } else access.requireProfileEdit(AchievementService.number(row.get("profile_user_id")));
        service.getJdbcTemplate().update("UPDATE zs_attachment SET deleted=1 WHERE id=?",id);
        service.audit("delete","attachment",id,"");
    }
}
