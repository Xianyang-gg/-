package com.sensitive.srams;

import java.util.*;
import java.nio.file.*;
import java.util.zip.ZipFile;
import javax.imageio.ImageIO;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import java.util.stream.Stream;
import org.h2.jdbcx.JdbcDataSource;
import org.junit.jupiter.api.*;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;
import org.junit.jupiter.params.provider.CsvSource;
import org.junit.jupiter.api.io.TempDir;
import com.sensitive.common.exception.ServiceException;
import static org.junit.jupiter.api.Assertions.*;

/** 用真实 SQL 验证各业务字段的筛选、分页及导出范围。 */
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class AchievementSearchTest {
    private JdbcDataSource source;
    private AchievementService service;
    @TempDir static Path exportWorkspace;
    private final Map<String,Long> firstIds=new HashMap<>(),secondIds=new HashMap<>();

    private AchievementAccess access(boolean collegeRead,long userId) {
        return new AchievementAccess() {
            @Override public boolean collegeRead(){return collegeRead;}
            @Override public long userId(){return userId;}
            @Override public boolean canEdit(Map<String,Object> row){return false;}
        };
    }

    @BeforeAll
    void setUp() throws Exception {
        source=new JdbcDataSource();
        source.setURL("jdbc:h2:mem:achievement_search;MODE=MySQL;DATABASE_TO_LOWER=TRUE;DB_CLOSE_DELAY=-1");
        service=new AchievementService(source,access(true,1));
        var db=service.db;
        db.execute("CREATE TABLE sys_user(user_id BIGINT PRIMARY KEY,nick_name VARCHAR(100))");
        db.execute("CREATE TABLE sys_dept(dept_id BIGINT PRIMARY KEY,parent_id BIGINT,dept_name VARCHAR(100),ancestors VARCHAR(100),order_num INT,status VARCHAR(1) DEFAULT '0',del_flag VARCHAR(1) DEFAULT '0')");
        db.execute("CREATE TABLE zs_achievement(id BIGINT PRIMARY KEY,category_code VARCHAR(32),name VARCHAR(255),owner_id BIGINT,major_dept_id BIGINT,level_code VARCHAR(64),achieved_date DATE,deleted INT DEFAULT 0)");
        db.execute("CREATE TABLE zs_achievement_member(id BIGINT AUTO_INCREMENT PRIMARY KEY,achievement_id BIGINT,user_id BIGINT,member_name VARCHAR(100),member_role VARCHAR(32),sort_num INT DEFAULT 0)");
        db.execute("CREATE TABLE zs_attachment(id BIGINT AUTO_INCREMENT PRIMARY KEY,achievement_id BIGINT,deleted INT DEFAULT 0,original_name VARCHAR(255) DEFAULT '佐证.png',file_size BIGINT DEFAULT 1,mime_type VARCHAR(100) DEFAULT 'image/png',file_ext VARCHAR(10) DEFAULT 'png',storage_key VARCHAR(255) DEFAULT 'evidence.png',sort_num INT DEFAULT 0)");
        db.execute("CREATE TABLE zs_achievement_sort(user_id BIGINT,category_code VARCHAR(32),achievement_id BIGINT,sort_year INT,sort_num INT)");
        db.update("INSERT INTO sys_user VALUES(1,'张老师'),(2,'李老师')");
        db.update("INSERT INTO sys_dept(dept_id,parent_id,dept_name,ancestors,order_num,status,del_flag) VALUES(1,0,'学院','0',0,'0','0'),(2,1,'信息工程学院','0,1',0,'0','0'),(10,2,'软件技术','0,1,2',0,'0','0'),(20,1,'软件技术','0,1',1,'0','0'),(30,1,'停用专业','0,1',2,'1','0'),(40,1,'已删除专业','0,1',3,'0','2')");
        ImageIO.write(new java.awt.image.BufferedImage(16,16,java.awt.image.BufferedImage.TYPE_INT_RGB),"png",exportWorkspace.resolve("evidence.png").toFile());
        Map<String,Map<String,AchievementCatalog.Field>> tables=new LinkedHashMap<>();
        for(var category:AchievementCatalog.ALL) {
            var fields=tables.computeIfAbsent(category.table(),key->new LinkedHashMap<>());
            category.fields().forEach(field->fields.put(field.key(),field));
        }
        tables.forEach((table,fields)->{
            StringBuilder sql=new StringBuilder("CREATE TABLE "+table+"(achievement_id BIGINT PRIMARY KEY");
            for(var field:fields.values()) sql.append(",").append(field.key()).append(" ").append(switch(field.type()) {
                case "date" -> "DATE";
                case "money" -> "DECIMAL(14,2)";
                case "number" -> "INT";
                default -> "VARCHAR(2000)";
            });
            db.execute(sql.append(")").toString());
        });
        long nextId=1;
        for(var category:AchievementCatalog.ALL) {
            firstIds.put(category.code(),nextId);secondIds.put(category.code(),nextId+1);
            for(int variant=0;variant<2;variant++) {
                long id=nextId+variant;
                db.update("INSERT INTO zs_achievement VALUES(?,?,?,?,?,?,?,0)",id,category.code(),(variant==0?"目标成果_":"其他成果_")+category.code(),variant+1,variant==0?10:20,variant==0?"国家级":"省级",variant==0?"2026-10-01":"2026-11-01");
                List<Object> values=new ArrayList<>();values.add(id);
                for(var field:category.fields()) values.add(sample(field,variant==0));
                String columns=String.join(",",category.fields().stream().map(AchievementCatalog.Field::key).toList());
                db.update("INSERT INTO "+category.table()+"(achievement_id,"+columns+") VALUES("+AchievementService.placeholders(values.size())+")",values.toArray());
                if(variant==0) {
                    db.update("INSERT INTO zs_attachment(achievement_id,deleted) VALUES(?,0),(?,0),(?,1)",id,id,id);
                    if(!category.code().startsWith("project_")) {
                        db.update("INSERT INTO zs_achievement_member(achievement_id,user_id,member_name,member_role) VALUES(?,2,'李老师','participant'),(?,NULL,'张学生','student')",id,id);
                    }
                }
            }
            nextId+=2;
        }
        db.update("INSERT INTO zs_achievement VALUES(999,'project_major','已删除成果',1,10,'国家级','2026-10-01',1)");
    }

    @AfterAll void close(){service.db.execute("SHUTDOWN");}

    private Object sample(AchievementCatalog.Field field,boolean target) {
        return switch(field.type()) {
            case "date" -> target?"2026-10-01":"2026-11-01";
            case "money", "number" -> target?0:5;
            case "select" -> field.options().get(target?0:field.options().size()-1);
            default -> field.key().equals("media_url")?(target?"https://example.com/target":"https://other.org/miss"):(target?"目标内容":"其他内容");
        };
    }

    private Stream<Arguments> fields() {
        return AchievementCatalog.ALL.stream().flatMap(category->category.fields().stream().map(field->Arguments.of(category,field)));
    }

    @SuppressWarnings("unchecked")
    private List<Long> listIds(AchievementService target,Map<String,?> params,int page,int size) {
        return ((List<Map<String,Object>>)target.list(params,page,size).get("rows")).stream().map(row->AchievementService.number(row.get("id"))).toList();
    }

    private void assertMatches(Map<String,?> params,Long... ids) {
        assertEquals(List.of(ids),listIds(service,params,1,100));
        assertEquals(List.of(ids),service.exportIds(params),"导出应使用相同的筛选条件与顺序");
    }

    @ParameterizedTest(name="{0}: {1}")
    @MethodSource("fields")
    void everyDetailColumnFiltersListAndExport(AchievementCatalog.Category category,AchievementCatalog.Field field) {
        Map<String,Object> params=new HashMap<>();params.put("categoryCode",category.code());params.put("majorDeptId",10);
        String key="detail_"+field.key();
        switch(field.type()) {
            case "date" -> {params.put(key+"Start","2026-10-01");params.put(key+"End","2026-10-01");}
            case "money", "number" -> {params.put(key+"Min",0);params.put(key+"Max",0);}
            case "select" -> params.put(key,sample(field,true));
            default -> params.put(key,field.key().equals("media_url")?"example.com":"目标");
        }
        assertMatches(params,firstIds.get(category.code()));
    }

    @Test
    void commonColumnsAndCombinedConditions() {
        long first=firstIds.get("project_major"),second=secondIds.get("project_major");
        assertMatches(Map.of("categoryCode","project_major","keyword","目标"),first);
        assertMatches(Map.of("categoryCode","project_major","ownerId",1),first);
        assertMatches(Map.of("categoryCode","project_major","majorDeptId",10),first);
        assertMatches(Map.of("categoryCode","project_major","levelCode","国家级"),first);
        assertMatches(Map.of("categoryCode","project_major","startDate","2026-10-01","endDate","2026-10-01"),first);
        assertMatches(Map.of("categoryCode","project_major","detail_contract_wanMin",1),second);
        assertMatches(Map.of("categoryCode","project_major","detail_finish_dateEnd","2026-10-31"),first);
        assertMatches(Map.of("categoryCode","project_major","majorDeptId",10,"levelCode","国家级","detail_contract_wanMax",0,"detail_issuing_unit","目标"),first);
        assertMatches(Map.of("categoryCode","project_major","majorDeptId",20,"detail_issuing_unit","目标"));
    }

    @ParameterizedTest
    @CsvSource({"project_major","project_research"})
    void multipleLevelsFilterListAndExport(String categoryCode) {
        long first=firstIds.get(categoryCode),second=secondIds.get(categoryCode);
        for(Object levels:List.of("国家级,省级",List.of("国家级","省级")," 国家级,省级,国家级, ")) {
            Map<String,Object> params=Map.of("categoryCode",categoryCode,"levelCode",levels);
            assertMatches(params,second,first);
            assertEquals(List.of(second),listIds(service,params,1,1));
            assertEquals(List.of(first),listIds(service,params,2,1));
            var restricted=new AchievementService(source,access(false,2));
            assertEquals(List.of(second),listIds(restricted,params,1,100));
            assertEquals(List.of(second),restricted.exportIds(params));
        }
        assertMatches(Map.of("categoryCode",categoryCode,"levelCode",List.of("国家级","市级")),first);
        assertMatches(Map.of("categoryCode",categoryCode,"levelCode",List.of("市级","校级")));
        assertMatches(Map.of("categoryCode",categoryCode,"levelCode",List.of()),second,first);
        assertMatches(Map.of("categoryCode",categoryCode,"levelCode",""),second,first);
        assertMatches(Map.of("categoryCode",categoryCode,"levelCode",List.of("' OR 1=1 --")));
        assertMatches(Map.of("categoryCode",categoryCode,"levelCode",List.of("国家级","省级"),"majorDeptId",10),first);
    }

    @Test
    void ownersAndExternalMembersAreIndependent() {
        long first=firstIds.get("award_student"),second=secondIds.get("award_student");
        assertMatches(Map.of("categoryCode","award_student","memberName","张学"),first);
        assertMatches(Map.of("categoryCode","award_student","ownerId",2),second);
        assertMatches(Map.of("categoryCode","award_student","memberName","张学","ownerId",2));
    }

    @Test
    void summaryPaginationAndExportHaveTheSameScope() {
        Map<String,Object> params=Map.of("scope","summary","categoryGroup","项目","majorDeptId",2,"levelCode","国家级");
        List<Long> expected=List.of(firstIds.get("project_student"),firstIds.get("project_horizontal"),firstIds.get("project_research"),firstIds.get("project_major"));
        assertEquals(4L,((Number)service.list(params,1,2).get("total")).longValue());
        List<Long> paginated=new ArrayList<>(listIds(service,params,1,2));paginated.addAll(listIds(service,params,2,2));
        assertEquals(expected,paginated);
        assertEquals(expected,service.exportIds(params));
    }

    @Test
    void departmentTreeUsesHierarchyAndDepartmentOrder() {
        var roots=service.departmentTree();
        assertEquals(1,roots.size());assertEquals(1L,roots.get(0).getId());
        var children=roots.get(0).getChildren();
        assertEquals(List.of(2L,20L,30L),children.stream().map(node->node.getId()).toList());
        assertEquals(10L,children.get(0).getChildren().get(0).getId());
        assertFalse(children.get(2).isDisabled(),"停用部门仍可筛选历史成果");
    }

    @Test
    void departmentIdsDistinguishDuplicateNamesAndIncludeDescendants() {
        long first=firstIds.get("project_major"),second=secondIds.get("project_major");
        assertMatches(Map.of("categoryCode","project_major","majorDeptId",10),first);
        assertMatches(Map.of("categoryCode","project_major","majorDeptId",20),second);
        assertMatches(Map.of("categoryCode","project_major","majorDeptId","2"),first);
        assertMatches(Map.of("categoryCode","project_major","majorDeptId",1),second,first);
        assertMatches(Map.of("categoryCode","project_major","majorDeptId",9999));
        assertMatches(Map.of("categoryCode","project_major"),second,first);
        assertThrows(ServiceException.class,()->service.exportIds(Map.of("categoryCode","project_major","majorDeptId",2,"ids",List.of(first,second))));
        assertThrows(ServiceException.class,()->service.list(Map.of("majorDeptId","bad-id"),1,10));
        var restricted=new AchievementService(source,access(false,2));
        assertTrue(restricted.exportIds(Map.of("categoryCode","project_major","majorDeptId",2)).isEmpty());
        assertEquals(List.of(firstIds.get("award_student")),restricted.exportIds(Map.of("categoryCode","award_student","majorDeptId",2)));
    }

    @ParameterizedTest
    @CsvSource({"1,false","2,false","3,false","1,true","2,true","3,true"})
    void generatedFilesMatchDepartmentFilteredList(int type,boolean summary) throws Exception {
        Map<String,Object> params=new HashMap<>(Map.of("majorDeptId",2,"sort","custom"));
        if(summary){params.put("scope","summary");params.put("categoryGroup","项目");}
        else {params.put("categoryCode","project_major");params.put("detail_contract_wanMax",0);}
        List<Long> ids=service.exportIds(params);
        assertEquals(listIds(service,params,1,100),ids);
        var records=service.exportRecords(ids);
        List<String> names=records.stream().map(row->row.get("name").toString()).toList();
        assertEquals(summary?4:1,names.size());
        var files=new AchievementFiles(service,service.access){@Override Path root(){return exportWorkspace;}};
        var exports=new AchievementExport(service,files);
        Path output=exportWorkspace.resolve("department-"+type+"-"+summary+switch(type){case 1->".xlsx";case 2->".docx";default->".zip";});
        try {
            var writer=AchievementExport.class.getDeclaredMethod(switch(type){case 1->"excel";case 2->"word";default->"zip";},Path.class,List.class,boolean.class);
            writer.setAccessible(true);writer.invoke(exports,output,records,summary);
            if(type==1) {
                try(var input=Files.newInputStream(output);var workbook=new XSSFWorkbook(input)) {
                    var sheet=workbook.getSheet(summary?"成果汇总":"按专业申报的项目");
                    assertEquals(names.size(),sheet.getLastRowNum());
                    for(var reportSheet:workbook) for(var cell:reportSheet.getRow(0)) assertNotEquals("所属专业",cell.getStringCellValue());
                    List<String> actual=new ArrayList<>();
                    for(int row=1;row<=sheet.getLastRowNum();row++) {
                        actual.add(sheet.getRow(row).getCell(summary?3:1).getStringCellValue());
                    }
                    assertEquals(summary?"成果日期":"级别",sheet.getRow(0).getCell(summary?5:3).getStringCellValue());
                    assertEquals(names,actual);
                    var projectSheet=workbook.getSheet("按专业申报的项目");
                    int moneyColumn=-1;
                    for(var cell:projectSheet.getRow(0)) if("合同经费（万元）".equals(cell.getStringCellValue())) moneyColumn=cell.getColumnIndex();
                    assertTrue(moneyColumn>=0);assertEquals(0d,projectSheet.getRow(1).getCell(moneyColumn).getNumericCellValue());
                }
            } else if(type==2) {
                try(var input=Files.newInputStream(output);var document=new XWPFDocument(input)) {
                    String text=String.join("\n",document.getParagraphs().stream().map(paragraph->paragraph.getText()).toList());
                    int last=-1;
                    for(String name:names){int position=text.indexOf(name);assertTrue(position>last);last=position;}
                    assertFalse(text.contains("其他成果_"));
                    assertFalse(text.contains("所属专业："));
                    long images=document.getParagraphs().stream().flatMap(paragraph->paragraph.getRuns().stream()).flatMap(run->run.getEmbeddedPictures().stream()).count();
                    assertEquals(2L*names.size(),images);
                }
            } else {
                try(var zip=new ZipFile(output.toFile())) {
                    assertEquals(3,zip.stream().map(entry->entry.getName().split("/")[0]).distinct().count());
                    List<String> actual=zip.stream().filter(entry->entry.isDirectory() && !entry.getName().equals("附件/"))
                        .map(entry->entry.getName().split("/")[1]).toList();
                    assertEquals(names,actual);
                    var spreadsheet=zip.stream().filter(entry->entry.getName().endsWith(".xlsx")).findFirst().orElseThrow();
                    try(var input=zip.getInputStream(spreadsheet);var workbook=new XSSFWorkbook(input)) {
                        var sheet=workbook.getSheet(summary?"成果汇总":"按专业申报的项目");
                        assertEquals(names.size(),sheet.getLastRowNum());
                        for(var reportSheet:workbook) for(var cell:reportSheet.getRow(0)) assertNotEquals("所属专业",cell.getStringCellValue());
                        for(int row=1;row<=names.size();row++)assertEquals(names.get(row-1),sheet.getRow(row).getCell(summary?3:1).getStringCellValue());
                    }
                    var word=zip.stream().filter(entry->entry.getName().endsWith(".docx")).findFirst().orElseThrow();
                    try(var input=zip.getInputStream(word);var document=new XWPFDocument(input)) {
                        String text=String.join("\n",document.getParagraphs().stream().map(paragraph->paragraph.getText()).toList());
                        int last=-1;
                        for(String name:names){int position=text.indexOf(name);assertTrue(position>last);last=position;}
                        assertFalse(text.contains("其他成果_"));
                        assertFalse(text.contains("所属专业："));
                        assertEquals(2L*names.size(),document.getParagraphs().stream().flatMap(paragraph->paragraph.getRuns().stream()).flatMap(run->run.getEmbeddedPictures().stream()).count());
                    }
                    assertEquals(2L*names.size(),zip.stream().filter(entry->!entry.isDirectory() && entry.getName().startsWith("附件/")).count());
                    byte[] original=Files.readAllBytes(exportWorkspace.resolve("evidence.png"));
                    for(var entry:zip.stream().filter(entry->!entry.isDirectory() && entry.getName().startsWith("附件/")).toList()) {
                        assertArrayEquals(original,zip.getInputStream(entry).readAllBytes());
                    }
                }
            }
        } finally {exports.stop();}
    }

    @Test
    @SuppressWarnings("unchecked")
    void wordIncludesAllProjectFieldsAndMarksMissingValues() throws Exception {
        var row=new LinkedHashMap<>(service.exportRecords(List.of(firstIds.get("project_major"))).get(0));
        var detail=new LinkedHashMap<>((Map<String,Object>)row.get("detail"));
        detail.put("project_type",null);
        detail.put("issuing_unit"," " );
        row.put("detail",detail);
        row.put("remark","补充说明");
        var files=new AchievementFiles(service,service.access){@Override Path root(){return exportWorkspace;}};
        var exports=new AchievementExport(service,files);
        try {
            var writer=AchievementExport.class.getDeclaredMethod("word",Path.class,List.class,boolean.class);
            writer.setAccessible(true);
            for(boolean summary:List.of(false,true)) {
                Path output=exportWorkspace.resolve("complete-project-"+summary+".docx");
                writer.invoke(exports,output,List.of(row),summary);
                try(var input=Files.newInputStream(output);var document=new XWPFDocument(input)) {
                    String text=String.join("\n",document.getParagraphs().stream().map(paragraph->paragraph.getText()).toList());
                    assertFalse(text.contains("所属专业："));
                    assertTrue(text.contains("级别：国家级"));
                    assertTrue(text.contains("项目类型：—"));
                    assertTrue(text.contains("下达单位：—"));
                    assertTrue(text.contains("合同经费（万元）：0.00"));
                    assertTrue(text.contains("备注：补充说明"));
                    for(var field:AchievementCatalog.get("project_major").fields()) assertTrue(text.contains(field.label()+"："),field.label());
                    assertTrue(text.indexOf("备注：补充说明")<text.indexOf("佐证："));
                    if(summary) assertTrue(text.contains("业务范围：项目 / 按专业申报的项目"));
                }
            }
        } finally {exports.stop();}
    }

    @Test
    @SuppressWarnings("unchecked")
    void zipNamesHandleDuplicateRecordsAndAttachmentsAndCleanTemporaryFiles() throws Exception {
        var original=service.exportRecords(List.of(firstIds.get("course"))).get(0);
        List<Map<String,Object>> records=new ArrayList<>();
        for(String name:List.of("同名成果","同名成果","../不合法:名称","..","CON")) {
            var row=new LinkedHashMap<>(original);row.put("name",name);
            var attachment=new LinkedHashMap<>(((List<Map<String,Object>>)original.get("attachments")).get(0));
            attachment.put("original_name","佐证.png");attachment.put("mime_type","image/jpeg");
            row.put("attachments",List.of(attachment,attachment));records.add(row);
        }
        var files=new AchievementFiles(service,service.access){@Override Path root(){return exportWorkspace;}};
        var exports=new AchievementExport(service,files);Path output=exportWorkspace.resolve("duplicates.zip");
        var writer=AchievementExport.class.getDeclaredMethod("zip",Path.class,List.class,boolean.class);writer.setAccessible(true);
        try {
            writer.invoke(exports,output,records,true);
            try(var zip=new ZipFile(output.toFile())) {
                assertNotNull(zip.getEntry("成果汇总.xlsx"));assertNotNull(zip.getEntry("成果汇总.docx"));assertNotNull(zip.getEntry("附件/"));
                for(String folder:List.of("同名成果","同名成果 (2)",".._不合法_名称","附件","_CON")) {
                    assertNotNull(zip.getEntry("附件/"+folder+"/佐证.jpg"));
                    assertNotNull(zip.getEntry("附件/"+folder+"/佐证 (2).jpg"));
                }
                assertTrue(zip.stream().noneMatch(entry->Arrays.asList(entry.getName().split("/")).contains("..")));
            }
            assertNoBundleTemporaryFiles();
            var broken=new LinkedHashMap<>(((List<Map<String,Object>>)records.get(0).get("attachments")).get(0));
            broken.put("storage_key","missing.png");records.get(0).put("attachments",List.of(broken));
            assertThrows(java.lang.reflect.InvocationTargetException.class,()->writer.invoke(exports,output,records,true));
            assertNoBundleTemporaryFiles();
        } finally {exports.stop();}
    }

    private void assertNoBundleTemporaryFiles() throws Exception {
        try(var entries=Files.list(exportWorkspace)) {
            assertTrue(entries.noneMatch(entry->entry.getFileName().toString().startsWith("export-bundle-")));
        }
    }

    @Test
    void filtersCannotBroadenAccessOrBypassBoundParameters() {
        var restricted=new AchievementService(source,access(false,2));
        Map<String,Object> project=Map.of("categoryCode","project_major","ownerId",1);
        assertTrue(listIds(restricted,project,1,10).isEmpty());assertTrue(restricted.exportIds(project).isEmpty());
        Map<String,Object> award=Map.of("categoryCode","award_student","ownerId",1,"memberName","张学");
        assertEquals(List.of(firstIds.get("award_student")),listIds(restricted,award,1,10));
        assertMatches(Map.of("categoryCode","project_major","detail_issuing_unit","' OR 1=1 --"));
    }

    @Test
    void invalidRangesAreRejected() {
        for(Map<String,Object> invalid:List.<Map<String,Object>>of(
            Map.of("detail_contract_wanMin",2,"detail_contract_wanMax",1),Map.of("detail_contract_wanMin",-1),
            Map.of("detail_contract_wanMin","0.001"),Map.of("detail_finish_dateStart","2026-11-01","detail_finish_dateEnd","2026-10-01"),
            Map.of("detail_finish_dateStart","bad-date"))) {
            var params=new HashMap<>(invalid);params.put("categoryCode","project_major");
            assertThrows(ServiceException.class,()->service.list(params,1,10));
            assertThrows(ServiceException.class,()->service.exportIds(params));
        }
    }
}
