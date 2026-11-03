<template>
  <section class="attachment-preview">
    <div class="attachment-heading"><span>{{ file.original_name }}</span><el-button link type="primary" @click="download">下载完整文件</el-button></div>
    <div v-if="isImage || isPdf" v-loading="loading" class="preview-content">
      <p v-if="loading" class="preview-hint">正在加载预览…</p>
      <p v-if="failed" class="preview-hint">{{ failureMessage }}，可下载完整文件查看。</p>
      <p v-if="isPdf && pageCount" class="preview-hint">共 {{ pageCount }} 页，预览前 {{ Math.min(pageCount, 2) }} 页</p>
      <div v-for="(url, index) in previewUrls" :key="url" class="preview-page">
        <el-image :src="url" :alt="isPdf ? `${file.original_name} 第 ${index + 1} 页` : file.original_name" fit="contain" :preview-src-list="previewUrls" :initial-index="index" preview-teleported hide-on-click-modal @error="failed = true">
          <template #error><span class="preview-hint">预览加载失败，可下载查看</span></template>
        </el-image>
        <div v-if="isPdf" class="page-number">第 {{ index + 1 }} 页</div>
      </div>
    </div>
  </section>
</template>

<script setup name="SramsAttachmentPreview">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { downloadAchievementAttachment, getAchievementAttachmentBlob } from '@/api/srams/achievement'
import { attachmentName } from '../config'

const props = defineProps({ file: { type: Object, required: true } })
const isImage = computed(() => props.file.mime_type?.startsWith('image/') || /\.(jpe?g|png)$/i.test(props.file.original_name))
const isPdf = computed(() => props.file.mime_type === 'application/pdf' || /\.pdf$/i.test(props.file.original_name))
const loading = ref(false), failed = ref(false), failureMessage = ref('预览失败'), previewUrls = ref([]), pageCount = ref(0)
let disposed = false, loadingTask, renderTask
function download() { return downloadAchievementAttachment(props.file.id, attachmentName(props.file)) }
onMounted(async () => {
  if (!isImage.value && !isPdf.value) return
  loading.value = true
  try {
    const blob = await getAchievementAttachmentBlob(props.file.id)
    if (disposed) return
    if (isImage.value) {
      if (!blob.type.startsWith('image/')) throw new Error('Invalid image')
      previewUrls.value.push(URL.createObjectURL(blob))
      return
    }
    const [{ loadPreviewPdf }, data] = await Promise.all([import('./pdfPreview'), blob.arrayBuffer()])
    if (disposed) return
    loadingTask = loadPreviewPdf(new Uint8Array(data))
    loadingTask.onPassword = () => { failureMessage.value = '加密 PDF 暂不支持预览'; loadingTask.destroy().catch(() => {}) }
    const pdf = await loadingTask.promise
    if (disposed) return
    pageCount.value = pdf.numPages
    for (let number = 1; number <= Math.min(pdf.numPages, 2); number++) {
      const page = await pdf.getPage(number)
      if (disposed) return
      const base = page.getViewport({ scale: 1 })
      const viewport = page.getViewport({ scale: Math.min(1.75, 1400 / base.width, 2000 / base.height) })
      const canvas = document.createElement('canvas')
      canvas.width = Math.ceil(viewport.width); canvas.height = Math.ceil(viewport.height)
      renderTask = page.render({ canvasContext: canvas.getContext('2d'), viewport })
      await renderTask.promise
      renderTask = null
      if (disposed) return
      const image = await new Promise(resolve => canvas.toBlob(resolve, 'image/png'))
      canvas.width = canvas.height = 0
      page.cleanup()
      if (disposed) return
      if (!image) throw new Error('PDF render failed')
      previewUrls.value.push(URL.createObjectURL(image))
    }
  } catch { if (!disposed) failed.value = true }
  finally {
    if (!disposed) loading.value = false
    if (loadingTask) await loadingTask.destroy().catch(() => {})
  }
})
onBeforeUnmount(() => {
  disposed = true
  renderTask?.cancel()
  loadingTask?.destroy().catch(() => {})
  previewUrls.value.forEach(url => URL.revokeObjectURL(url))
})
</script>

<style scoped>
.attachment-preview{margin:16px 0;padding:14px;border:1px solid #e5eaf0;border-radius:6px}.attachment-heading{display:flex;align-items:center;justify-content:space-between;gap:12px}.attachment-heading span{min-width:0;word-break:break-all;line-height:1.6}.attachment-heading .el-button{flex-shrink:0}.preview-content{min-height:40px;margin-top:12px}.preview-hint{margin:8px 0;color:#718096;font-size:12px;line-height:1.8}.preview-page{margin-top:12px;padding:8px;background:#f6f8fb;border:1px solid #edf0f5;border-radius:4px}.preview-page .el-image{display:block;width:100%;cursor:zoom-in}.preview-page :deep(.el-image__inner){display:block;width:100%;height:auto}.page-number{text-align:center;color:#909399;font-size:12px;padding-top:8px}
</style>
