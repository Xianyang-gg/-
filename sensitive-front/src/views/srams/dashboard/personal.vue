<template>
  <div class="app-container dashboard-page" :style="vars">
    <div class="dashboard-heading">
      <div><p>数据大屏</p><h2>个人数据大屏</h2></div>
      <div class="heading-tags">
        <el-tag v-if="person.deptName" effect="plain" type="info">{{ person.deptName }}</el-tag>
        <el-tag effect="plain" :type="viewingOther ? 'warning' : 'primary'">{{ viewingOther ? '只读查看他人数据' : '本人负责或参与' }}</el-tag>
      </div>
    </div>
    <el-form class="dashboard-filters" inline @submit.prevent="search">
      <el-form-item label="账号">
        <el-select v-if="canSwitch" v-model="userId" filterable placeholder="输入姓名或账号搜索" @change="search">
          <el-option v-for="item in people" :key="item.user_id" :label="`${item.name}（${item.user_name}）`" :value="Number(item.user_id)">
            <span>{{ item.name }}（{{ item.user_name }}）</span><span class="option-dept">{{ item.dept_name }}</span>
          </el-option>
        </el-select>
        <span v-else class="person-name">{{ person.name }}<template v-if="person.userName">（{{ person.userName }}）</template></span>
      </el-form-item>
      <el-form-item label="时间范围"><el-date-picker v-model="dates" type="daterange" value-format="YYYY-MM-DD" range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期" /></el-form-item>
      <BusinessFilter v-model="businessFilter" :categories="categories" />
      <el-form-item><el-button type="primary" @click="search">查询</el-button><el-button @click="reset">重置</el-button></el-form-item>
    </el-form>
    <div v-loading="loading && !stats" class="dashboard-body" :class="{ refreshing }">
      <div class="kpi-row">
        <div v-for="tile in kpis" :key="tile.label" class="kpi-tile"><span>{{ tile.label }}</span><strong>{{ tile.value }}<small>{{ tile.unit }}</small></strong></div>
      </div>
      <el-row :gutter="16">
        <el-col :xs="24" :lg="10"><ChartPanel title="业务模块占比" subtitle="本人负责或参与的成果" :chart="groupChart" /></el-col>
        <el-col :xs="24" :lg="14"><ChartPanel title="年度趋势" subtitle="按成果日期统计，各模块堆叠" :chart="yearChart" /></el-col>
      </el-row>
      <ChartPanel title="各子项负责与参与" subtitle="只列有成果的子项；项目类只统计负责人" :chart="roleChart" :height="roleHeight" />
      <h3 class="section-title">各业务模块子项</h3>
      <el-row :gutter="16" class="module-row">
        <el-col v-for="module in modules" :key="module.group" :xs="24" :md="12" :lg="8">
          <ChartPanel v-if="module.useChart" :title="module.group" :subtitle="`共 ${fmtCount(module.total)} 项`" :chart="module" />
          <ModuleTile v-else :breakdown="module" :subtitle="`${module.items.length} 个子项`" />
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup name="SramsDashboardPersonal">
import { computed, onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import useSettingsStore from '@/store/modules/settings'
import { getDashboardPeople, getPersonalDashboard } from '@/api/srams/dashboard'
import ChartPanel from './ChartPanel.vue'
import ModuleTile from './ModuleTile.vue'
import BusinessFilter from './BusinessFilter.vue'
import { businessParams } from './filters'
import { GROUPS, fmtCount, fmtMoney, groupPie, moduleBreakdown, roleBar, surfaceVars, yearBar } from './charts'

const route = useRoute(), settings = useSettingsStore()
const dark = computed(() => settings.isDark)
const vars = computed(() => surfaceVars(dark.value))
const loading = ref(true), refreshing = ref(false), stats = ref(null)
const dates = ref([]), userId = ref(), selfId = ref(), canSwitch = ref(false), people = ref([])
const businessFilter = ref({ categoryCodes: [], levels: {} })
const person = computed(() => stats.value?.person || {})
const viewingOther = computed(() => selfId.value != null && Number(person.value.userId) !== selfId.value)
const categories = computed(() => stats.value?.categories || [])
const groupChart = computed(() => groupPie(categories.value, dark.value))
const yearChart = computed(() => yearBar(stats.value?.years, categories.value, dark.value))
const roleChart = computed(() => roleBar(categories.value, dark.value))
const roleHeight = computed(() => Math.max(220, roleChart.value.table.rows.length * 34 + 64))
const modules = computed(() => GROUPS.map(group => moduleBreakdown(categories.value, group, dark.value)))
const kpis = computed(() => {
  const summary = stats.value?.summary || {}
  return [
    { label: '成果总数', value: fmtCount(summary.total), unit: '项' },
    { label: '本人负责', value: fmtCount(summary.owned), unit: '项' },
    { label: '本人参与', value: fmtCount(summary.participated), unit: '项' },
    { label: '负责项目合同经费', value: fmtMoney(summary.contractWan), unit: '万元' },
    { label: '负责项目到账经费', value: fmtMoney(summary.receivedWan), unit: '万元' }
  ]
})

let sequence = 0
async function search() {
  const current = ++sequence
  refreshing.value = Boolean(stats.value)
  try {
    const result = await getPersonalDashboard({ userId: userId.value, startDate: dates.value?.[0], endDate: dates.value?.[1], ...businessParams(businessFilter.value) })
    if (current !== sequence) return
    stats.value = result.data
    canSwitch.value = Boolean(result.data.canSwitch)
    userId.value = Number(result.data.person.userId)
  } finally {
    if (current === sequence) { loading.value = false; refreshing.value = false }
  }
}
function reset() { dates.value = []; businessFilter.value = { categoryCodes: [], levels: {} }; return search() }
onMounted(async () => {
  try { await search() } catch { return }
  selfId.value = userId.value
  if (!canSwitch.value) return
  people.value = (await getDashboardPeople()).data
  const preset = Number(route.query.userId)
  if (preset && preset !== selfId.value) { userId.value = preset; await search() }
})
</script>

<style scoped lang="scss">
@use './dashboard.scss';
.person-name { color: var(--chart-text); font-weight: 600; }
.option-dept { float: right; margin-left: 16px; color: var(--chart-muted, #898781); font-size: 12px; }
</style>
