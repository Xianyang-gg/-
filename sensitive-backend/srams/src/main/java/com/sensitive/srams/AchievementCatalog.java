package com.sensitive.srams;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;
import com.sensitive.common.exception.ServiceException;

/** 固定的成果字段白名单；数据库标识符不接受客户端输入。 */
public final class AchievementCatalog {
    public record Field(String key, String label, String type, int maxLength, List<String> options) {
        public Object validate(Object value) {
            if (value == null || value.toString().isBlank()) return null;
            String text = value.toString().trim();
            try {
                return switch (type) {
                    case "date" -> LocalDate.parse(text).toString();
                    case "money" -> {
                        BigDecimal n = new BigDecimal(text);
                        if (n.signum() < 0 || n.scale() > 2 || n.compareTo(new BigDecimal("999999999999.99")) > 0)
                            throw new IllegalArgumentException();
                        yield n;
                    }
                    case "number" -> {
                        int n = Integer.parseInt(text);
                        if (n < 0) throw new IllegalArgumentException();
                        yield n;
                    }
                    default -> {
                        if (text.length() > maxLength || (!options.isEmpty() && !options.contains(text)))
                            throw new IllegalArgumentException();
                        if (key.equals("media_url") && !(text.startsWith("https://") || text.startsWith("http://")))
                            throw new IllegalArgumentException();
                        yield text;
                    }
                };
            } catch (RuntimeException ex) { throw new ServiceException(label + "格式或范围不正确"); }
        }
    }
    public record Category(String code, String label, String group, String table, List<Field> fields) {}
    private static Field t(String key, String label) { return new Field(key,label,"text",255,List.of()); }
    private static Field t(String key, String label, int length) { return new Field(key,label,"text",length,List.of()); }
    private static Field d(String key, String label) { return new Field(key,label,"date",0,List.of()); }
    private static Field m(String key, String label) { return new Field(key,label,"money",0,List.of()); }
    private static Field s(String key, String label, String options) { return new Field(key,label,"select",64,List.of(options.split("/"))); }
    private static final String LEVELS="国家级/省级/市级/校级";
    public static final List<Category> ALL = List.of(
        new Category("project_major","按专业申报的项目","项目","zs_detail_project_major",List.of(
            s("project_type","项目类型","工程中心/实训基地/重点专业/技能平台/紧缺专业/其他"),t("issuing_unit","下达单位"),m("contract_wan","合同经费（万元）"),m("received_wan","到账经费（万元）"),d("apply_date","立项时间"),d("finish_date","结项时间"))),
        new Category("project_research","教科研项目","项目","zs_detail_project_research",List.of(
            s("project_type","项目类型","教研/科研/其他"),t("issuing_unit","下达单位"),m("contract_wan","合同经费（万元）"),m("received_wan","到账经费（万元）"),d("apply_date","立项时间"),d("finish_date","结项时间"))),
        new Category("project_horizontal","横向项目","项目","zs_detail_project_horizontal",List.of(
            t("company_name","合作企业名称"),m("contract_wan","合同经费（万元）"),m("received_wan","到账经费（万元）"),d("start_date","立项时间"),d("end_date","结项时间"))),
        new Category("project_student","指导学生项目","项目","zs_detail_project_student",List.of(
            t("issuing_unit","下达单位"),s("project_level","项目级别",LEVELS),m("contract_wan","合同经费（万元）"),m("received_wan","到账经费（万元）"),d("grant_date","立项时间"),d("finish_date","结项时间"))),
        new Category("award_teacher","教师获奖及荣誉称号","获奖","zs_detail_award",List.of(
            s("award_type","获奖类型","个人获奖/竞赛获奖/教材获奖/论文获奖/征文获奖/项目获奖/其他"),t("issuer","授奖单位"),s("award_level","获奖级别","国家级/省级/市级/校级/企业级"),d("award_date","获奖时间"))),
        new Category("award_student","指导学生获奖","获奖","zs_detail_award",List.of(
            s("award_grade","获奖等级","一等/二等/三等/优秀/金/银/铜/特等/其他"),t("issuer","发证单位"),s("award_level","获奖级别",LEVELS),d("award_date","获奖时间"))),
        new Category("course","课程","教材和课程","zs_detail_course",List.of(
            t("project_name","立项项目名称"),t("approving_unit","立项单位"),s("project_level","课程级别",LEVELS),d("start_date","开始时间"),d("finish_date","完成时间"))),
        new Category("textbook","教材","教材和课程","zs_detail_textbook",List.of(
            t("isbn","ISBN",32),t("editor_in_chief","主编"),t("publisher","出版单位"),d("publish_date","出版时间"),s("textbook_type","教材类型","活页式教材/工作手册式教材/数字教材/普通教材"),s("textbook_level","教材等级","国家规划教材/省规划教材/普通教材/校本教材"),t("company_name","合作企业"))),
        new Category("paper","论文","论文和专利","zs_detail_paper",List.of(
            s("paper_type","论文类别","科研/教研"),s("paper_level","论文等级","中文核心/SCI/EI/普通"),t("journal_name","发表期刊"),d("publish_date","发表时间"),t("first_author","第一作者",100))),
        new Category("patent","专利及软件著作权","论文和专利","zs_detail_patent",List.of(
            s("patent_type","类别","专利/实用新型/软件著作权"),t("rights_holder","权利人或著作权人"),t("registration_no","专利号或登记号",100),d("apply_date","申请日期"),d("grant_date","授权日期"))),
        new Category("patent_transfer","专利转让","论文和专利","zs_detail_patent_transfer",List.of(
            s("patent_type","专利类型","专利/实用新型/软件著作权"),t("patent_no","专利号",100),t("inventors","发明人",500),m("transfer_fee","转让费（元/项）"),t("transferee","受让方"),d("transfer_date","转让时间"))),
        new Category("visit","接待参观与企业洽谈","交流合作","zs_detail_visit",List.of(
            t("visit_unit","接待单位"),t("contact_name","联系人",100),t("accompany_text","陪同人",500),d("visit_date","接待时间"),t("content","主要内容",2000))),
        new Category("tech_training","举办技术交流和公开培训","交流合作","zs_detail_tech_training",List.of(
            t("audience","邀请单位或授课对象",500),t("lecturer","主讲人"),new Field("participant_count","人数","number",0,List.of()),d("event_date","举办时间"))),
        new Category("study_training","参加培训进修","交流合作","zs_detail_study_training",List.of(
            s("training_type","类别","培训/会议"),s("scope","范围","国内/国际"),s("training_level","级别","省培/国培/其他"),t("organizer","主办单位"),t("issuer","发证单位"),d("event_date","参加时间"))),
        new Category("media","媒体报道","媒体报道","zs_detail_media",List.of(
            t("media_title","报道标题"),t("media_name","媒体名称"),s("media_level","媒体级别","国家/省/市/镇街/单位"),t("media_url","报道链接",1000),d("publish_date","报道时间")))
    );
    public static Category get(String code) {
        return ALL.stream().filter(c->c.code().equals(code)).findFirst().orElseThrow(()->new ServiceException("无效的成果类别"));
    }
    public static final List<Field> PROFILE = List.of(
        t("real_name","姓名",64),new Field("gender","性别","number",0,List.of()),d("birth_date","出生日期"),t("ethnicity","民族",32),t("political_status","政治面貌",32),t("highest_education","最高学历",32),t("highest_degree","最高学位",32),d("degree_date","学位获取时间"),t("position_name","职务",64),t("professional_title","职称",64),d("title_date","职称获取时间")
    );
    private AchievementCatalog() {}
}
