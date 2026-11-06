<template>
  <div class="app-container dashboard-page" :style="vars">
    <div class="dashboard-heading">
      <div><p>数据大屏</p><h2>学院数据大屏</h2></div>
      <div class="heading-tags"><el-tag effect="plain">全院数据 · 只读查看</el-tag></div>
    </div>
    <el-form class="dashboard-filters" inline @submit.prevent="search">
      <el-form-item label="时间范围"><el-date-picker v-model="dates" type="daterange" value-format="YYYY-MM-DD" range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期" /></el-form-item>
      <el-form-item label="所属部门"><el-tree-select v-model="majorDeptId" :data="departments" node-key="id" check-strictly filterable clearable :render-after-expand="false" placeholder="全部部门" /></el-form-item>
      <BusinessFilter v-model="businessFilter" :categories="categories" />
      <el-form-item><el-button type="primary" @click="search">查询</el-button><el-button @click="reset">重置</el-button></el-form-item>
    </el-form>
    <div v-loading="loading && !stats" class="dashboard-body" :class="{ refreshing }">
      <div class="kpi-row">
        <div v-for="tile in kpis" :key="tile.label" class="kpi-tile"><span>{{ tile.label }}</span><strong>{{ tile.value }}<small>{{ tile.unit }}</small></strong></div>
      </div>
      <el-row :gutter="16">
        <el-col :xs="24" :lg="10"><ChartPanel title="业务模块占比" subtitle="六个业务模块的成果数量" :chart="groupChart" /></el-col>
        <el-col :xs="24" :lg="14"><ChartPanel title="年度趋势" subtitle="按成果日期统计，各模块堆叠" :chart="yearChart" /></el-col>
      </el-row>
      <h3 class="section-title">各业务模块子项</h3>
      <el-row :gutter="16" class="module-row">
        <el-col v-for="module in modules" :key="module.group" :xs="24" :md="12" :lg="8">
          <ChartPanel v-if="module.useChart" :title="module.group" :subtitle="`共 ${fmtCount(module.total)} 项`" :chart="module" />
          <ModuleTile v-else :breakdown="module" :subtitle="`${module.items.length} 个子项`" />
        </el-col>
      </el-row>
      <el-row :gutter="16">
        <el-col :xs="24" :lg="12"><ChartPanel title="各部门成果数量" subtitle="按负责人所属部门统计，前 20 个部门" :chart="deptChart" :height="360" /></el-col>
        <el-col :xs="24" :lg="12"><ChartPanel title="负责人成果数量前 10" subtitle="按负责人统计" :chart="ownerChart" :height="360" /></el-col>
      </el-row>
      <ChartPanel title="项目经费" subtitle="四类项目的合同经费与到账经费，单位万元" :chart="fundingChart" />
    </div>
  </div>
</template>

<script setup name="SramsDashboardCollege">
import { computed, onMounted, ref } from 'vue'
import useSettingsStore from '@/store/modules/settings'
import { getAchievementDeptTree } from '@/api/srams/achievement'
import { getCollegeDashboard } from '@/api/srams/dashboard'
import ChartPanel from './ChartPanel.vue'
import ModuleTile from './ModuleTile.vue'
import BusinessFilter from './BusinessFilter.vue'
import { businessParams } from './filters'
import { GROUPS, fmtCount, fmtMoney, fundingBar, groupPie, moduleBreakdown, rankBar, surfaceVars, yearBar } from './charts'

const settings = useSettingsStore()
const dark = computed(() => settings.isDark)
const vars = computed(() => surfaceVars(dark.value))
const loading = ref(true), refreshing = ref(false), stats = ref(null)
const dates = ref([]), majorDeptId = ref(), departments = ref([]), applied = ref({})
const businessFilter = ref({ categoryCodes: [], levels: {} })
const categories = computed(() => stats.value?.categories || [])
const groupChart = computed(() => groupPie(categories.value, dark.value))
const yearChart = computed(() => yearBar(stats.value?.years, categories.value, dark.value))
const modules = computed(() => GROUPS.map(group => moduleBreakdown(categories.value, group, dark.value)))
const deptChart = computed(() => rankBar(stats.value?.departments, '部门', dark.value))
const ownerChart = computed(() => rankBar(stats.value?.topOwners, '负责人', dark.value))
const fundingChart = computed(() => fundingBar(stats.value?.funding, dark.value))
const kpis = computed(() => {
  const summary = stats.value?.summary || {}
  return [
    { label: '成果总数', value: fmtCount(summary.total), unit: '项' },
    { label: '涉及负责人', value: fmtCount(summary.owners), unit: '人' },
    { label: '项目合同经费', value: fmtMoney(summary.contractWan), unit: '万元' },
    { label: '项目到账经费', value: fmtMoney(summary.receivedWan), unit: '万元' }
  ]
})

let sequence = 0
async function load() {
  const current = ++sequence
  refreshing.value = Boolean(stats.value)
  try {
    const result = await getCollegeDashboard(applied.value)
    if (current === sequence) stats.value = result.data
  } finally {
    if (current === sequence) { loading.value = false; refreshing.value = false }
  }
}
function search() {
  applied.value = { startDate: dates.value?.[0], endDate: dates.value?.[1], majorDeptId: majorDeptId.value, ...businessParams(businessFilter.value) }
  return load()
}
function reset() { dates.value = []; majorDeptId.value = undefined; businessFilter.value = { categoryCodes: [], levels: {} }; return search() }
onMounted(() => {
  getAchievementDeptTree().then(result => { departments.value = result.data }).catch(() => {})
  search().catch(() => {})
})
</script>

<style scoped lang="scss">
@use './dashboard.scss';
</style>
