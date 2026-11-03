<template>
  <div class="achievement-export">
    <el-form class="summary-filters achievement-filters" label-position="top" @submit.prevent="search">
      <div class="filter-fields">
      <el-form-item label="成果名称"><el-input v-model="query.keyword" clearable placeholder="请输入成果名称" @keyup.enter="search" /></el-form-item>
      <el-form-item label="负责人"><el-select v-model="query.ownerIds" multiple filterable clearable collapse-tags collapse-tags-tooltip placeholder="全部负责人"><el-option v-for="person in people" :key="person.user_id" :label="person.name" :value="person.user_id" /></el-select></el-form-item>
      <!-- <el-form-item label="业务模块"><el-select v-model="query.categoryGroup" clearable placeholder="全部模块"><el-option v-for="group in groups" :key="group" :label="group" :value="group" /></el-select></el-form-item> -->
      <el-form-item label="业务范围"><el-select v-model="query.categoryCodes" multiple filterable clearable collapse-tags collapse-tags-tooltip placeholder="全部业务"><el-option-group v-for="group in groups" :key="group" :label="group"><el-option v-for="category in metadata.categories.filter(item => item.group === group)" :key="category.code" :label="category.label" :value="category.code" /></el-option-group></el-select></el-form-item>
      <el-form-item label="时间范围"><el-date-picker v-model="dates" type="daterange" value-format="YYYY-MM-DD" start-placeholder="开始日期" end-placeholder="结束日期" range-separator="至" /></el-form-item>
      </div>
      <div class="filter-actions"><el-button type="primary" @click="search">查询</el-button><el-button @click="resetSearch">重置</el-button></div>
    </el-form>
    <div class="toolbar">
      <div><span>共 {{ total }} 条</span><el-tag effect="plain" class="scope-tag">{{ metadata.admin ? '全部管理权限' : metadata.collegeRead ? '全院可查看下载' : '本人负责或参与' }}</el-tag></div>
      <div class="toolbar-actions">
        <el-select v-model="query.sort" style="width:150px" @change="changeSort"><el-option label="自定义排序" value="custom" /><el-option label="按成果日期" value="date" /><el-option label="按负责人" value="owner" /></el-select>
        <el-button :disabled="loading || !total" @click="openSort">调整顺序</el-button>
        <el-dropdown @command="exportData"><el-button :loading="exporting" :disabled="loading || !total">{{ selected.length ? `导出所选 ${selected.length} 条` : '导出查询结果' }}<el-icon class="el-icon--right"><ArrowDown /></el-icon></el-button><template #dropdown><el-dropdown-menu><el-dropdown-item command="1">Excel 表格</el-dropdown-item><el-dropdown-item command="2">Word 佐证材料</el-dropdown-item><el-dropdown-item command="3">附件压缩包</el-dropdown-item></el-dropdown-menu></template></el-dropdown>
      </div>
    </div>
    <el-table ref="tableRef" v-loading="loading" :data="records" row-key="id" @selection-change="selected = $event">
      <el-table-column type="selection" width="48" fixed="left" /><el-table-column type="index" :index="index => (query.pageNum - 1) * query.pageSize + index + 1" label="序号" width="65" />
      <el-table-column prop="name" label="成果名称" min-width="240" show-overflow-tooltip><template #default="{ row }"><el-button link type="primary" @click="openDetail(row)">{{ row.name }}</el-button></template></el-table-column>
      <el-table-column label="业务模块" width="130"><template #default="{ row }">{{ categoryOf(row).group }}</template></el-table-column>
      <el-table-column label="业务范围" min-width="190" show-overflow-tooltip><template #default="{ row }">{{ categoryOf(row).label }}</template></el-table-column>
      <el-table-column prop="owner_name" label="负责人" width="110" />
      <el-table-column prop="achieved_date" label="成果日期" width="120" /><el-table-column prop="level_code" label="级别" width="100" />
      <el-table-column label="佐证" width="80"><template #default="{ row }">{{ row.attachment_count || 0 }} 份</template></el-table-column>
      <el-table-column label="操作" width="80" fixed="right"><template #default="{ row }"><el-button link type="primary" @click="openDetail(row)">查看</el-button></template></el-table-column>
    </el-table>
    <pagination v-show="total > 0" v-model:page="query.pageNum" v-model:limit="query.pageSize" :total="total" @pagination="load" />
    <ExportTasks ref="exportTasks" />
    <el-drawer v-model="detail.open" :title="categoryOf(detail.data).label + '详情'" size="600px" destroy-on-close><template v-if="detail.data"><h3>{{ detail.data.name }}</h3><el-descriptions :column="1" border><el-descriptions-item label="业务范围">{{ categoryOf(detail.data).group }} / {{ categoryOf(detail.data).label }}</el-descriptions-item><el-descriptions-item label="负责人">{{ detail.data.owner_name }}</el-descriptions-item><el-descriptions-item label="成果日期">{{ detail.data.achieved_date }}</el-descriptions-item><el-descriptions-item v-if="detail.data.level_code" label="级别">{{ detail.data.level_code }}</el-descriptions-item><el-descriptions-item v-for="field in categoryOf(detail.data).fields" :key="field.key" :label="field.label">{{ detail.data.detail?.[field.key] ?? '—' }}</el-descriptions-item><el-descriptions-item v-if="detail.data.members?.length && !detail.data.category_code.startsWith('project_')" label="参与人员">{{ memberText(detail.data.members) }}</el-descriptions-item><el-descriptions-item label="备注">{{ detail.data.remark || '—' }}</el-descriptions-item></el-descriptions><h4>佐证材料</h4><AttachmentPreview v-for="file in detail.data.attachments" :key="file.id" :file="file" /><el-empty v-if="!detail.data.attachments?.length" description="暂无佐证材料" /></template></el-drawer>
    <el-dialog v-model="sortDialog.open" title="调整汇总成果顺序" width="860px" destroy-on-close><p class="hint">按住左侧手柄拖拽，或使用上移、下移调整。保存后影响当前账号汇总页的显示与导出顺序。</p><DragSortTable v-model:rows="sortDialog.rows" :disabled="saving"><el-table-column type="index" width="55" /><el-table-column prop="name" label="成果名称" min-width="200" /><el-table-column label="业务范围" min-width="160"><template #default="{ row }">{{ categoryOf(row).label }}</template></el-table-column><el-table-column prop="owner_name" label="负责人" width="100" /><el-table-column label="调整" width="150"><template #default="{ $index }"><el-button link :disabled="saving || $index === 0" @click="moveSort($index,-1)">上移</el-button><el-button link :disabled="saving || $index === sortDialog.rows.length-1" @click="moveSort($index,1)">下移</el-button></template></el-table-column></DragSortTable><template #footer><el-button @click="sortDialog.open=false">取消</el-button><el-button type="primary" :loading="saving" @click="submitSort">保存顺序</el-button></template></el-dialog>
  </div>
</template>

<script setup name="SramsAchievementExport">
import { computed, getCurrentInstance, onMounted, reactive, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { ArrowDown } from '@element-plus/icons-vue'
import { getAchievementMetadata, getAchievementPeople, listAchievement, getAchievement, saveAchievementSort, exportAchievement } from '@/api/srams/achievement'
import { trackAchievementExport } from '@/utils/achievementExportNotice'
import ExportTasks from '../components/ExportTasks.vue'
import AttachmentPreview from '../components/AttachmentPreview.vue'
import DragSortTable from '../components/DragSortTable.vue'
import { roleLabels } from '../config'

const exportTasks = ref()
const { proxy } = getCurrentInstance(), route = useRoute()
const loading = ref(true), exporting = ref(false), saving = ref(false), people = ref([]), dates = ref([])
const records = ref([]), selected = ref([]), total = ref(0), tableRef = ref()
const metadata = reactive({ categories: [], collegeRead: false, admin: false })
const query = reactive({ pageNum: 1, pageSize: 10, keyword: '', ownerIds: [], categoryCodes: [], categoryGroup: '', sort: 'custom' })
const applied = ref({}), detail = reactive({ open: false, data: null }), sortDialog = reactive({ open: false, rows: [] })
const groups = computed(() => [...new Set(metadata.categories.map(item => item.group))])
let loadSequence = 0
function categoryOf(row) { return metadata.categories.find(item => item.code === row?.category_code) || { label: '', group: '', fields: [] } }
function memberText(members) { return members.map(item => `${item.member_name}（${roleLabels[item.member_role] || item.member_role}）`).join('、') }
function filter() { return { ...applied.value, scope: 'summary', sort: query.sort, pageNum: query.pageNum, pageSize: query.pageSize } }
async function load() {
  const sequence = ++loadSequence
  loading.value = true
  try {
    const result = await listAchievement(filter())
    if (sequence !== loadSequence) return
    records.value = result.data.rows; total.value = result.data.total; selected.value = []; tableRef.value?.clearSelection()
  } finally { if (sequence === loadSequence) loading.value = false }
}
function search() {
  query.pageNum = 1
  applied.value = { ...query, ownerIds: [...query.ownerIds], categoryCodes: [...query.categoryCodes], startDate: dates.value?.[0], endDate: dates.value?.[1] }
  return load()
}
function resetSearch() { Object.assign(query, { keyword: '', ownerIds: [], categoryCodes: [], categoryGroup: '', sort: 'custom' }); dates.value = []; return search() }
function changeSort() { query.pageNum = 1; return load() }
async function openDetail(row) { const result = await getAchievement(row.id); detail.data = result.data; detail.open = true }
async function openSort() {
  const result = await listAchievement({ ...filter(), pageNum: 1, pageSize: 5000 })
  if (result.data.total > 5000) { proxy.$modal.msgWarning('请缩小查询范围至 5000 条以内'); return }
  sortDialog.rows = result.data.rows; sortDialog.open = true
}
function moveSort(index, delta) { const other = index + delta; [sortDialog.rows[index], sortDialog.rows[other]] = [sortDialog.rows[other], sortDialog.rows[index]] }
async function submitSort() { saving.value = true; try { await saveAchievementSort('summary', sortDialog.rows.map(row => row.id)); sortDialog.open = false; query.sort = 'custom'; await load() } finally { saving.value = false } }
async function exportData(type) {
  if (exporting.value) return
  exporting.value = true
  try {
    const params = selected.value.length ? { ...filter(), ids: selected.value.map(row => row.id) } : filter()
    const result = await exportAchievement(Number(type), params)
    trackAchievementExport(result.data.id)
    exportTasks.value?.refresh(); proxy.$modal.msgSuccess('已加入导出队列，完成后可在导出任务中下载')
  } finally { exporting.value = false }
}
watch(() => route.query.teacherId, value => {
  if (route.name !== 'Index' || !metadata.userId) return
  query.ownerIds = value ? [Number(value)] : []; search()
})
onMounted(async () => {
  try {
    const [meta, persons] = await Promise.all([getAchievementMetadata(), getAchievementPeople()])
    Object.assign(metadata, meta.data); people.value = persons.data
    query.ownerIds = route.query.teacherId ? [Number(route.query.teacherId)] : []
    await search()
  } finally { loading.value = false }
})
</script>

<style scoped lang="scss">
@use '@/assets/styles/achievement-filters.scss';

.summary-filters{margin-bottom:20px}.toolbar,.toolbar-actions{display:flex;align-items:center;justify-content:space-between;gap:10px}.toolbar{margin:4px 0 16px}.scope-tag{margin-left:12px}.hint{color:#718096;line-height:1.8;margin:0 0 16px}.file-line{display:flex;align-items:center;gap:12px;margin-bottom:10px}.file-line span{flex:1;word-break:break-all}
@media(max-width:1000px){.toolbar{align-items:flex-start;flex-direction:column;gap:14px}.toolbar-actions{flex-wrap:wrap}.summary-filters :deep(.el-form-item){max-width:100%}.summary-filters :deep(.el-form-item__content){max-width:100%}}
</style>
