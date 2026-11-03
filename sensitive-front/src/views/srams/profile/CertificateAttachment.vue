<template>
  <div class="certificate-file">
    <div v-if="isImage" v-loading="loading" class="certificate-preview">
      <el-image v-if="previewUrl" :src="previewUrl" :alt="file.original_name" fit="contain" :preview-src-list="[previewUrl]" preview-teleported hide-on-click-modal>
        <template #error><span class="preview-placeholder">图片预览失败，可下载查看</span></template>
      </el-image>
      <span v-else class="preview-placeholder">{{ failed ? '图片预览失败，可下载查看' : '图片加载中' }}</span>
    </div>
    <div class="file-name" :title="file.original_name">{{ file.original_name }}</div>
    <div class="file-actions"><el-button link type="primary" @click="$emit('download')">下载</el-button><el-button v-if="canEdit" link type="danger" @click="$emit('remove')">删除</el-button></div>
  </div>
</template>

<script setup name="SramsCertificateAttachment">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { getAchievementAttachmentBlob } from '@/api/srams/achievement'

const props = defineProps({ file: { type: Object, required: true }, canEdit: Boolean })
defineEmits(['download', 'remove'])
const isImage = computed(() => props.file.mime_type?.startsWith('image/'))
const previewUrl = ref(''), loading = ref(false), failed = ref(false)
let disposed = false
onMounted(async () => {
  if (!isImage.value) return
  loading.value = true
  try {
    const blob = await getAchievementAttachmentBlob(props.file.id)
    if (disposed) return
    if (!blob.type.startsWith('image/')) { failed.value = true; return }
    previewUrl.value = URL.createObjectURL(blob)
  } catch { if (!disposed) failed.value = true }
  finally { if (!disposed) loading.value = false }
})
onBeforeUnmount(() => {
  disposed = true
  if (previewUrl.value) URL.revokeObjectURL(previewUrl.value)
})
</script>

<style scoped>
.certificate-file{width:200px;max-width:100%;padding:12px;border:1px solid #e5eaf0;border-radius:6px;background:#fff}.certificate-preview{display:flex;align-items:center;justify-content:center;height:150px;margin-bottom:10px;background:#f6f8fb;border-radius:4px;overflow:hidden}.certificate-preview .el-image{width:100%;height:100%;cursor:zoom-in}.preview-placeholder{padding:12px;color:#909399;font-size:12px;text-align:center}.file-name{font-size:13px;word-break:break-all;line-height:1.6}.file-actions{display:flex;gap:12px;margin-top:8px}
</style>
