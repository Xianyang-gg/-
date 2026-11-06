package com.sensitive.srams;

import java.math.BigDecimal;
import java.util.*;
import org.h2.jdbcx.JdbcDataSource;
import org.junit.jupiter.api.*;
import com.sensitive.common.exception.ServiceException;
import static org.junit.jupiter.api.Assertions.*;

/** 用真实 SQL 验证数据大屏的统计口径与访问范围。 */
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class AchievementDashboardTest {
    private JdbcDataSource source;
    private AchievementService base;

    private AchievementDashboard dashboard(long userId,boolean collegeRead) {
        var access=new AchievementAccess() {
            @Override public long userId(){return userId;}
            @Override public boolean admin(){return false;}
            @Override public boolean collegeRead(){return collegeRead;}
        };
        return new AchievementDashboard(new AchievementService(source,access));
    }

    @BeforeAll
    void setUp() {
        source=new JdbcDataSource();
        source.setURL("jdbc:h2:mem:achievement_dashboard;MODE=MySQL;DATABASE_TO_LOWER=TRUE;DB_CLOSE_DELAY=-1");
        base=new AchievementService(source,new AchievementAccess());
        var db=base.db;
        db.execute("CREATE TABLE sys_user(user_id BIGINT PRIMARY KEY,nick_name VARCHAR(100),user_name VARCHAR(100),dept_id BIGINT,status VARCHAR(1),del_flag VARCHAR(1))");
        db.execute("CREATE TABLE sys_dept(dept_id BIGINT PRIMARY KEY,parent_id BIGINT,dept_name VARCHAR(100),ancestors VARCHAR(100))");
        db.execute("CREATE TABLE zs_achievement(id BIGINT PRIMARY KEY,category_code VARCHAR(32),name VARCHAR(255),owner_id BIGINT,major_dept_id BIGINT,level_code VARCHAR(64),achieved_date DATE,deleted INT DEFAULT 0)");
        db.execute("CREATE TABLE zs_achievement_member(id BIGINT AUTO_INCREMENT PRIMARY KEY,achievement_id BIGINT,user_id BIGINT,member_name VARCHAR(100),member_role VARCHAR(32))");
        db.execute("CREATE TABLE zs_audit_log(user_id BIGINT,action VARCHAR(32),target_type VARCHAR(32),target_id BIGINT,detail VARCHAR(2000))");
        Set<String> tables=new HashSet<>();
        for(var category:AchievementCatalog.ALL) {
            if(!tables.add(category.table())) continue;
            String columns="achievement_id BIGINT PRIMARY KEY";
            if(category.code().startsWith("project_")) columns+=",contract_wan DECIMAL(14,2),received_wan DECIMAL(14,2)";
            for(var field:category.fields())
                if(field.key().endsWith("_level")) columns+=","+field.key()+" VARCHAR(64)";
            db.execute("CREATE TABLE "+category.table()+"("+columns+")");
        }
        db.update("INSERT INTO sys_dept VALUES(1,0,'学院','0'),(10,1,'软件技术','0,1'),(20,1,'物联网','0,1')");
        db.update("INSERT INTO sys_user VALUES(1,'张老师','teacher1',10,'0','0'),(2,'李老师','teacher2',20,'0','0'),(3,'王老师','teacher3',10,'0','0'),"
            +"(4,'停用老师','teacher4',10,'1','0'),(5,'已删除老师','teacher5',10,'0','2')");
        db.update("INSERT INTO zs_achievement VALUES"
            +"(1,'project_major','专业项目',1,10,NULL,'2025-03-01',0),"
            +"(2,'project_horizontal','横向项目',2,20,NULL,'2026-05-01',0),"
            +"(3,'award_teacher','教师获奖',1,10,NULL,'2026-06-01',0),"
            +"(4,'paper','论文一',2,20,NULL,'2026-07-01',0),"
            +"(5,'paper','论文二',1,10,NULL,'2026-08-01',0),"
            +"(6,'media','媒体报道',3,10,NULL,'2025-09-01',0),"
            +"(7,'award_teacher','已删除成果',1,10,NULL,'2026-01-01',1)");
        db.update("INSERT INTO zs_achievement_member(achievement_id,user_id,member_name,member_role) VALUES"
            +"(2,1,'张老师','member'),(3,2,'李老师','winner'),(5,2,'李老师','author')");
        db.update("INSERT INTO zs_detail_project_major VALUES(1,10.50,5.25)");
        db.update("INSERT INTO zs_detail_project_horizontal VALUES(2,20.00,8.00)");
        db.update("UPDATE zs_achievement SET level_code='国家级' WHERE id=1");
        db.update("INSERT INTO zs_detail_paper VALUES(4,'SCI'),(5,'EI')");
        db.update("INSERT INTO zs_detail_media VALUES(6,'省')");
        db.update("INSERT INTO zs_detail_award VALUES(3,'省级')");
    }

    @SuppressWarnings("unchecked")
    private static Map<String,Object> map(Object value){return (Map<String,Object>)value;}
    @SuppressWarnings("unchecked")
    private static List<Map<String,Object>> list(Object value){return (List<Map<String,Object>>)value;}
    private static Map<String,Object> category(Map<String,Object> stats,String code) {
        return list(stats.get("categories")).stream().filter(c->code.equals(c.get("code"))).findFirst().orElseThrow();
    }
    private long audits() {return Objects.requireNonNull(base.db.queryForObject("SELECT COUNT(*) FROM zs_audit_log WHERE target_type='dashboard'",Long.class));}

    @Test
    void collegeCountsEveryCategoryAndAggregates() {
        var stats=dashboard(9,true).college(Map.of());
        var categories=list(stats.get("categories"));
        assertEquals(AchievementCatalog.ALL.stream().map(AchievementCatalog.Category::code).toList(),categories.stream().map(c->c.get("code")).toList(),"15个子项按目录顺序返回");
        assertEquals(1L,category(stats,"project_major").get("total"));
        assertEquals(1L,category(stats,"award_teacher").get("total"),"已删除成果不计入");
        assertEquals(2L,category(stats,"paper").get("total"));
        assertEquals(0L,category(stats,"textbook").get("total"),"无数据的子项补0");
        assertEquals("论文和专利",category(stats,"paper").get("group"));

        var summary=map(stats.get("summary"));
        assertEquals(6L,summary.get("total"));
        assertEquals(3L,summary.get("owners"));
        assertEquals(new BigDecimal("30.50"),summary.get("contractWan"));
        assertEquals(new BigDecimal("13.25"),summary.get("receivedWan"));
        var funding=list(stats.get("funding"));
        assertEquals(4,funding.size());
        assertEquals(new BigDecimal("10.50"),funding.stream().filter(f->"project_major".equals(f.get("code"))).findFirst().orElseThrow().get("contractWan"));

        Map<Long,Long> byYear=new TreeMap<>();
        for(var year:list(stats.get("years"))) byYear.merge((Long)year.get("year"),(Long)year.get("total"),Long::sum);
        assertEquals(Map.of(2025L,2L,2026L,4L),byYear);
        assertEquals(2025L,list(stats.get("years")).get(0).get("year"),"年份升序");

        var departments=list(stats.get("departments"));
        assertEquals("软件技术",departments.get(0).get("name"));
        assertEquals(4L,departments.get(0).get("total"));
        var owners=list(stats.get("topOwners"));
        assertEquals("张老师",owners.get(0).get("name"));
        assertEquals(3L,owners.get(0).get("total"));
        assertFalse(stats.containsKey("person"));
    }

    @Test
    void collegeFiltersApplyAndUnknownParametersAreIgnored() {
        var dashboard=dashboard(9,true);
        var since2026=map(dashboard.college(Map.of("startDate","2026-01-01")).get("summary"));
        assertEquals(4L,since2026.get("total"));
        assertEquals(new BigDecimal("20.00"),since2026.get("contractWan"));
        assertEquals(2L,map(dashboard.college(Map.of("majorDeptId","20")).get("summary")).get("total"));
        assertEquals(6L,map(dashboard.college(Map.of("majorDeptId","1")).get("summary")).get("total"),"上级部门包含下属专业");
        assertEquals(6L,map(dashboard.college(Map.of("ownerIds","2","personId","2","ids","1")).get("summary")).get("total"),"只接受白名单内的筛选条件");
        assertThrows(ServiceException.class,()->dashboard.college(Map.of("startDate","2026-12-01","endDate","2026-01-01")));
    }

    @Test
    void multipleBusinessesUseTheirOwnLevelFields() {
        var dashboard=dashboard(9,true);
        var all=dashboard.college(Map.of("categoryCodes","paper,media"));
        assertEquals(3L,map(all.get("summary")).get("total"));
        assertEquals(new BigDecimal("0.00"),map(all.get("summary")).get("contractWan"));
        assertEquals(List.of("中文核心","SCI","EI","普通"),category(all,"paper").get("levelOptions"));
        assertEquals(List.of("国家","省","市","镇街","单位"),category(all,"media").get("levelOptions"));
        assertEquals(List.of(),category(all,"patent").get("levelOptions"));

        var filtered=dashboard.college(Map.of("categoryCodes","paper,media","level_paper","SCI","level_media","省"));
        assertEquals(2L,map(filtered.get("summary")).get("total"));
        assertEquals(1L,category(filtered,"paper").get("total"));
        assertEquals(1L,category(filtered,"media").get("total"));
        assertEquals(2L,list(filtered.get("years")).stream().mapToLong(row->(Long)row.get("total")).sum());
        assertEquals(2L,list(filtered.get("departments")).stream().mapToLong(row->(Long)row.get("total")).sum());
        assertEquals(2L,list(filtered.get("topOwners")).stream().mapToLong(row->(Long)row.get("total")).sum());

        assertEquals(2L,map(dashboard.college(Map.of("categoryCodes","paper,media","level_paper","SCI,EI")).get("summary")).get("total"),"选中级别仅匹配对应业务，同一业务级别取并集");
        assertEquals(2L,map(dashboard.college(Map.of("categoryCodes","paper,award_teacher","level_award_teacher","省级","level_paper","SCI")).get("summary")).get("total"));
        var project=map(dashboard.college(Map.of("categoryCodes","project_major,project_horizontal","level_project_major","省级")).get("summary"));
        assertEquals(0L,project.get("total"),"选级别后不包含未选级别的横向项目");
        assertEquals(new BigDecimal("0.00"),project.get("contractWan"));
        assertEquals(1L,map(dashboard.college(Map.of("categoryCodes","project_major","level_project_major","国家级")).get("summary")).get("total"));
    }

    @Test
    void businessLevelsRespectScopeAndDiscardDeselectedConditions() {
        var college=dashboard(9,true);
        assertEquals(1L,map(college.college(Map.of("level_paper","SCI","levelCode","SCI")).get("summary")).get("total"),"未选择业务时也可直接筛选级别");
        assertEquals(2L,map(college.college(Map.of("categoryCodes","paper","level_media","国家")).get("summary")).get("total"),"忽略已取消业务的残留级别");
        assertEquals(0L,map(college.college(Map.of("categoryCodes","paper","level_paper","SCI","majorDeptId","10")).get("summary")).get("total"));
        assertEquals(0L,map(college.college(Map.of("categoryCodes","media","level_media","省","startDate","2026-01-01")).get("summary")).get("total"));
        assertEquals(0L,map(dashboard(1,false).personal(null,Map.of("categoryCodes","paper,media","level_paper","SCI")).get("summary")).get("total"),"级别筛选不能扩大个人权限");
        assertEquals(1L,map(dashboard(1,false).personal(null,Map.of("categoryCodes","paper,media","level_paper","EI")).get("summary")).get("total"));
        assertThrows(ServiceException.class,()->college.college(Map.of("categoryCodes","paper","level_paper","省级")));
        assertThrows(ServiceException.class,()->college.college(Map.of("categoryCodes","invalid")));
    }

    @Test
    void levelsCanBeSelectedAcrossAllBusinesses() {
        var college=dashboard(9,true);
        var stats=college.college(Map.of("level_paper","SCI","level_media","省"));
        assertEquals(2L,map(stats.get("summary")).get("total"));
        assertEquals(1L,category(stats,"paper").get("total"));
        assertEquals(1L,category(stats,"media").get("total"));
        assertEquals(0L,category(stats,"award_teacher").get("total"),"选级别后排除其他业务");
        assertEquals(2L,list(stats.get("years")).stream().mapToLong(row->(Long)row.get("total")).sum());
        assertEquals(2L,list(stats.get("departments")).stream().mapToLong(row->(Long)row.get("total")).sum());
        assertEquals(2L,list(stats.get("topOwners")).stream().mapToLong(row->(Long)row.get("total")).sum());
        var funding=map(college.college(Map.of("level_project_major","国家级","level_paper","SCI")).get("summary"));
        assertEquals(2L,funding.get("total"));
        assertEquals(new BigDecimal("10.50"),funding.get("contractWan"));
        assertEquals(0L,map(college.college(Map.of("level_media","国家")).get("summary")).get("total"));
        assertEquals(0L,map(dashboard(1,false).personal(null,Map.of("level_paper","SCI","level_media","省")).get("summary")).get("total"),"直接选级别仍遵守个人数据范围");
        assertEquals(1L,map(dashboard(2,false).personal(null,Map.of("level_paper","SCI","level_media","省")).get("summary")).get("total"));
        assertEquals(1L,map(college.college(Map.of("level_project_major","国家级","level_award_teacher","国家级")).get("summary")).get("total"),"同名级别仍区分业务");
        assertThrows(ServiceException.class,()->college.college(Map.of("level_paper","省级")));
        assertEquals(6L,map(college.college(Map.of()).get("summary")).get("total"),"清空级别恢复含无级别及未填写级别数据的全部成果");
        assertEquals(6L,map(college.college(null).get("summary")).get("total"));
    }

    @Test
    void personalSplitsOwnedAndParticipated() {
        long before=audits();
        var stats=dashboard(9,true).personal(2L,Map.of());
        var summary=map(stats.get("summary"));
        assertEquals(4L,summary.get("total"));
        assertEquals(2L,summary.get("owned"));
        assertEquals(2L,summary.get("participated"));
        assertEquals(1L,category(stats,"paper").get("owned"));
        assertEquals(1L,category(stats,"paper").get("participated"));
        assertEquals(1L,category(stats,"award_teacher").get("participated"));
        assertEquals(new BigDecimal("20.00"),summary.get("contractWan"));
        var person=map(stats.get("person"));
        assertEquals("李老师",person.get("name"));
        assertEquals("teacher2",person.get("userName"));
        assertEquals("物联网",person.get("deptName"));
        assertEquals(true,stats.get("canSwitch"));
        assertFalse(stats.containsKey("departments"),"个人大屏不返回全院排行");
        assertEquals(before+1,audits(),"查看他人数据大屏记录审计");

        var own=dashboard(1,false).personal(null,Map.of());
        var ownSummary=map(own.get("summary"));
        assertEquals(3L,ownSummary.get("total"),"项目成员不计入参与");
        assertEquals(0L,ownSummary.get("participated"));
        assertEquals(new BigDecimal("10.50"),ownSummary.get("contractWan"));
        assertEquals(false,own.get("canSwitch"));
        assertEquals(1L,map(own.get("person")).get("userId"));
        assertEquals(before+1,audits(),"查看本人不记录审计");
    }

    @Test
    void teachersCannotReadOthersOrCollege() {
        var teacher=dashboard(1,false);
        assertEquals(403,assertThrows(ServiceException.class,()->teacher.personal(2L,Map.of())).getCode());
        assertEquals(403,assertThrows(ServiceException.class,()->teacher.college(Map.of())).getCode());
        assertEquals(403,assertThrows(ServiceException.class,teacher::people).getCode());
        assertDoesNotThrow(()->teacher.personal(1L,Map.of()));

        var college=dashboard(9,true);
        assertEquals(404,assertThrows(ServiceException.class,()->college.personal(999L,Map.of())).getCode());
        assertEquals(404,assertThrows(ServiceException.class,()->college.personal(5L,Map.of())).getCode(),"已删除账号不可查看");
        assertDoesNotThrow(()->college.personal(4L,Map.of()),"停用账号保留历史数据可查看");
        var people=college.people();
        assertEquals(List.of(1L,2L,3L),people.stream().map(p->((Number)p.get("user_id")).longValue()).sorted().toList(),"切换列表只含启用账号");
        assertEquals("teacher2",people.stream().filter(p->((Number)p.get("user_id")).longValue()==2).findFirst().orElseThrow().get("user_name"));
    }
}
