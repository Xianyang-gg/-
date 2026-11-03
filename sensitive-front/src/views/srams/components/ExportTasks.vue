<template>
  <el-card v-if="tasks.length" id="export-tasks" class="export-tasks" shadow="never">
    <template #header><div class="task-heading"><span>我的最近导出任务</span><el-button link type="primary" :loading="loading" @click="refresh">刷新</el-button></div></template>
    <el-table :data="tasks" size="small" max-height="240">
      <el-table-column prop="id" label="任务编号" width="95" />
      <el-table-column prop="content_type" label="内容" min-width="280" show-overflow-tooltip />
      <el-table-column label="格式" width="90"><template #default="{ row }">{{ formats[row.task_type] }}</template></el-table-column>
      <el-table-column prop="created_at" label="提交时间" min-width="165" />
      <el-table-column label="状态" min-width="210"><template #default="{ row }"><el-tag :type="tagType(row)">{{ stateText(row) }}</el-tag><span v-if="row.status === 3" class="task-error">{{ row.error_message }}</span></template></el-table-column>
      <el-table-column label="操作" width="180"><template #default="{ row }">
        <el-button v-if="row.status === 2 && !Number(row.expired)" link type="primary" :loading="downloading === row.id" :disabled="deleting === row.id" @click="download(row)">下载文件</el-button>
        <el-button v-if="row.status === 2 || row.status === 3" link type="danger" :loading="deleting === row.id" :disabled="deleting !== null || downloading === row.id" @click="remove(row)">删除</el-button>
      </template></el-table-column>
    </el-table>
    <p>导出在后台依次生成，可继续录入和查询；刷新或返回页面后仍可下载。文件保留 7 天，失败或过期后请重新提交。</p>
  </el-card>
</template>

<script setup>
import { ref, onMounted, onUnmounted, onActivated, onDeactivated, watch, nextTick } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listAchievementExportTasks, downloadAchievementExport, deleteAchievementExportTask } from '@/api/srams/achievement'
import useUserStore from '@/store/modules/user'

const userStore = useUserStore(), route = useRoute()
const tasks = ref([]), loading = ref(false), downloading = ref(null), deleting = ref(null)
const formats = { 1: 'Excel', 2: 'Word', 3: 'ZIP' }
let timer, active = true, refreshAgain = false, scrollRequested = false
function stateText(task) {
  if (task.status === 0) return Number(task.ahead) ? '排队中，前面还有 ' + task.ahead + ' 个任务' : '排队中'
  if (task.status === 1) return '正在生成'
  if (task.status === 3) return '生成失败'
  return Number(task.expired) ? '已过期' : '已完成'
}
function tagType(task) { return task.status === 3 ? 'danger' : task.status === 2 && !Number(task.expired) ? 'success' : 'info' }
async function refresh() {
  if (!active || !userStore.token) return
  if (loading.value) { refreshAgain = true; return }
  clearTimeout(timer); loading.value = true
  const token = userStore.token
  try {
    const result = await listAchievementExportTasks()
    if (token === userStore.token) {
      tasks.value = result.data
      if (scrollRequested) {
        await nextTick()
        const target = document.getElementById('export-tasks')
        if (target) { target.scrollIntoView({ behavior: 'smooth', block: 'start' }); scrollRequested = false }
      }
    }
  }
  catch { /* 请求层统一提示网络或登录错误；保留已有任务，允许手动重试。 */ }
  finally {
    loading.value = false
    if (active && refreshAgain) { refreshAgain = false; timer = setTimeout(refresh, 0) }
    else if (active && tasks.value.some(task => task.status === 0 || task.status === 1)) timer = setTimeout(refresh, 3000)
  }
}
async function download(task) {
  downloading.value = task.id
  try { await downloadAchievementExport(task.id, task.file_name) }
  finally { downloading.value = null }
}
async function remove(task) {
  if (deleting.value !== null) return
  const token = userStore.token
  deleting.value = task.id
  try {
    try {
      await ElMessageBox.confirm(`是否删除导出任务 #${task.id}？删除后导出文件将一并清除，需要时可重新导出。`, '删除导出任务', {
        confirmButtonText: '删除', cancelButtonText: '取消', type: 'warning'
      })
    } catch { return }
    if (token !== userStore.token) return
    await deleteAchievementExportTask(task.id)
    if (token !== userStore.token) return
    tasks.value = tasks.value.filter(item => item.id !== task.id)
    ElMessage.success('删除成功')
    await refresh()
  } catch { /* 请求层统一提示删除失败。 */ }
  finally { if (token === userStore.token) deleting.value = null }
}
function stop() { active = false; clearTimeout(timer) }
watch(() => userStore.token, () => {
  tasks.value = []; downloading.value = null; deleting.value = null; clearTimeout(timer); refreshAgain = false
  if (userStore.token) refresh()
})
function showTasks() {
  scrollRequested = route.name === 'Index' && route.hash === '#export-tasks'
  return refresh()
}
watch(() => route.hash, () => { if (route.name === 'Index' && route.hash === '#export-tasks') showTasks() })
onMounted(showTasks)
onActivated(() => { active = true; showTasks() })
onDeactivated(stop)
onUnmounted(stop)
defineExpose({ refresh })
</script>

<style scoped>
.export-tasks{margin-top:20px;margin-bottom:16px;scroll-margin-top:20px}.task-heading{display:flex;align-items:center;justify-content:space-between}.task-error{margin-left:10px;color:var(--el-color-danger)}p{margin:12px 0 0;color:#718096;font-size:12px}
</style>
