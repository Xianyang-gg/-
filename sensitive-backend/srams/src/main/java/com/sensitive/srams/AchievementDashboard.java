package com.sensitive.srams;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;
import com.sensitive.common.exception.ServiceException;
import org.springframework.stereotype.Service;

/** 数据大屏统计：只读聚合，数据范围复用 AchievementService.filter。 */
@Service
public class AchievementDashboard {
    private static final Set<String> FILTER_KEYS = Set.of("startDate","endDate","majorDeptId","categoryCodes");
    private final AchievementService service;
    private final AchievementAccess access;
    public AchievementDashboard(AchievementService service) { this.service=service; this.access=service.getAccess(); }

    public Map<String,Object> college(Map<String,?> params) {
        if(!access.collegeRead()) throw new ServiceException("无权查看学院数据大屏",403);
        return stats(safe(params),null);
    }

    public Map<String,Object> personal(Long userId,Map<String,?> params) {
        long target=userId==null?access.userId():userId;
        if(target!=access.userId() && !access.collegeRead()) throw new ServiceException("只能查看本人的数据大屏",403);
        List<Map<String,Object>> people=service.rows("SELECT u.user_id,u.nick_name AS name,u.user_name,d.dept_name FROM sys_user u "
            +"LEFT JOIN sys_dept d ON d.dept_id=u.dept_id WHERE u.user_id=? AND u.del_flag='0'",target);
        if(people.isEmpty()) throw new ServiceException("账号不存在",404);
        Map<String,Object> filters=safe(params);filters.put("personId",target);
        Map<String,Object> result=stats(filters,target);
        Map<String,Object> person=people.get(0);
        result.put("person",Map.of("userId",target,"name",AchievementService.text(person.get("name")),
            "userName",AchievementService.text(person.get("user_name")),"deptName",AchievementService.text(person.get("dept_name"))));
        result.put("canSwitch",access.collegeRead());
        if(target!=access.userId()) service.audit("view","dashboard",target,"");
        return result;
    }

    public List<Map<String,Object>> people() {
        if(!access.collegeRead()) throw new ServiceException("无权切换查看其他账号",403);
        return service.rows("SELECT u.user_id,u.nick_name AS name,u.user_name,d.dept_name FROM sys_user u "
            +"LEFT JOIN sys_dept d ON d.dept_id=u.dept_id WHERE u.del_flag='0' AND u.status='0' ORDER BY u.nick_name,u.user_id");
    }

    private static Map<String,Object> safe(Map<String,?> params) {
        Map<String,Object> safe=new HashMap<>();
        if(params!=null) FILTER_KEYS.forEach(key->{ String value=AchievementService.text(params.get(key)); if(!value.isEmpty()) safe.put(key,value); });
        Set<String> selected=new HashSet<>(items(safe.get("categoryCodes")));
        selected.forEach(AchievementCatalog::get);
        for(var category:AchievementCatalog.ALL) {
            if(!selected.isEmpty() && !selected.contains(category.code())) continue;
            var field=levelField(category);
            List<String> levels=items(params==null?null:params.get("level_"+category.code()));
            if(field!=null && !levels.isEmpty()) {
                levels.forEach(field::validate);
                safe.put("level_"+category.code(),levels);
            }
        }
        return safe;
    }

    private static List<String> items(Object value) {
        Collection<?> values=value instanceof Collection<?> c?c:Arrays.asList(AchievementService.text(value).split(","));
        return values.stream().map(AchievementService::text).filter(s->!s.isEmpty()).distinct().toList();
    }

    private static AchievementCatalog.Field levelField(AchievementCatalog.Category category) {
        if(Set.of("project_major","project_research").contains(category.code()))
            return new AchievementCatalog.Field("level_code","项目级别","select",64,List.of("国家级","省级","市级","校级"));
        return category.fields().stream().filter(f->f.key().endsWith("_level")).findFirst().orElse(null);
    }

    private AchievementService.Filter filter(Map<String,Object> params) {
        AchievementService.Filter base=service.filter(params);
        StringBuilder sql=new StringBuilder(base.where());
        List<Object> args=new ArrayList<>(base.args());
        List<String> levelSql=new ArrayList<>();
        for(var category:AchievementCatalog.ALL) {
            List<String> levels=items(params.get("level_"+category.code()));
            if(levels.isEmpty()) continue;
            var field=levelField(category);
            StringBuilder clause=new StringBuilder("(a.category_code=? AND ");args.add(category.code());
            if(field.key().equals("level_code"))
                clause.append("a.level_code IN (").append(AchievementService.placeholders(levels.size())).append(")");
            else
                clause.append("EXISTS (SELECT 1 FROM ").append(category.table())
                    .append(" dl WHERE dl.achievement_id=a.id AND dl.").append(field.key())
                    .append(" IN (").append(AchievementService.placeholders(levels.size())).append("))");
            clause.append(")");args.addAll(levels);levelSql.add(clause.toString());
        }
        if(!levelSql.isEmpty()) sql.append(" AND (").append(String.join(" OR ",levelSql)).append(")");
        return new AchievementService.Filter(sql.toString(),args);
    }

    private Map<String,Object> stats(Map<String,Object> params,Long personId) {
        AchievementService.Filter f=filter(params);
        Object[] where=f.args().toArray();
        Map<String,Object> result=new LinkedHashMap<>();

        List<Object> categoryArgs=new ArrayList<>();
        if(personId!=null) categoryArgs.add(personId);
        categoryArgs.addAll(f.args());
        Map<String,Map<String,Object>> counted=new HashMap<>();
        for(var row:service.rows("SELECT a.category_code,COUNT(*) AS total"+(personId==null?"":",SUM(CASE WHEN a.owner_id=? THEN 1 ELSE 0 END) AS owned")
            +" FROM zs_achievement a"+f.where()+" GROUP BY a.category_code",categoryArgs.toArray()))
            counted.put(AchievementService.text(row.get("category_code")),row);
        List<Map<String,Object>> categories=new ArrayList<>();
        long total=0,owned=0;
        for(var category:AchievementCatalog.ALL) {
            Map<String,Object> row=counted.getOrDefault(category.code(),Map.of());
            long n=count(row.get("total")),own=personId==null?n:count(row.get("owned"));
            Map<String,Object> item=new LinkedHashMap<>();
            item.put("code",category.code());item.put("label",category.label());item.put("group",category.group());item.put("total",n);
            var field=levelField(category);
            item.put("levelLabel",field==null?"":field.label());
            item.put("levelOptions",field==null?List.of():field.options());
            if(personId!=null){item.put("owned",own);item.put("participated",n-own);}
            categories.add(item);total+=n;owned+=own;
        }
        result.put("categories",categories);

        Map<String,Object> summary=new LinkedHashMap<>();
        summary.put("total",total);
        summary.put("owners",count(service.one("SELECT COUNT(DISTINCT a.owner_id) AS owners FROM zs_achievement a"+f.where(),where).get("owners")));
        if(personId!=null){summary.put("owned",owned);summary.put("participated",total-owned);}

        List<Map<String,Object>> years=new ArrayList<>();
        for(var row:service.rows("SELECT YEAR(a.achieved_date) AS stat_year,a.category_code,COUNT(*) AS total FROM zs_achievement a"+f.where()
            +" AND a.achieved_date IS NOT NULL GROUP BY YEAR(a.achieved_date),a.category_code ORDER BY stat_year",where))
            years.add(Map.of("year",count(row.get("stat_year")),"code",AchievementService.text(row.get("category_code")),"total",count(row.get("total"))));
        result.put("years",years);

        List<Map<String,Object>> funding=new ArrayList<>();
        BigDecimal contract=BigDecimal.ZERO,received=BigDecimal.ZERO;
        for(var category:AchievementCatalog.ALL) {
            if(!category.code().startsWith("project_")) continue;
            List<Object> args=new ArrayList<>(f.args());args.add(category.code());
            Map<String,Object> row=service.one("SELECT COALESCE(SUM(pf.contract_wan),0) AS contract_wan,COALESCE(SUM(pf.received_wan),0) AS received_wan "
                +"FROM zs_achievement a JOIN "+category.table()+" pf ON pf.achievement_id=a.id"+f.where()+" AND a.category_code=?",args.toArray());
            BigDecimal c=money(row.get("contract_wan")),r=money(row.get("received_wan"));
            funding.add(Map.of("code",category.code(),"label",category.label(),"contractWan",c,"receivedWan",r));
            contract=contract.add(c);received=received.add(r);
        }
        result.put("funding",funding);
        summary.put("contractWan",contract);summary.put("receivedWan",received);
        result.put("summary",summary);

        if(personId==null) {
            result.put("departments",ranking(service.rows("SELECT a.major_dept_id AS id,d.dept_name AS name,COUNT(*) AS total FROM zs_achievement a "
                +"LEFT JOIN sys_dept d ON d.dept_id=a.major_dept_id"+f.where()+" GROUP BY a.major_dept_id,d.dept_name ORDER BY total DESC,a.major_dept_id LIMIT 20",where)));
            result.put("topOwners",ranking(service.rows("SELECT a.owner_id AS id,u.nick_name AS name,COUNT(*) AS total FROM zs_achievement a "
                +"LEFT JOIN sys_user u ON u.user_id=a.owner_id"+f.where()+" GROUP BY a.owner_id,u.nick_name ORDER BY total DESC,a.owner_id LIMIT 10",where)));
        }
        return result;
    }

    private static List<Map<String,Object>> ranking(List<Map<String,Object>> rows) {
        return rows.stream().map(row->Map.<String,Object>of("id",count(row.get("id")),
            "name",AchievementService.text(row.get("name")).isEmpty()?"未知":AchievementService.text(row.get("name")),"total",count(row.get("total")))).toList();
    }
    private static long count(Object value) { return value instanceof Number n ? n.longValue() : 0L; }
    private static BigDecimal money(Object value) {
        BigDecimal n=value instanceof BigDecimal b?b:value instanceof Number x?new BigDecimal(x.toString()):BigDecimal.ZERO;
        return n.setScale(2,RoundingMode.HALF_UP);
    }
}
