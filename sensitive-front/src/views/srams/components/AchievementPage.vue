<template>
  <div class="app-container business-page">
    <div class="page-heading">
      <div><p>{{ category.group }}</p><h2>{{ category.label }}</h2></div>
      <div class="heading-actions">
        <el-button @click="openProfile">教师资料与证书</el-button>
        <el-button @click="openCenter">成果总览与导出</el-button>
        <el-button v-if="metadata.canCreate" type="primary" @click="openCreate">{{ isProject ? '新增项目' : '新增记录' }}</el-button>
      </div>
    </div>
    <el-card shadow="never" class="filter-card">
      <el-form :model="query" class="achievement-filters" label-position="top" @submit.prevent="search">
        <div class="filter-fields">
        <el-form-item :label="config.name"><el-input v-model="query.keyword" clearable :placeholder="`请输入${config.name}`" @keyup.enter="search" /></el-form-item>
        <el-form-item label="负责人"><el-select v-model="query.ownerId" clearable filterable placeholder="选择负责人"><el-option v-for="person in people" :key="person.user_id" :label="person.name" :value="person.user_id" /></el-select></el-form-item>
        <el-form-item v-if="config.level" label="级别"><el-select v-model="query.levelCode" multiple collapse-tags collapse-tags-tooltip clearable filterable allow-create default-first-option placeholder="请选择或输入级别（可多选）"><el-option v-for="level in levels" :key="level" :label="level" :value="level" /></el-select></el-form-item>
        <el-form-item :label="eventField.label"><el-date-picker v-model="dates" type="daterange" value-format="YYYY-MM-DD" range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期" /></el-form-item>
        <el-form-item v-for="field in searchFields" :key="field.key" :label="field.label">
          <el-select v-if="field.type === 'select'" v-model="query[`detail_${field.key}`]" clearable :placeholder="`请选择${field.label}`"><el-option v-for="option in field.options" :key="option" :label="option" :value="option" /></el-select>
          <el-date-picker v-else-if="field.type === 'date'" v-model="fieldDates[field.key]" type="daterange" value-format="YYYY-MM-DD" range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期" />
          <div v-else-if="field.type === 'money' || field.type === 'number'" class="filter-range"><el-input-number v-model="query[`detail_${field.key}Min`]" :min="0" :precision="field.type === 'money' ? 2 : 0" :controls="false" placeholder="最小值" :aria-label="`${field.label}最小值`" /><span>至</span><el-input-number v-model="query[`detail_${field.key}Max`]" :min="0" :precision="field.type === 'money' ? 2 : 0" :controls="false" placeholder="最大值" :aria-label="`${field.label}最大值`" /></div>
          <el-input v-else v-model="query[`detail_${field.key}`]" clearable :placeholder="`请输入${field.label}`" @keyup.enter="search" />
        </el-form-item>
        <el-form-item v-if="config.roles.length" :label="memberLabel"><el-input v-model="query.memberName" clearable placeholder="请输入人员姓名" @keyup.enter="search" /></el-form-item>
        </div>
        <div class="filter-actions"><el-button type="primary" @click="search">查询</el-button><el-button @click="resetSearch">重置</el-button></div>
      </el-form>
    </el-card>
    <div class="toolbar">
      <div><span>共 {{ total }} 条</span><el-tag effect="plain" class="scope-tag">{{ metadata.admin ? '全部管理权限' : metadata.collegeRead ? '全院可查看下载' : isProject ? '本人负责' : '本人负责或参与' }}</el-tag></div>
      <div class="toolbar-actions">
        <el-select v-model="query.sort" style="width:150px" @change="load"><el-option label="自定义排序" value="custom" /><el-option :label="`按${eventField.label}`" value="date" /><el-option label="按负责人" value="owner" /></el-select>
        <el-button @click="openSort">调整顺序</el-button>
        <el-dropdown @command="exportData"><el-button :loading="exporting">{{ selected.length ? `导出所选 ${selected.length} 条` : '导出查询结果' }}<el-icon class="el-icon--right"><ArrowDown /></el-icon></el-button><template #dropdown><el-dropdown-menu><el-dropdown-item command="1">Excel 表格</el-dropdown-item><el-dropdown-item command="2">Word 佐证材料</el-dropdown-item><el-dropdown-item command="3">附件压缩包</el-dropdown-item></el-dropdown-menu></template></el-dropdown>
      </div>
    </div>
    <el-table v-loading="loading" :data="records" row-key="id" @selection-change="selected = $event">
      <el-table-column type="selection" width="48" fixed="left" /><el-table-column type="index" label="序号" width="65" fixed="left" />
      <el-table-column prop="name" :label="config.name" min-width="230" fixed="left" show-overflow-tooltip><template #default="{ row }"><el-button link type="primary" @click="openDetail(row)">{{ row.name }}</el-button></template></el-table-column>
      <el-table-column prop="owner_name" label="负责人" width="110" />
      <el-table-column v-if="config.level" prop="level_code" label="级别" width="110" />
      <el-table-column v-for="field in category.fields" :key="field.key" :label="field.label" :min-width="field.type === 'money' ? 160 : 150" show-overflow-tooltip><template #default="{ row }"><el-link v-if="field.key === 'media_url' && row.detail?.[field.key]" :href="row.detail[field.key]" target="_blank" rel="noopener noreferrer" type="primary">查看报道</el-link><span v-else>{{ row.detail?.[field.key] ?? '—' }}</span></template></el-table-column>
      <el-table-column v-if="config.roles.length" :label="memberLabel" min-width="220" show-overflow-tooltip><template #default="{ row }">{{ memberText(row.members) || '—' }}</template></el-table-column>
      <el-table-column label="佐证" width="80"><template #default="{ row }">{{ row.attachment_count || 0 }} 份</template></el-table-column>
      <el-table-column label="操作" width="170" fixed="right"><template #default="{ row }"><el-button link type="primary" @click="openDetail(row)">查看</el-button><el-button v-if="row.can_edit" link type="primary" @click="openEdit(row)">编辑</el-button><el-button v-if="row.can_edit" link type="danger" @click="remove(row)">删除</el-button></template></el-table-column>
    </el-table>
    <pagination v-show="total > 0" v-model:page="query.pageNum" v-model:limit="query.pageSize" :total="total" @pagination="load" />

    <el-dialog v-model="dialog.open" :title="dialog.title" width="900px" destroy-on-close class="record-dialog">
      <template #header><div class="record-dialog-heading"><span>{{ category.group }}</span><h3>{{ dialog.title }}</h3><p>填写成果信息并上传佐证材料，带 * 的为必填项。</p></div></template>
      <el-form ref="formRef" :model="form" :rules="rules" label-position="top" class="record-form">
        <section class="record-section"><div class="record-section-title"><span>基本信息</span><small>{{ category.label }}</small></div>
        <el-row :gutter="24">
          <el-col :span="24"><el-form-item :label="config.name" prop="name"><el-input v-model="form.name" :placeholder="`请输入${config.name}`" maxlength="255" show-word-limit /></el-form-item></el-col>
          <el-col :xs="24" :sm="12"><el-form-item label="负责人" prop="owner_id"><el-select v-model="form.owner_id" :disabled="!metadata.admin" filterable placeholder="请选择负责人"><el-option v-for="person in people" :key="person.user_id" :label="person.name" :value="person.user_id" /></el-select></el-form-item></el-col>
          <el-col v-if="config.level" :xs="24" :sm="12"><el-form-item label="级别"><el-select v-model="form.level_code" clearable placeholder="请选择级别"><el-option v-for="level in levels" :key="level" :label="level" :value="level" /></el-select></el-form-item></el-col>
        </el-row>
        </section>
        <section class="record-section"><div class="record-section-title"><span>{{ isProject ? '项目详情' : '成果详情' }}</span><small v-if="isProject">经费单位：万元</small></div>
        <div v-if="metadata.recognitionEnabled" class="recognition-bar"><el-upload :show-file-list="false" accept="image/jpeg,image/png" :http-request="recognizeFile"><el-button :loading="recognizing">从佐证图片识别字段</el-button></el-upload><span>请核对识别结果后保存。</span></div>
        <el-row :gutter="24">
          <el-col v-for="field in category.fields" :key="field.key" :xs="24" :sm="field.maxLength > 500 ? 24 : 12">
            <el-form-item :label="field.label" :prop="`detail.${field.key}`">
              <el-select v-if="field.type === 'select'" v-model="form.detail[field.key]" clearable :placeholder="`请选择${field.label}`"><el-option v-for="option in field.options" :key="option" :label="option" :value="option" /></el-select>
              <el-input-number v-else-if="field.type === 'money' || field.type === 'number'" v-model="form.detail[field.key]" :min="0" :precision="field.type === 'money' ? 2 : 0" controls-position="right" :placeholder="field.type === 'money' ? '请输入金额' : '请输入数量'" />
              <el-date-picker v-else-if="field.type === 'date'" v-model="form.detail[field.key]" value-format="YYYY-MM-DD" :placeholder="`请选择${field.label}`" />
              <el-input v-else v-model="form.detail[field.key]" :type="field.maxLength > 500 ? 'textarea' : 'text'" :maxlength="field.maxLength" :placeholder="`请输入${field.label}`" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item v-if="config.roles.length" :label="memberLabel"><div class="members"><div v-for="(member,index) in form.members" :key="index" class="member-row"><el-select v-model="member.member_role" style="width:130px"><el-option v-for="role in config.roles" :key="role" :label="roleLabels[role]" :value="role" /></el-select><el-select v-model="member.user_id" clearable filterable placeholder="院内教师"><el-option v-for="person in people" :key="person.user_id" :label="person.name" :value="person.user_id" /></el-select><el-input v-if="!member.user_id" v-model="member.member_name" placeholder="学生或校外人员姓名" /><el-button link type="danger" @click="form.members.splice(index,1)">移除</el-button></div><el-button link type="primary" @click="addMember">添加人员</el-button></div></el-form-item>
        <el-form-item label="备注"><el-input v-model="form.remark" type="textarea" :rows="3" maxlength="1000" show-word-limit placeholder="可补充其他说明（选填）" /></el-form-item>
        </section>
        <section class="record-section record-evidence-section"><div class="record-section-title"><span>佐证材料</span><small>至少上传一份</small></div>
        <el-form-item class="evidence-item"><div class="attachments"><el-upload class="evidence-upload" drag :show-file-list="false" accept=".jpg,.jpeg,.png,.pdf" :http-request="uploadAttachment" :before-upload="validateUpload"><el-icon class="upload-symbol"><UploadFilled /></el-icon><div class="upload-title">将文件拖到此处，或<span>点击上传</span></div><div class="upload-description">支持 JPG、PNG、PDF，图片最多 2 张</div></el-upload><div v-for="(file,index) in pendingFiles" :key="`pending-${index}`" class="file-line evidence-file"><span>{{ file.name }}（待保存）</span><el-button link type="danger" @click="pendingFiles.splice(index,1)">移除</el-button></div><div v-for="file in form.attachments" :key="file.id" class="file-line evidence-file"><span>{{ file.original_name }}</span><el-button link @click="downloadAttachment(file)">下载</el-button><el-button link type="danger" @click="removeAttachment(file)">删除</el-button></div><p class="hint evidence-limit">源文件不超过 10MB，处理后每份不超过 3MB。</p></div></el-form-item>
        </section>
      </el-form><template #footer><div class="record-dialog-footer"><span>请确认信息与佐证材料一致</span><div><el-button @click="dialog.open=false">取消</el-button><el-button type="primary" :loading="saving" @click="submit">保存</el-button></div></div></template>
    </el-dialog>

    <el-drawer v-model="detail.open" :title="category.label + '详情'" size="600px" destroy-on-close><template v-if="detail.data"><h3>{{ detail.data.name }}</h3><el-descriptions :column="1" border><el-descriptions-item label="负责人">{{ detail.data.owner_name }}</el-descriptions-item><el-descriptions-item v-if="config.level" label="级别">{{ detail.data.level_code || '—' }}</el-descriptions-item><el-descriptions-item v-for="field in category.fields" :key="field.key" :label="field.label">{{ detail.data.detail?.[field.key] ?? '—' }}</el-descriptions-item><el-descriptions-item v-if="config.roles.length" :label="memberLabel">{{ memberText(detail.data.members) || '—' }}</el-descriptions-item><el-descriptions-item label="备注">{{ detail.data.remark || '—' }}</el-descriptions-item></el-descriptions><h4>佐证材料</h4><AttachmentPreview v-for="file in detail.data.attachments" :key="file.id" :file="file" /><el-empty v-if="!detail.data.attachments?.length" description="暂无佐证材料" /></template></el-drawer>
    <el-dialog v-model="sortDialog.open" :title="`调整${category.label}顺序`" width="700px" destroy-on-close><p class="hint">按住左侧手柄拖拽，或使用上移、下移调整。保存后影响当前账号的显示与导出顺序。</p><DragSortTable v-model:rows="sortDialog.rows" :disabled="saving"><el-table-column type="index" width="55" /><el-table-column prop="name" :label="config.name" /><el-table-column label="调整" width="150"><template #default="{ $index }"><el-button link :disabled="saving || $index === 0" @click="moveSort($index,-1)">上移</el-button><el-button link :disabled="saving || $index === sortDialog.rows.length-1" @click="moveSort($index,1)">下移</el-button></template></el-table-column></DragSortTable><template #footer><el-button @click="sortDialog.open=false">取消</el-button><el-button type="primary" :loading="saving" @click="submitSort">保存顺序</el-button></template></el-dialog>
  </div>
</template>

<script setup name="SramsAchievementPage">
import { computed, getCurrentInstance, onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ArrowDown, UploadFilled } from '@element-plus/icons-vue'
import { getAchievementMetadata, getAchievementPeople, deleteAchievementAttachment, downloadAchievementAttachment, uploadAchievementAttachment } from '@/api/srams/achievement'
import { trackAchievementExport } from '@/utils/achievementExportNotice'
import AttachmentPreview from './AttachmentPreview.vue'
import DragSortTable from './DragSortTable.vue'
import { attachmentName, pageConfig, roleLabels } from '../config'

const props = defineProps({ categoryCode: { type: String, required: true }, api: { type: Object, required: true } })
const { proxy } = getCurrentInstance()
const router = useRouter()
const config = pageConfig[props.categoryCode]
const isProject = props.categoryCode.startsWith('project_')
const category = reactive({ label: '', group: '', fields: [] })
const eventField = computed(() => category.fields.find(field => field.key === config.date) || { label: '时间' })
const searchFields = computed(() => category.fields.filter(field => field.key !== config.date))
const fieldDates = reactive({})
const memberLabel = config.roles.map(role => roleLabels[role]).join(' / ')
const levels = ['国家级', '省级', '市级', '校级']
const metadata = reactive({ admin: false, collegeRead: false, canCreate: false, recognitionEnabled: false })
const people = ref([]), records = ref([]), selected = ref([]), total = ref(0), dates = ref([])
const loading = ref(false), saving = ref(false), exporting = ref(false), recognizing = ref(false), pendingFiles = ref([])
const query = reactive({ pageNum: 1, pageSize: 10, keyword: undefined, ownerId: undefined, levelCode: [], memberName: undefined, sort: 'custom' })
const applied = ref({})
const dialog = reactive({ open: false, title: '', editing: false })
const detail = reactive({ open: false, data: null }), sortDialog = reactive({ open: false, rows: [] })
const form = reactive({ id: null, name: '', owner_id: null, level_code: '', remark: '', detail: {}, members: [], attachments: [] })
const rules = { name: [{ required: true, message: `请输入${config.name}` }], owner_id: [{ required: true, message: '请选择负责人' }], [`detail.${config.date}`]: [{ required: true, message: '请选择时间' }] }

function memberText(list = []) { return list.map(item => `${item.member_name}（${roleLabels[item.member_role] || item.member_role}）`).join('、') }
function openCenter() { router.push({ name: 'Index', query: query.ownerId ? { teacherId: query.ownerId } : {}, hash: '#teacher-center' }) }
function openProfile() { router.push({ name: 'Profile', params: { activeTab: 'achievement' }, query: query.ownerId ? { teacherId: query.ownerId } : {} }) }
function filter() { return { ...applied.value, pageNum: query.pageNum, pageSize: query.pageSize, sort: query.sort } }
async function load() {
  loading.value = true
  try { const result = await props.api.list(filter()); records.value = result.data.rows; total.value = result.data.total; selected.value = [] }
  finally { loading.value = false }
}
function search() {
  query.pageNum = 1
  const params = { ...query, levelCode: query.levelCode.join(',') || undefined, startDate: dates.value?.[0], endDate: dates.value?.[1] }
  for (const [key, range] of Object.entries(fieldDates)) { params[`detail_${key}Start`] = range?.[0]; params[`detail_${key}End`] = range?.[1] }
  applied.value = params
  return load()
}
function resetSearch() {
  for (const key of Object.keys(query)) if (key !== 'pageSize') query[key] = undefined
  Object.assign(query, { pageNum: 1, levelCode: [], sort: 'custom' }); dates.value = []
  for (const key of Object.keys(fieldDates)) delete fieldDates[key]
  return search()
}
function openCreate() {
  Object.assign(form, { id: null, name: '', owner_id: metadata.userId, level_code: '', remark: '', detail: Object.fromEntries(category.fields.map(field => [field.key, undefined])), members: [], attachments: [] })
  pendingFiles.value = []; dialog.editing = false; dialog.title = `新增${category.label}`; dialog.open = true
}
async function openEdit(row) {
  const result = await props.api.get(row.id)
  Object.assign(form, result.data, { detail: { ...result.data.detail }, members: (result.data.members || []).map(item => ({ ...item })), attachments: result.data.attachments || [] })
  pendingFiles.value = []; dialog.editing = true; dialog.title = `编辑${category.label}`; dialog.open = true
}
async function openDetail(row) { const result = await props.api.get(row.id); detail.data = result.data; detail.open = true }
function addMember() { form.members.push({ user_id: null, member_name: '', member_role: config.roles[0] }) }
function validateUpload(file) {
  if (!/\.(jpe?g|png|pdf)$/i.test(file.name)) { proxy.$modal.msgWarning('仅支持 JPG、PNG 和 PDF'); return false }
  if (file.size > 10 * 1024 * 1024) { proxy.$modal.msgWarning('源文件不能超过 10MB'); return false }
  const imageCount = pendingFiles.value.filter(item => /\.(jpe?g|png)$/i.test(item.name)).length + form.attachments.filter(item => item.mime_type?.startsWith('image/')).length
  if (/\.(jpe?g|png)$/i.test(file.name) && imageCount >= 2) { proxy.$modal.msgWarning('最多上传 2 张图片'); return false }
  return true
}
async function uploadAttachment(options) {
  if (!dialog.editing) { pendingFiles.value.push(options.file); options.onSuccess(); return }
  try { const result = await uploadAchievementAttachment(options.file, 1, form.id); form.attachments.push({ ...result.data, mime_type: /\.(jpe?g|png)$/i.test(options.file.name) ? 'image/jpeg' : 'application/pdf' }); options.onSuccess() }
  catch (error) { options.onError(error) }
}
async function removeAttachment(file) { await deleteAchievementAttachment(file.id); form.attachments = form.attachments.filter(item => item.id !== file.id) }
function downloadAttachment(file) { return downloadAchievementAttachment(file.id, attachmentName(file)) }
async function submit() {
  const valid = await proxy.$refs.formRef.validate().catch(() => false)
  if (!valid) return
  if (!form.attachments.length && !pendingFiles.value.length) { proxy.$modal.msgWarning('请至少添加一份佐证材料'); return }
  saving.value = true
  try {
    const body = { ...form, achieved_date: form.detail[config.date] }
    if (isProject) delete body.members
    const result = dialog.editing ? await props.api.update(form.id, body) : await props.api.create(body)
    form.id = result.data.id; dialog.editing = true; dialog.title = `编辑${category.label}`
    while (pendingFiles.value.length) {
      const file = pendingFiles.value[0], uploaded = await uploadAchievementAttachment(file, 1, form.id)
      form.attachments.push({ ...uploaded.data, mime_type: /\.(jpe?g|png)$/i.test(file.name) ? 'image/jpeg' : 'application/pdf' }); pendingFiles.value.shift()
    }
    proxy.$modal.msgSuccess('保存成功'); dialog.open = false; await load()
  } finally { saving.value = false }
}
async function remove(row) { await proxy.$modal.confirm(`是否删除“${row.name}”？`); await props.api.remove([row.id]); proxy.$modal.msgSuccess('删除成功'); load() }
async function openSort() {
  const result = await props.api.list({ ...filter(), pageNum: 1, pageSize: 5000 })
  if (result.data.total > 5000) { proxy.$modal.msgWarning('请缩小查询范围至 5000 条以内'); return }
  sortDialog.rows = result.data.rows; sortDialog.open = true
}
function moveSort(index, delta) { const other = index + delta; [sortDialog.rows[index], sortDialog.rows[other]] = [sortDialog.rows[other], sortDialog.rows[index]] }
async function submitSort() { saving.value = true; try { await props.api.sort(sortDialog.rows.map(row => row.id)); sortDialog.open = false; query.sort = 'custom'; await load() } finally { saving.value = false } }
async function exportData(type) {
  if (exporting.value) return
  exporting.value = true
  try { const params = selected.value.length ? { ...filter(), ids: selected.value.map(row => row.id) } : filter(); const result = await props.api.export(Number(type), params); trackAchievementExport(result.data.id); proxy.$modal.msgSuccess('已加入导出队列，完成后会提示前往“成果总览与导出”下载') }
  finally { exporting.value = false }
}
async function recognizeFile(options) {
  recognizing.value = true
  try { await proxy.$modal.confirm('识别图片将发送到学院配置的识别服务，是否继续？'); const result = await props.api.recognize(options.file); if (result.data.name) form.name = result.data.name; Object.assign(form.detail, result.data.detail); if (result.data.achieved_date && !form.detail[config.date]) form.detail[config.date] = result.data.achieved_date; options.onSuccess() }
  catch (error) { options.onError(error) } finally { recognizing.value = false }
}
onMounted(async () => {
  const [meta, persons] = await Promise.all([getAchievementMetadata(), getAchievementPeople()])
  Object.assign(metadata, meta.data); Object.assign(category, meta.data.categories.find(item => item.code === props.categoryCode)); people.value = persons.data
  await search()
})
</script>

<style scoped lang="scss">
@use '@/assets/styles/achievement-filters.scss';

.business-page{background:#f6f8fb;min-height:calc(100vh - 84px)}
.page-heading{display:flex;align-items:center;justify-content:space-between;margin-bottom:20px;padding:24px;background:#fff;border:1px solid #e5eaf0;border-radius:8px}
.page-heading p{margin:0 0 8px;color:#718096;font-size:13px}.page-heading h2{margin:0;font-size:23px;color:#243b53}
.filter-card{margin-bottom:20px}.filter-card :deep(.el-card__body){padding:24px}
.toolbar,.toolbar-actions{display:flex;align-items:center;justify-content:space-between;gap:10px}.toolbar{margin-bottom:16px}.scope-tag{margin-left:12px}

.record-dialog-heading{padding:2px 0 6px}.record-dialog-heading>span{font-size:12px;color:var(--el-color-primary);font-weight:600}.record-dialog-heading h3{margin:6px 0 8px;font-size:22px;font-weight:650;color:var(--el-text-color-primary)}.record-dialog-heading p{margin:0;color:var(--el-text-color-secondary);font-size:13px;line-height:1.6}
.record-form{max-height:62vh;overflow-y:auto;padding:2px 8px 2px 2px;scrollbar-gutter:stable}
.record-section{padding:20px 22px 2px;margin-bottom:16px;border:1px solid var(--el-border-color-lighter);border-radius:12px;background:var(--el-bg-color)}.record-section:last-child{margin-bottom:0}.record-section-title{display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:20px}.record-section-title>span{font-size:15px;font-weight:650;color:var(--el-text-color-primary)}.record-section-title small{font-size:12px;color:var(--el-text-color-secondary)}
.record-form :deep(.el-form-item){margin-bottom:22px}.record-form :deep(.el-form-item__label){font-weight:500;font-size:13px;line-height:20px;padding:0;margin-bottom:8px;color:var(--el-text-color-regular)}.record-form :deep(.el-select),.record-form :deep(.el-date-editor.el-input),.record-form :deep(.el-input-number){width:100%}.record-form :deep(.el-input__wrapper),.record-form :deep(.el-select__wrapper){min-height:38px;border-radius:7px}.record-form :deep(.el-input-number .el-input__inner){text-align:left}.record-form :deep(.el-textarea__inner){border-radius:7px;padding:10px 12px}
.evidence-upload{width:100%}.evidence-upload :deep(.el-upload){width:100%}.evidence-upload :deep(.el-upload-dragger){padding:22px 16px;border-radius:9px;background:var(--el-fill-color-lighter);border-color:var(--el-border-color)}.upload-symbol{font-size:30px;color:var(--el-color-primary);margin-bottom:8px}.upload-title{font-size:14px;color:var(--el-text-color-regular)}.upload-title span{color:var(--el-color-primary);margin-left:4px}.upload-description{font-size:12px;color:var(--el-text-color-secondary);margin-top:8px}.evidence-limit{margin:10px 0 0;line-height:1.8}.evidence-file{padding:10px 12px;margin-top:10px;border:1px solid var(--el-border-color-lighter);border-radius:7px;background:var(--el-fill-color-blank);font-size:13px}
.record-dialog-footer{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:6px 2px 0}.record-dialog-footer>span{font-size:12px;color:var(--el-text-color-secondary)}.record-dialog-footer .el-button{min-width:80px;height:36px;border-radius:7px}
@media(max-width:600px){.record-section{padding:16px 14px 0}.record-section-title{flex-wrap:wrap}.record-dialog-footer>span{display:none}.record-dialog-footer{justify-content:flex-end}.record-form .member-row{flex-wrap:wrap}.record-form .member-row .el-select,.record-form .member-row .el-input{flex-basis:100%}}

.members,.attachments{width:100%}.member-row,.file-line{display:flex;align-items:center;gap:8px;margin-bottom:10px}.member-row .el-select,.member-row .el-input{flex:1}.file-line span{flex:1;word-break:break-all}
.hint,.recognition-bar{font-size:12px;color:#718096}.recognition-bar{display:flex;align-items:center;gap:12px;margin:8px 0 18px}
@media(max-width:1000px){.page-heading,.toolbar{align-items:flex-start;flex-direction:column;gap:14px}.toolbar-actions{flex-wrap:wrap}.heading-actions{display:flex;flex-wrap:wrap;gap:8px}}
</style>

<style lang="scss">
.el-dialog.record-dialog{max-width:calc(100vw - 32px);padding:24px;border-radius:16px}.el-dialog.record-dialog>.el-dialog__header{margin-right:0;padding:0 30px 16px 0;border-bottom:1px solid var(--el-border-color-lighter)}.el-dialog.record-dialog>.el-dialog__body{padding:18px 0 8px}.el-dialog.record-dialog>.el-dialog__footer{padding:14px 0 0;border-top:1px solid var(--el-border-color-lighter)}
@media(max-width:600px){.el-dialog.record-dialog{padding:18px;max-width:calc(100vw - 20px)}}
</style>
