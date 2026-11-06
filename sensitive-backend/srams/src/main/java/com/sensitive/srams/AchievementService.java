package com.sensitive.srams;

import java.sql.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;
import javax.sql.DataSource;
import com.sensitive.common.core.domain.TreeSelect;
import com.sensitive.common.exception.ServiceException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AchievementService {
    final JdbcTemplate db;
    final AchievementAccess access;
    static final RowMapper<Map<String,Object>> ROW = (rs,n) -> {
        Map<String,Object> row = new LinkedHashMap<>();
        for (int i=1;i<=rs.getMetaData().getColumnCount();i++) {
            Object v=rs.getObject(i);
            if (v instanceof java.sql.Date d) v=d.toLocalDate().toString();
            else if (v instanceof Timestamp t) v=t.toLocalDateTime().toString();
            row.put(rs.getMetaData().getColumnLabel(i).toLowerCase(Locale.ROOT),v);
        }
        return row;
    };
    public AchievementService(DataSource source, AchievementAccess access) {
        this.db=new JdbcTemplate(source); this.access=access;
    }
    public AchievementAccess getAccess() { return access; }
    public JdbcTemplate getJdbcTemplate() { return db; }
    public List<Map<String,Object>> rows(String sql,Object... args) { return db.query(sql,ROW,args); }
    public Map<String,Object> one(String sql,Object... args) {
        List<Map<String,Object>> result=rows(sql,args);
        if(result.isEmpty()) throw new ServiceException("记录不存在",404);
        return result.get(0);
    }
    public long insert(String sql,Object... args) {
        GeneratedKeyHolder holder=new GeneratedKeyHolder();
        db.update(connection -> {
            PreparedStatement ps=connection.prepareStatement(sql,Statement.RETURN_GENERATED_KEYS);
            for(int i=0;i<args.length;i++) ps.setObject(i+1,args[i]);
            return ps;
        },holder);
        return Objects.requireNonNull(holder.getKey()).longValue();
    }
    public static long number(Object n) {
        try { long id=Long.parseLong(String.valueOf(n)); if(id<=0) throw new NumberFormatException(); return id; }
        catch(RuntimeException ex) { throw new ServiceException("无效的记录编号"); }
    }
    public static String text(Object value) { return value==null ? "" : value.toString().trim(); }
    private static String required(Object value,String label,int max) {
        String s=text(value);
        if(s.isBlank() || s.length()>max) throw new ServiceException(label+"必填且不能超过"+max+"个字符");
        return s;
    }
    private static String date(Object value) {
        String s=text(value); if(s.isEmpty()) return null;
        try{return LocalDate.parse(s).toString();}catch(RuntimeException e){throw new ServiceException("日期格式应为 yyyy-MM-dd");}
    }
    public static List<Long> ids(Object value) {
        if(value==null) return List.of();
        Collection<?> values=value instanceof Collection<?> c ? c : Arrays.asList(text(value).split(","));
        if(values.size()>5000) throw new ServiceException("一次最多处理5000条成果");
        return values.stream().filter(v->!text(v).isEmpty()).map(AchievementService::number).distinct().toList();
    }
    public static boolean summary(Map<String,?> params) { return "summary".equals(text(params.get("scope"))); }
    record Filter(String where, List<Object> args) {}
    Filter filter(Map<String,?> params) {
        StringBuilder sql=new StringBuilder(" WHERE a.deleted=0");
        List<Object> args=new ArrayList<>();
        if(!access.collegeRead()) {
            sql.append(" AND (a.owner_id=? OR (a.category_code NOT IN ('project_major','project_research','project_horizontal','project_student') AND EXISTS (SELECT 1 FROM zs_achievement_member am WHERE am.achievement_id=a.id AND am.user_id=?)))");
            args.add(access.userId());args.add(access.userId());
        }
        if(!text(params.get("personId")).isEmpty()) {
            long person=number(params.get("personId"));
            sql.append(" AND (a.owner_id=? OR (a.category_code NOT IN ('project_major','project_research','project_horizontal','project_student') AND EXISTS (SELECT 1 FROM zs_achievement_member pm WHERE pm.achievement_id=a.id AND pm.user_id=?)))");
            args.add(person);args.add(person);
        }
        List<Long> owners=ids(params.get("ownerIds"));
        if(!owners.isEmpty()) {
            sql.append(" AND a.owner_id IN (").append(placeholders(owners.size())).append(")");args.addAll(owners);
        }
        if(!text(params.get("categoryCode")).isEmpty()) {
            sql.append(" AND a.category_code=?");args.add(AchievementCatalog.get(text(params.get("categoryCode"))).code());
        }
        Object categoryValues=params.get("categoryCodes");
        Collection<?> categoryItems=categoryValues instanceof Collection<?> c?c:Arrays.asList(text(categoryValues).split(","));
        if(categoryItems.size()>AchievementCatalog.ALL.size()) throw new ServiceException("业务范围数量不正确");
        List<String> categories=categoryItems.stream().map(AchievementService::text).filter(s->!s.isEmpty()).map(s->AchievementCatalog.get(s).code()).distinct().toList();
        if(!categories.isEmpty()) {
            sql.append(" AND a.category_code IN (").append(placeholders(categories.size())).append(")");args.addAll(categories);
        }
        if(!text(params.get("categoryGroup")).isEmpty()) {
            List<String> groupCategories=AchievementCatalog.ALL.stream().filter(c->c.group().equals(text(params.get("categoryGroup")))).map(AchievementCatalog.Category::code).toList();
            if(groupCategories.isEmpty()) throw new ServiceException("无效的业务模块");
            sql.append(" AND a.category_code IN (").append(placeholders(groupCategories.size())).append(")");args.addAll(groupCategories);
        }
        if(!text(params.get("keyword")).isEmpty()) {
            sql.append(" AND a.name LIKE ?");args.add("%"+text(params.get("keyword"))+"%");
        }
        if(!text(params.get("ownerId")).isEmpty()) {
            sql.append(" AND a.owner_id=?");args.add(number(params.get("ownerId")));
        }
        if(!text(params.get("majorDeptId")).isEmpty()) {
            long department=number(params.get("majorDeptId"));
            sql.append(" AND EXISTS (SELECT 1 FROM sys_dept fd WHERE fd.dept_id=a.major_dept_id AND (fd.dept_id=? OR CONCAT(',',fd.ancestors,',') LIKE ?))");
            args.add(department);args.add("%,"+department+",%");
        }
        Object levelValues=params.get("levelCode");
        Collection<?> levelItems=levelValues instanceof Collection<?> c?c:Arrays.asList(text(levelValues).split(","));
        List<String> levels=levelItems.stream().map(AchievementService::text).filter(s->!s.isEmpty()).distinct().toList();
        if(!levels.isEmpty()) {
            sql.append(" AND a.level_code IN (").append(placeholders(levels.size())).append(")");args.addAll(levels);
        }
        if(!text(params.get("memberName")).isEmpty()) {
            sql.append(" AND EXISTS (SELECT 1 FROM zs_achievement_member fm WHERE fm.achievement_id=a.id AND fm.member_name LIKE ?)");
            args.add("%"+text(params.get("memberName"))+"%");
        }
        if(!text(params.get("categoryCode")).isEmpty()) {
            var category=AchievementCatalog.get(text(params.get("categoryCode")));
            StringBuilder detailSql=new StringBuilder();
            for(var field:category.fields()) {
                String key="detail_"+field.key(),column="fd."+field.key();
                switch(field.type()) {
                    case "date" -> appendRange(detailSql,args,column,field,params.get(key+"Start"),params.get(key+"End"));
                    case "money", "number" -> appendRange(detailSql,args,column,field,params.get(key+"Min"),params.get(key+"Max"));
                    default -> {
                        if(!text(params.get(key)).isEmpty()) {
                            boolean exact="select".equals(field.type());
                            detailSql.append(" AND ").append(column).append(exact?"=?":" LIKE ?");
                            args.add(exact?field.validate(params.get(key)):"%"+text(params.get(key))+"%");
                        }
                    }
                }
            }
            if(!detailSql.isEmpty()) sql.append(" AND EXISTS (SELECT 1 FROM ").append(category.table())
                .append(" fd WHERE fd.achievement_id=a.id").append(detailSql).append(")");
        }
        String start=date(params.get("startDate")),end=date(params.get("endDate"));
        if(start!=null && end!=null && start.compareTo(end)>0) throw new ServiceException("开始日期不能晚于结束日期");
        if(start!=null){sql.append(" AND a.achieved_date>=?");args.add(start);}
        if(end!=null){sql.append(" AND a.achieved_date<=?");args.add(end);}
        List<Long> selected=ids(params.get("ids"));
        if(!selected.isEmpty()) {
            sql.append(" AND a.id IN (").append(placeholders(selected.size())).append(")");args.addAll(selected);
        }
        return new Filter(sql.toString(),args);
    }
    private static void appendRange(StringBuilder sql,List<Object> args,String column,AchievementCatalog.Field field,Object min,Object max) {
        Object lower=field.validate(min),upper=field.validate(max);
        if(lower!=null && upper!=null) {
            int order="date".equals(field.type())?lower.toString().compareTo(upper.toString()):new BigDecimal(lower.toString()).compareTo(new BigDecimal(upper.toString()));
            if(order>0) throw new ServiceException(field.label()+"的起始值不能大于结束值");
        }
        if(lower!=null){sql.append(" AND ").append(column).append(">=?");args.add(lower);}
        if(upper!=null){sql.append(" AND ").append(column).append("<=?");args.add(upper);}
    }
    static String placeholders(int size) { return String.join(",",Collections.nCopies(size,"?")); }
    private String exportOrder(Map<String,?> params) {
        return switch(text(params.get("sort"))){
            case "owner" -> "u.nick_name,a.achieved_date DESC,a.id DESC";
            case "custom" -> "CASE WHEN s.sort_num IS NULL THEN 1 ELSE 0 END,s.sort_num,a.achieved_date DESC,a.id DESC";
            default -> "a.achieved_date DESC,a.id DESC";
        };
    }
    /** 仅查询有权导出的ID，固定提交时的范围及顺序，不加载整批详情。 */
    public List<Long> exportIds(Map<String,?> params) {
        Filter f=filter(params);
        List<Object> args=new ArrayList<>();args.add(access.userId());args.addAll(f.args());
        String sortCategory=summary(params)?"'summary'":"a.category_code";
        List<Long> result=rows("SELECT a.id FROM zs_achievement a LEFT JOIN sys_user u ON u.user_id=a.owner_id "
            +"LEFT JOIN zs_achievement_sort s ON s.achievement_id=a.id AND s.user_id=? AND s.category_code="+sortCategory+" AND s.sort_year=0"
            +f.where()+" ORDER BY "+exportOrder(params)+" LIMIT 5001",args.toArray()).stream().map(r->number(r.get("id"))).toList();
        if(result.size()>5000) throw new ServiceException("一次最多导出5000条成果，请缩小筛选范围");
        List<Long> selected=ids(params.get("ids"));
        if(!selected.isEmpty() && !new HashSet<>(result).equals(new HashSet<>(selected)))
            throw new ServiceException("部分成果不存在或无权访问，请刷新后重试",403);
        return result;
    }
    /** 下载及生成均按当前权限批量校验，避免逐条查询。 */
    public void requireExportReadable(List<Long> ids) {
        for(int offset=0;offset<ids.size();offset+=500) {
            List<Long> batch=ids.subList(offset,Math.min(offset+500,ids.size()));
            Filter f=filter(Map.of("ids",batch));
            long count=Objects.requireNonNull(db.queryForObject("SELECT COUNT(*) FROM zs_achievement a"+f.where(),Long.class,f.args().toArray()));
            if(count!=batch.size()) throw new ServiceException("部分成果已删除或无权访问，请重新提交导出",403);
        }
    }
    /** 每500条一批，主表、人员、附件及各类别明细分别批量读取，保留快照顺序。 */
    @SuppressWarnings("unchecked")
    public List<Map<String,Object>> exportRecords(List<Long> ids) {
        List<Map<String,Object>> result=new ArrayList<>();
        for(int offset=0;offset<ids.size();offset+=500) {
            List<Long> batch=ids.subList(offset,Math.min(offset+500,ids.size()));
            Filter f=filter(Map.of("ids",batch));
            Map<Long,Map<String,Object>> byId=new HashMap<>();
            for(Map<String,Object> row:rows("SELECT a.*,u.nick_name AS owner_name,d.dept_name AS major_name FROM zs_achievement a "
                +"LEFT JOIN sys_user u ON u.user_id=a.owner_id LEFT JOIN sys_dept d ON d.dept_id=a.major_dept_id"+f.where(),f.args().toArray())) {
                row.put("detail",Map.of());row.put("members",new ArrayList<Map<String,Object>>());row.put("attachments",new ArrayList<Map<String,Object>>());
                byId.put(number(row.get("id")),row);
            }
            if(byId.size()!=batch.size()) throw new ServiceException("部分成果已删除或无权访问，请重新提交导出",403);
            String in=placeholders(batch.size());Object[] args=batch.toArray();
            for(Map<String,Object> member:rows("SELECT achievement_id,user_id,member_name,member_role FROM zs_achievement_member WHERE achievement_id IN ("+in+") ORDER BY sort_num,id",args))
                ((List<Map<String,Object>>)byId.get(number(member.get("achievement_id"))).get("members")).add(member);
            for(Map<String,Object> attachment:rows("SELECT id,achievement_id,original_name,file_size,mime_type,file_ext,sort_num,storage_key FROM zs_attachment WHERE deleted=0 AND achievement_id IN ("+in+") ORDER BY sort_num,id",args))
                ((List<Map<String,Object>>)byId.get(number(attachment.get("achievement_id"))).get("attachments")).add(attachment);
            for(var category:AchievementCatalog.ALL) {
                List<Long> categoryIds=batch.stream().filter(id->category.code().equals(byId.get(id).get("category_code"))).toList();
                if(categoryIds.isEmpty()) continue;
                for(Map<String,Object> detail:rows("SELECT * FROM "+category.table()+" WHERE achievement_id IN ("+placeholders(categoryIds.size())+")",categoryIds.toArray()))
                    byId.get(number(detail.get("achievement_id"))).put("detail",detail);
            }
            for(Long id:batch) {
                Map<String,Object> row=byId.get(id);
                if(((List<?>)row.get("attachments")).isEmpty()) throw new ServiceException("成果“"+row.get("name")+"”缺少佐证材料，请补充后导出");
                result.add(row);
            }
        }
        return result;
    }
    public Map<String,Object> list(Map<String,?> params,int page,int size) {
        Filter f=filter(params);
        AchievementCatalog.Category category=text(params.get("categoryCode")).isEmpty()?null:AchievementCatalog.get(text(params.get("categoryCode")));
        String detailColumns=category==null?"":category.fields().stream().map(field->",dt."+field.key()+" AS detail_"+field.key()).collect(Collectors.joining());
        String detailJoin=category==null?"":" LEFT JOIN "+category.table()+" dt ON dt.achievement_id=a.id ";
        long count=Objects.requireNonNull(db.queryForObject("SELECT COUNT(*) FROM zs_achievement a"+f.where(),Long.class,f.args().toArray()));
        List<Object> args=new ArrayList<>(); args.add(access.userId()); args.addAll(f.args());args.add(size);args.add((page-1)*size);
        String order=exportOrder(params);
        String sortCategory=summary(params)?"'summary'":"a.category_code";
        List<Map<String,Object>> records=rows("SELECT a.*,u.nick_name AS owner_name,d.dept_name AS major_name"+detailColumns+","
            +"(SELECT COUNT(*) FROM zs_attachment f WHERE f.achievement_id=a.id AND f.deleted=0) AS attachment_count "
            +"FROM zs_achievement a LEFT JOIN sys_user u ON u.user_id=a.owner_id LEFT JOIN sys_dept d ON d.dept_id=a.major_dept_id "
            +"LEFT JOIN zs_achievement_sort s ON s.achievement_id=a.id AND s.user_id=? AND s.category_code="+sortCategory+" AND s.sort_year=0"+detailJoin
            +f.where()+" ORDER BY "+order+" LIMIT ? OFFSET ?",args.toArray());
        records.forEach(r->{
            r.put("can_edit",access.canEdit(r));
            if(category!=null){Map<String,Object> detail=new LinkedHashMap<>();category.fields().forEach(field->detail.put(field.key(),r.remove("detail_"+field.key())));r.put("detail",detail);}
            r.put("members",new ArrayList<Map<String,Object>>());
        });
        if(!records.isEmpty() && (category==null || !category.code().startsWith("project_"))) {
            Map<Long,Map<String,Object>> byId=records.stream().collect(Collectors.toMap(r->number(r.get("id")),r->r));
            for(Map<String,Object> member:rows("SELECT achievement_id,user_id,member_name,member_role FROM zs_achievement_member WHERE achievement_id IN ("+placeholders(records.size())+") ORDER BY sort_num,id",records.stream().map(r->r.get("id")).toArray())) {
                @SuppressWarnings("unchecked") List<Map<String,Object>> members=(List<Map<String,Object>>)byId.get(number(member.get("achievement_id"))).get("members");members.add(member);
            }
        }
        return Map.of("rows",records,"total",count);
    }
    public Map<String,Object> readable(long id) {
        Map<String,Object> row=one("SELECT a.*,u.nick_name AS owner_name,d.dept_name AS major_name FROM zs_achievement a LEFT JOIN sys_user u ON u.user_id=a.owner_id LEFT JOIN sys_dept d ON d.dept_id=a.major_dept_id WHERE a.id=? AND a.deleted=0",id);
        if(!access.collegeRead() && number(row.get("owner_id"))!=access.userId()
            && (text(row.get("category_code")).startsWith("project_") || Objects.requireNonNull(db.queryForObject("SELECT COUNT(*) FROM zs_achievement_member WHERE achievement_id=? AND user_id=?",Long.class,id,access.userId()))==0))
            throw new ServiceException("无权查看该成果",403);
        return row;
    }
    public Map<String,Object> detail(long id) {
        Map<String,Object> row=readable(id);
        AchievementCatalog.Category c=AchievementCatalog.get(text(row.get("category_code")));
        List<Map<String,Object>> details=rows("SELECT * FROM "+c.table()+" WHERE achievement_id=?",id);
        row.put("detail",details.isEmpty()?Map.of():details.get(0));
        row.put("members",rows("SELECT id,user_id,member_name,member_role,sort_num FROM zs_achievement_member WHERE achievement_id=? ORDER BY sort_num,id",id));
        row.put("attachments",attachments(id));
        row.put("can_edit",access.canEdit(row));
        return row;
    }
    public List<Map<String,Object>> attachments(long id) {
        return rows("SELECT id,original_name,file_size,mime_type,file_ext,sort_num FROM zs_attachment WHERE achievement_id=? AND deleted=0 ORDER BY sort_num,id",id);
    }
    public List<Map<String,Object>> people() {
        return rows("SELECT u.user_id,u.nick_name AS name,u.dept_id,d.dept_name FROM sys_user u LEFT JOIN sys_dept d ON d.dept_id=u.dept_id WHERE u.del_flag='0' AND u.status='0' ORDER BY u.nick_name,u.user_id");
    }
    public List<TreeSelect> departmentTree() {
        // 筛选保留停用部门，便于检索历史成果；成果数据仍由 filter 统一校验权限。
        List<Map<String,Object>> departments=rows("SELECT dept_id,parent_id,dept_name FROM sys_dept WHERE del_flag='0' ORDER BY parent_id,order_num,dept_id");
        Map<Long,TreeSelect> nodes=new LinkedHashMap<>();
        for(var department:departments) {
            var node=new TreeSelect();node.setId(number(department.get("dept_id")));node.setLabel(text(department.get("dept_name")));node.setChildren(new ArrayList<>());
            nodes.put(node.getId(),node);
        }
        List<TreeSelect> roots=new ArrayList<>();
        for(var department:departments) {
            var node=nodes.get(number(department.get("dept_id")));
            Object parentId=department.get("parent_id");
            var parent=parentId==null?null:nodes.get(((Number)parentId).longValue());
            if(parent==null) roots.add(node);else parent.getChildren().add(node);
        }
        return roots;
    }
    @Transactional(rollbackFor=Exception.class)
    public long save(Map<String,Object> data,Long id) {
        access.requireCreate();
        AchievementCatalog.Category c=AchievementCatalog.get(text(data.get("category_code")));
        boolean project=c.code().startsWith("project_");
        if(project && data.get("members") instanceof Collection<?> members && !members.isEmpty()) throw new ServiceException("项目仅维护负责人，无需录入成员");
        Map<String,Object> previous=null;
        if(id!=null){ previous=readable(id);access.requireEdit(previous);
            if(!c.code().equals(previous.get("category_code"))) throw new ServiceException("修改时不能更改成果类别");
        }
        long owner=number(data.get("owner_id"));
        if(!access.admin() && owner!=access.userId()) throw new ServiceException("只能为本人录入成果",403);
        Map<String,Object> user=one("SELECT user_id,dept_id,nick_name FROM sys_user WHERE user_id=? AND del_flag='0' AND status='0'",owner);
        long dept=number(user.get("dept_id"));
        String name=required(data.get("name"),"成果名称",255);
        Map<?,?> values=data.get("detail") instanceof Map<?,?> m ? m : Map.of();
        Object eventDate=project?values.get(c.code().equals("project_horizontal")?"start_date":c.code().equals("project_student")?"grant_date":"apply_date"):data.get("achieved_date");
        String achieved=date(eventDate);
        if(achieved==null) throw new ServiceException(project?"请选择立项时间":"请选择成果日期");
        String level=text(data.get("level_code")),remark=text(data.get("remark"));
        if(level.length()>64 || remark.length()>1000) throw new ServiceException("级别或备注过长");
        if(id==null) id=insert("INSERT INTO zs_achievement(category_code,name,owner_id,major_dept_id,level_code,achieved_date,remark,created_by) VALUES(?,?,?,?,?,?,?,?)",c.code(),name,owner,dept,level,achieved,remark,access.userId());
        else db.update("UPDATE zs_achievement SET name=?,owner_id=?,major_dept_id=?,level_code=?,achieved_date=?,remark=? WHERE id=?",name,owner,dept,level,achieved,remark,id);
        Map<String,Object> checked=new LinkedHashMap<>();
        for(AchievementCatalog.Field f:c.fields()) checked.put(f.key(),f.validate(values.get(f.key())));
        validateDates(checked);
        db.update("DELETE FROM "+c.table()+" WHERE achievement_id=?",id);
        List<Object> detailArgs=new ArrayList<>();detailArgs.add(id);detailArgs.addAll(checked.values());
        db.update("INSERT INTO "+c.table()+"(achievement_id,"+String.join(",",checked.keySet())+") VALUES("+placeholders(detailArgs.size())+")",detailArgs.toArray());
        Object memberObject=data.get("members");
        if(memberObject!=null && !(memberObject instanceof List<?>)) throw new ServiceException("参与人员格式不正确");
        List<?> members=memberObject instanceof List<?> l?l:List.of();
        if(members.size()>200) throw new ServiceException("单条成果最多200名参与人员");
        if(!project) db.update("DELETE FROM zs_achievement_member WHERE achievement_id=?",id);
        Set<String> seen=new HashSet<>(); int order=0;
        for(Object item:members) {
            if(!(item instanceof Map<?,?> member)) throw new ServiceException("参与人员格式不正确");
            String role=required(member.get("member_role"),"人员角色",32);
            if(!Set.of("member","student","supervisor","participant","author","first_author","editor","co_editor","inventor","winner","accompany","lecturer").contains(role)) throw new ServiceException("无效的人员角色");
            Long uid=text(member.get("user_id")).isEmpty()?null:number(member.get("user_id"));
            String memberName=uid==null?required(member.get("member_name"),"参与人姓名",100):text(one("SELECT nick_name FROM sys_user WHERE user_id=? AND del_flag='0' AND status='0'",uid).get("nick_name"));
            if(!seen.add((uid==null?memberName:uid.toString())+":"+role)) throw new ServiceException("同一人员的相同角色不能重复");
            db.update("INSERT INTO zs_achievement_member(achievement_id,user_id,member_name,member_role,sort_num) VALUES(?,?,?,?,?)",id,uid,memberName,role,order++);
        }
        audit(previous==null?"create":"update","achievement",id,name);
        return id;
    }
    private void validateDates(Map<String,Object> values) {
        for(String[] pair:List.of(new String[]{"apply_date","finish_date"},new String[]{"apply_date","grant_date"},new String[]{"grant_date","finish_date"},new String[]{"start_date","end_date"},new String[]{"start_date","finish_date"})) {
            Object a=values.get(pair[0]),b=values.get(pair[1]);
            if(a!=null && b!=null && a.toString().compareTo(b.toString())>0) throw new ServiceException("结束或授权日期不能早于开始或申请日期");
        }
    }
    @Transactional(rollbackFor=Exception.class)
    public void delete(List<Long> ids) {
        if(ids.isEmpty()) throw new ServiceException("请选择成果");
        Map<Long,Map<String,Object>> records=new LinkedHashMap<>();
        for(long id:ids.stream().distinct().sorted().toList()) {
            one("SELECT id FROM zs_achievement WHERE id=? AND deleted=0 FOR UPDATE",id);
            Map<String,Object> row=readable(id);access.requireEdit(row);records.put(id,row);
        }
        for(var entry:records.entrySet()) {
            long id=entry.getKey();Map<String,Object> row=entry.getValue();
            AchievementCatalog.Category category=AchievementCatalog.get(text(row.get("category_code")));
            db.update("DELETE FROM "+category.table()+" WHERE achievement_id=?",id);
            db.update("DELETE FROM zs_achievement_member WHERE achievement_id=?",id);
            db.update("DELETE FROM zs_achievement_sort WHERE achievement_id=?",id);
            db.update("DELETE FROM zs_attachment WHERE achievement_id=?",id);
            db.update("DELETE FROM zs_achievement WHERE id=?",id);
            audit("delete","achievement",id,text(row.get("name")));
        }
    }
    @Transactional(rollbackFor=Exception.class)
    public void sort(String category,List<Long> ids) {
        boolean summary="summary".equals(category);
        if(!summary) AchievementCatalog.get(category);
        if(ids.isEmpty()) throw new ServiceException("请先选择要排序的成果");
        for(long id:ids) {
            Map<String,Object> row=readable(id);
            if(!summary && !category.equals(row.get("category_code"))) throw new ServiceException("只能对同一类别的成果排序");
        }
        List<Long> ordered=ids;
        if(summary) {
            // 筛选后排序只调整选中记录的相对顺序，保留其他记录的位置。
            ordered=new ArrayList<>(rows("SELECT achievement_id FROM zs_achievement_sort WHERE user_id=? AND category_code=? AND sort_year=0 ORDER BY sort_num,id",access.userId(),category).stream().map(r->number(r.get("achievement_id"))).toList());
            Set<Long> existing=new HashSet<>(ordered),selected=new HashSet<>(ids);
            for(long id:ids) if(!existing.contains(id)) ordered.add(id);
            Iterator<Long> replacement=ids.iterator();
            for(int i=0;i<ordered.size();i++) if(selected.contains(ordered.get(i))) ordered.set(i,replacement.next());
        }
        db.update("DELETE FROM zs_achievement_sort WHERE user_id=? AND category_code=? AND sort_year=0",access.userId(),category);
        int n=0; for(long id:ordered) db.update("INSERT INTO zs_achievement_sort(user_id,category_code,sort_year,achievement_id,sort_num) VALUES(?,?,0,?,?)",access.userId(),category,id,n++);
    }
    public Map<String,Object> profile(long id) {
        access.requireProfileRead(id);
        Map<String,Object> base=one("SELECT user_id,nick_name AS real_name,dept_id AS major_dept_id FROM sys_user WHERE user_id=? AND del_flag='0'",id);
        List<Map<String,Object>> stored=rows("SELECT * FROM zs_teacher_profile WHERE user_id=?",id);
        if(!stored.isEmpty()) base.putAll(stored.get(0));
        base.put("attachments",rows("SELECT id,target_type,original_name,file_size,mime_type,file_ext FROM zs_attachment WHERE profile_user_id=? AND deleted=0 ORDER BY target_type,id",id));
        base.put("can_edit",access.admin() || access.userId()==id);
        audit("view","teacher_profile",id,"");return base;
    }
    @Transactional(rollbackFor=Exception.class)
    public void saveProfile(long id,Map<String,Object> values) {
        access.requireProfileEdit(id);
        long dept=number(one("SELECT dept_id FROM sys_user WHERE user_id=? AND del_flag='0'",id).get("dept_id"));
        Map<String,Object> checked=new LinkedHashMap<>();
        for(AchievementCatalog.Field f:AchievementCatalog.PROFILE) checked.put(f.key(),f.validate(values.get(f.key())));
        required(checked.get("real_name"),"姓名",64);
        if(checked.get("gender")!=null && !Set.of(1,2).contains(checked.get("gender"))) throw new ServiceException("性别不正确");
        if(checked.get("birth_date")!=null && LocalDate.parse(checked.get("birth_date").toString()).isAfter(LocalDate.now())) throw new ServiceException("出生日期不能晚于今天");
        List<Object> args=new ArrayList<>(List.of(id,dept));args.addAll(checked.values());
        db.update("INSERT INTO zs_teacher_profile(user_id,major_dept_id,"+String.join(",",checked.keySet())+") VALUES("+placeholders(args.size())+") ON DUPLICATE KEY UPDATE major_dept_id=VALUES(major_dept_id),"+checked.keySet().stream().map(k->k+"=VALUES("+k+")").collect(Collectors.joining(",")),args.toArray());
        audit("update","teacher_profile",id,"");
    }
    public void audit(String action,String target,long id,String detail) {
        db.update("INSERT INTO zs_audit_log(user_id,action,target_type,target_id,detail) VALUES(?,?,?,?,?)",access.userId(),action,target,id,detail);
    }
}
