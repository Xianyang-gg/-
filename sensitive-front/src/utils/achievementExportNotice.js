import { watch, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import useUserStore from '@/store/modules/user'
import { listAchievementExportTasks } from '@/api/srams/achievement'

const pending = new Set()
let userStore, router, timer, loading = false, enabled = false, recoverPending = false, session = 0
let notices = Promise.resolve()

function schedule(delay = 3000) {
  clearTimeout(timer)
  if (enabled && userStore?.token) timer = setTimeout(refresh, delay)
}

async function offerDownload(task, currentSession) {
  if (currentSession !== session || !userStore.token) return
  try {
    await ElMessageBox.confirm(`导出任务 #${task.id} 已完成，是否前往“导出”页面下载文件？`, '导出完成', {
      confirmButtonText: '前往导出任务',
      cancelButtonText: '留在本页',
      type: 'success',
      distinguishCancelAndClose: true
    })
  } catch { return }
  if (currentSession !== session || !userStore.token) return
  await router.push({ name: 'Index', hash: '#export-tasks' })
  await nextTick()
  document.getElementById('export-tasks')?.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

async function refresh() {
  if (loading || !enabled || !userStore.token) return
  loading = true
  const currentSession = session
  try {
    const result = await listAchievementExportTasks()
    if (currentSession !== session) return
    if (recoverPending) {
      result.data.filter(task => task.status === 0 || task.status === 1).forEach(task => pending.add(task.id))
      recoverPending = false
    }
    for (const task of result.data) {
      if (!pending.has(task.id) || (task.status !== 2 && task.status !== 3)) continue
      pending.delete(task.id)
      if (task.status === 3) ElMessage.error(task.error_message || '导出失败，请重新提交')
      else notices = notices.then(() => offerDownload(task, currentSession)).catch(error => console.error('打开导出任务失败', error))
    }
  } catch { /* 请求层统一提示错误，下次轮询继续查询。 */ }
  finally {
    loading = false
    if (pending.size || recoverPending) schedule()
  }
}

// 在应用启动时监听，切换业务页面不会停止完成提示。
export function startAchievementExportNotifications(appRouter) {
  router = appRouter
  userStore = useUserStore()
  watch(() => [userStore.token, userStore.permissions.some(permission => permission === '*:*:*' || permission === 'achievement:list')], ([token, allowed]) => {
    session++
    pending.clear()
    clearTimeout(timer)
    enabled = Boolean(token && allowed)
    recoverPending = enabled
    if (enabled) schedule(0)
  }, { immediate: true })
}

export function trackAchievementExport(taskId) {
  pending.add(taskId)
  schedule(0)
}
