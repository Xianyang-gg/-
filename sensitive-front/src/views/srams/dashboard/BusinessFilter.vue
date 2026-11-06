<template>
  <el-form-item label="业务模块">
    <el-select :model-value="modelValue.categoryCodes" multiple collapse-tags collapse-tags-tooltip clearable filterable placeholder="全部业务" @update:model-value="selectCategories">
      <el-option-group v-for="group in groups" :key="group" :label="group">
        <el-option v-for="category in categories.filter(item => item.group === group)" :key="category.code" :label="category.label" :value="category.code" />
      </el-option-group>
    </el-select>
  </el-form-item>
  <el-form-item label="级别">
    <el-select :model-value="selectedLevels" multiple collapse-tags collapse-tags-tooltip clearable filterable placeholder="全部级别" @update:model-value="selectLevels">
      <el-option-group v-for="category in levelCategories" :key="category.code" :label="category.label">
        <el-option v-for="level in category.levelOptions" :key="level" :label="`${category.label} · ${level}`" :value="`${category.code}:${level}`">
          <span>{{ level }}</span>
        </el-option>
      </el-option-group>
    </el-select>
  </el-form-item>
  <span class="level-hint">级别可跨业务多选，不选则查询全部级别</span>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: { type: Object, required: true },
  categories: { type: Array, default: () => [] }
})
const emit = defineEmits(['update:modelValue'])
const groups = computed(() => [...new Set(props.categories.map(item => item.group))])
const levelCategories = computed(() => props.categories.filter(item => (!props.modelValue.categoryCodes.length || props.modelValue.categoryCodes.includes(item.code)) && item.levelOptions?.length))
const selectedLevels = computed(() => levelCategories.value.flatMap(category => (props.modelValue.levels[category.code] || []).map(level => `${category.code}:${level}`)))

function selectCategories(categoryCodes) {
  const levels = Object.fromEntries(Object.entries(props.modelValue.levels).filter(([code]) => !categoryCodes.length || categoryCodes.includes(code)))
  emit('update:modelValue', { categoryCodes, levels })
}
function selectLevels(values) {
  const levels = {}
  for (const value of values) {
    const [code, level] = value.split(':')
    if (!levels[code]) levels[code] = []
    levels[code].push(level)
  }
  emit('update:modelValue', { ...props.modelValue, levels })
}
</script>

<style scoped>
.el-form-item { margin: 0; }
.el-select { width: 240px; }
.level-hint { color: var(--chart-secondary); font-size: 12px; }
@media (max-width: 768px) {
  .el-select { width: 100%; }
}
</style>
