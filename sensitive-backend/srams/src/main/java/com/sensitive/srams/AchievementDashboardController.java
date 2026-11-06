package com.sensitive.srams;

import java.util.Map;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import com.sensitive.common.core.domain.AjaxResult;

/** 数据大屏只读接口：菜单权限控制入口，AchievementAccess 控制数据范围。 */
@RestController
@RequestMapping("/achievement/dashboard")
public class AchievementDashboardController {
    private final AchievementDashboard dashboard;
    public AchievementDashboardController(AchievementDashboard dashboard) { this.dashboard=dashboard; }

    @GetMapping("/college")
    @PreAuthorize("@ss.hasPermi('achievement:dashboard:college')")
    public AjaxResult college(@RequestParam Map<String,String> params) { return AjaxResult.success(dashboard.college(params)); }

    @GetMapping("/personal")
    @PreAuthorize("@ss.hasPermi('achievement:dashboard:personal')")
    public AjaxResult personal(@RequestParam(required=false) Long userId,@RequestParam Map<String,String> params) {
        return AjaxResult.success(dashboard.personal(userId,params));
    }

    @GetMapping("/people")
    @PreAuthorize("@ss.hasPermi('achievement:dashboard:personal')")
    public AjaxResult people() { return AjaxResult.success(dashboard.people()); }
}
