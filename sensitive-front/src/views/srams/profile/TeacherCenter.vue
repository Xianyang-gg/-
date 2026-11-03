<template>
  <div v-loading="loading" class="teacher-center">
    <div class="profile-toolbar">
      <el-form inline>
        <el-form-item v-if="metadata.collegeRead" label="教师"><el-select v-model="userId" filterable :disabled="editVisible" @change="loadProfile"><el-option v-for="person in people" :key="person.user_id" :label="person.name" :value="person.user_id" /></el-select></el-form-item>
        <el-form-item v-else label="教师">{{ profile.real_name }}</el-form-item>
      </el-form>
      <div><el-dropdown @command="exportProfile"><el-button :loading="exporting" :disabled="loading || !profile.user_id || Number(profile.user_id) !== Number(userId)">导出<el-icon class="el-icon--right"><ArrowDown /></el-icon></el-button><template #dropdown><el-dropdown-menu><el-dropdown-item command="1">Excel 表格</el-dropdown-item><el-dropdown-item command="2">Word 佐证材料</el-dropdown-item><el-dropdown-item command="3">附件压缩包</el-dropdown-item></el-dropdown-menu></template></el-dropdown><el-button v-if="canEdit" type="primary" @click="openEdit">修改</el-button></div>
    </div>
        <el-form :model="profile" label-width="120px" disabled>
          <el-row :gutter="20"><el-col v-for="field in metadata.profileFields || []" :key="field.key" :xs="24" :md="12"><el-form-item :label="field.label" :prop="field.key"><el-date-picker v-if="field.type === 'date'" v-model="profile[field.key]" value-format="YYYY-MM-DD" /><el-select v-else-if="field.key === 'gender'" v-model="profile.gender" clearable><el-option label="男" :value="1" /><el-option label="女" :value="2" /></el-select><el-input v-else v-model="profile[field.key]" :maxlength="field.maxLength" /></el-form-item></el-col></el-row>
        </el-form>
        <el-divider content-position="left">学历、学位和职称证书</el-divider>
        <div v-for="certificate in certificates" :key="certificate.type" class="certificate-group"><strong>{{ certificate.label }}</strong><div class="certificate-files"><CertificateAttachment v-for="file in (profile.attachments || []).filter(item => item.target_type === certificate.type)" :key="file.id" :file="file" @download="downloadFile(file)" /></div></div>
    <el-dialog v-model="editVisible" title="修改教师资料与证书" width="900px" :style="{ maxWidth: 'calc(100vw - 32px)' }" append-to-body destroy-on-close :close-on-click-modal="false" :close-on-press-escape="!saving" :show-close="!saving">
      <div class="profile-editor">
        <el-form ref="profileForm" :model="editProfile" label-width="120px" :disabled="saving" :rules="{ real_name: [{ required: true, message: '请输入姓名' }] }">
          <el-row :gutter="20"><el-col v-for="field in metadata.profileFields || []" :key="field.key" :xs="24" :md="12"><el-form-item :label="field.label" :prop="field.key"><el-date-picker v-if="field.type === 'date'" v-model="editProfile[field.key]" value-format="YYYY-MM-DD" /><el-select v-else-if="field.key === 'gender'" v-model="editProfile.gender" clearable><el-option label="男" :value="1" /><el-option label="女" :value="2" /></el-select><el-input v-else v-model="editProfile[field.key]" :maxlength="field.maxLength" /></el-form-item></el-col></el-row>
        </el-form>
        <el-divider content-position="left">学历、学位和职称证书</el-divider>
        <el-alert title="证书上传和删除即时生效，取消仅放弃未保存的资料修改。" type="info" :closable="false" show-icon />
        <div v-for="certificate in certificates" :key="certificate.type" class="certificate-group"><strong>{{ certificate.label }}</strong><el-upload :disabled="saving" :show-file-list="false" accept=".jpg,.jpeg,.png,.pdf" :before-upload="validateUpload" :http-request="options => uploadCertificate(options,certificate.type)"><el-button link type="primary" :disabled="saving">上传证书</el-button></el-upload><div class="certificate-files"><CertificateAttachment v-for="file in (profile.attachments || []).filter(item => item.target_type === certificate.type)" :key="file.id" :file="file" :can-edit="!saving" @download="downloadFile(file)" @remove="removeFile(file)" /></div></div>
      </div>
      <template #footer>
        <el-button :disabled="saving" @click="editVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="saveProfile">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="SramsTeacherCenter">
import { computed, getCurrentInstance, onMounted, reactive, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { ArrowDown } from '@element-plus/icons-vue'
import { getAchievementMetadata, getAchievementPeople, getAchievementProfile, saveAchievementProfile, exportAchievement, uploadAchievementAttachment, deleteAchievementAttachment, downloadAchievementAttachment } from '@/api/srams/achievement'
import { trackAchievementExport } from '@/utils/achievementExportNotice'
import { attachmentName } from '../config'
import CertificateAttachment from './CertificateAttachment.vue'

const { proxy } = getCurrentInstance(), route = useRoute()
const loading = ref(false), saving = ref(false), exporting = ref(false), userId = ref(null), people = ref([])
const metadata = reactive({ collegeRead: false, profileFields: [] }), profile = ref({})
const editVisible = ref(false), editProfile = ref({})
const canEdit = computed(() => profile.value.can_edit && Number(profile.value.user_id) === Number(userId.value))
const certificates = [{ type: 2, label: '学历证' }, { type: 3, label: '学位证' }, { type: 4, label: '职称证' }]
watch(() => route.query.teacherId, async value => {
  if (route.name !== 'Profile' || route.params.activeTab !== 'achievement' || !metadata.userId) return
  const targetId = metadata.collegeRead && value ? Number(value) : metadata.userId
  if (targetId !== userId.value) { editVisible.value = false; userId.value = targetId; await loadProfile() }
})
async function loadProfile() { const result = await getAchievementProfile(userId.value); profile.value = result.data }
async function exportProfile(type) {
  if (exporting.value || Number(profile.value.user_id) !== Number(userId.value)) return
  exporting.value = true
  try {
    const result = await exportAchievement(Number(type), { scope: 'profile', profileUserId: userId.value })
    trackAchievementExport(result.data.id)
    proxy.$modal.msgSuccess('已加入导出队列，完成后可在首页导出任务中下载')
  } finally { exporting.value = false }
}
function openEdit() { if (!canEdit.value) return; editProfile.value = { ...profile.value }; editVisible.value = true }
async function saveProfile() {
  if (saving.value || !canEdit.value || !await proxy.$refs.profileForm.validate().catch(() => false)) return
  saving.value = true
  try { await saveAchievementProfile(userId.value, editProfile.value); await loadProfile(); editVisible.value = false; proxy.$modal.msgSuccess('保存成功') }
  finally { saving.value = false }
}
function validateUpload(file) { if (!/\.(jpe?g|png|pdf)$/i.test(file.name) || file.size > 10 * 1024 * 1024) { proxy.$modal.msgWarning('请选择不超过 10MB 的 JPG、PNG 或 PDF'); return false } return true }
async function uploadCertificate(options, type) { try { await uploadAchievementAttachment(options.file, type, null, userId.value); options.onSuccess(); await loadProfile() } catch (error) { options.onError(error) } }
function downloadFile(file) { return downloadAchievementAttachment(file.id, attachmentName(file)) }
async function removeFile(file) { await proxy.$modal.confirm('是否删除此证书附件？'); await deleteAchievementAttachment(file.id); await loadProfile() }
onMounted(async () => {
  loading.value = true
  try { const [meta, persons] = await Promise.all([getAchievementMetadata(), getAchievementPeople()]); Object.assign(metadata, meta.data); people.value = persons.data; userId.value = metadata.collegeRead && route.query.teacherId ? Number(route.query.teacherId) : metadata.userId; await loadProfile() }
  finally { loading.value = false }
})
</script>

<style scoped>
.profile-toolbar{display:flex;align-items:flex-start;justify-content:space-between;gap:16px}.teacher-center :deep(.el-select),.teacher-center :deep(.el-date-editor){max-width:100%}.profile-editor{max-height:65vh;overflow-y:auto;padding-right:12px}.profile-editor :deep(.el-select),.profile-editor :deep(.el-date-editor){width:100%;max-width:100%}.certificate-group{padding:16px 0;border-bottom:1px solid #e7edf3;margin-bottom:16px}.certificate-group>.el-upload{margin-left:16px}.certificate-files{display:flex;flex-wrap:wrap;gap:16px;margin-top:12px}
</style>
