import { getDocument, GlobalWorkerOptions } from 'pdfjs-dist'
import workerUrl from 'pdfjs-dist/build/pdf.worker.min.mjs?url'

GlobalWorkerOptions.workerSrc = workerUrl

// 字体、中文字符映射和解码器随前端构建，预览不依赖外部站点。
const resources = import.meta.glob('/node_modules/pdfjs-dist/{cmaps,standard_fonts,wasm}/*.{bcmap,pfb,ttf,wasm,js}', { eager: true, query: '?url', import: 'default' })
const folders = { cMapUrl: 'cmaps', standardFontDataUrl: 'standard_fonts', wasmUrl: 'wasm' }
class PreviewDataFactory {
  async fetch({ kind, filename }) {
    const url = resources[`/node_modules/pdfjs-dist/${folders[kind]}/${filename}`]
    if (!url) throw new Error('PDF 预览资源不存在')
    const response = await fetch(url)
    if (!response.ok) throw new Error('PDF 预览资源加载失败')
    return new Uint8Array(await response.arrayBuffer())
  }
}

export function loadPreviewPdf(data) {
  return getDocument({ data, BinaryDataFactory: PreviewDataFactory, useWorkerFetch: false, enableXfa: false })
}
