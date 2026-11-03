import request from '@/utils/request'
import { saveAs } from 'file-saver'

export const getAchievementMetadata = () => request({ url: '/achievement/metadata', method: 'get' })
export const listAchievement = query => request({ url: '/achievement/list', method: 'get', params: { ...query, ownerIds: Array.isArray(query.ownerIds) ? query.ownerIds.join(',') : query.ownerIds, categoryCodes: Array.isArray(query.categoryCodes) ? query.categoryCodes.join(',') : query.categoryCodes } })
export const getAchievement = id => request({ url: `/achievement/${id}`, method: 'get' })
export const addAchievement = data => request({ url: '/achievement', method: 'post', data })
export const updateAchievement = (id, data) => request({ url: `/achievement/${id}`, method: 'put', data })
export const deleteAchievement = ids => request({ url: '/achievement', method: 'delete', data: { ids } })
export const saveAchievementSort = (categoryCode, ids) => request({ url: '/achievement/sort', method: 'put', data: { categoryCode, ids } })
export const getAchievementProfile = userId => request({ url: `/achievement/profile/${userId}`, method: 'get' })
export const saveAchievementProfile = (userId, data) => request({ url: `/achievement/profile/${userId}`, method: 'put', data })
export const getAchievementPeople = () => request({ url: '/achievement/people', method: 'get' })
export const getAchievementDeptTree = () => request({ url: '/achievement/deptTree', method: 'get' })
export const uploadAchievementAttachment = (file, targetType, achievementId, profileUserId) => {
  const data = new FormData()
  data.append('file', file)
  data.append('targetType', targetType)
  if (achievementId) data.append('achievementId', achievementId)
  if (profileUserId) data.append('profileUserId', profileUserId)
  return request({ url: '/achievement/attachments', method: 'post', data, headers: { 'Content-Type': 'multipart/form-data', repeatSubmit: false }, timeout: 60000 })
}
export const deleteAchievementAttachment = id => request({ url: `/achievement/attachments/${id}`, method: 'delete' })
export const exportAchievement = (type, data) => request({ url: `/achievement/export/${type}`, method: 'post', data })
export const listAchievementExportTasks = () => request({ url: '/achievement/export/tasks', method: 'get' })
export const deleteAchievementExportTask = id => request({ url: `/achievement/export/tasks/${id}`, method: 'delete' })
export const recognizeAchievement = (categoryCode, file) => {
  const data = new FormData(); data.append('categoryCode', categoryCode); data.append('file', file)
  return request({ url: '/achievement/recognize', method: 'post', data, headers: { 'Content-Type': 'multipart/form-data', repeatSubmit: false }, timeout: 120000 })
}
export function downloadAchievementAttachment(id, name) {
  return downloadBlob(`/achievement/attachments/${id}/download`, name)
}
export function getAchievementAttachmentBlob(id) {
  return requestBlob(`/achievement/attachments/${id}/download`)
}
export function downloadAchievementExport(id, name) {
  return downloadBlob(`/achievement/export/${id}/download`, name)
}
function requestBlob(url) {
  return request({ url, method: 'get', responseType: 'blob', timeout: 300000 }).then(async data => {
    if (data.type?.includes('json')) {
      const error = JSON.parse(await data.text())
      throw new Error(error.msg || '下载失败')
    }
    return data
  })
}
function downloadBlob(url, name) {
  return requestBlob(url).then(data => saveAs(data, name))
}
