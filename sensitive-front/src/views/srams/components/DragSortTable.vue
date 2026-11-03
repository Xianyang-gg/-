<template>
  <el-table ref="tableRef" :data="rows" row-key="id" max-height="480" class="drag-sort-table">
    <el-table-column label="拖拽" width="60" align="center">
      <template #default>
        <el-button class="sort-drag-handle" link :disabled="disabled" aria-label="拖拽调整顺序" title="按住拖拽调整顺序"><el-icon><Rank /></el-icon></el-button>
      </template>
    </el-table-column>
    <slot />
  </el-table>
</template>

<script setup>
import { nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { Rank } from '@element-plus/icons-vue'
import Sortable from 'sortablejs'

const props = defineProps({ rows: { type: Array, required: true }, disabled: Boolean })
const emit = defineEmits(['update:rows'])
const tableRef = ref()
let sortable

onMounted(async () => {
  await nextTick()
  const body = tableRef.value?.$el.querySelector('.el-table__body-wrapper tbody')
  if (!body) return
  sortable = Sortable.create(body, {
    handle: '.sort-drag-handle',
    draggable: '.el-table__row',
    animation: 150,
    ghostClass: 'sort-drag-ghost',
    disabled: props.disabled,
    onEnd({ item, oldIndex, newIndex }) {
      if (oldIndex === newIndex || oldIndex == null || newIndex == null) return
      // 先还原 Sortable 的 DOM 移动，再交由 Vue 按记录 ID 更新，避免连续拖拽错位。
      item.remove()
      body.insertBefore(item, body.children[oldIndex] || null)
      const rows = [...props.rows]
      rows.splice(newIndex, 0, rows.splice(oldIndex, 1)[0])
      emit('update:rows', rows)
    }
  })
})
watch(() => props.disabled, value => sortable?.option('disabled', value))
onBeforeUnmount(() => sortable?.destroy())
</script>

<style scoped>
.sort-drag-handle{cursor:grab;padding:6px;color:var(--el-text-color-secondary);touch-action:none}
.sort-drag-handle:active{cursor:grabbing}.sort-drag-handle.is-disabled{cursor:not-allowed}
.sort-drag-handle :deep(.el-icon){font-size:18px}
.drag-sort-table :deep(.sort-drag-ghost>td){background:var(--el-color-primary-light-9)!important}
</style>
