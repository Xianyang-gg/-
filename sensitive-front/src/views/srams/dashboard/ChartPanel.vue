<template>
  <section class="chart-panel">
    <header class="chart-head">
      <div><h3>{{ title }}</h3><p v-if="subtitle">{{ subtitle }}</p></div>
      <el-button v-if="!chart.empty" link type="primary" @click="tableView = !tableView">{{ tableView ? '查看图表' : '查看表格' }}</el-button>
    </header>
    <el-empty v-if="chart.empty" description="暂无数据" :image-size="72" :style="{ height: `${height}px` }" />
    <el-table v-else-if="tableView" :data="chart.table.rows" size="small" :max-height="height">
      <el-table-column v-for="column in chart.table.columns" :key="column.prop" :prop="column.prop" :label="column.label" min-width="90" />
    </el-table>
    <div v-else ref="chartRef" class="chart-body" role="img" :aria-label="`${title}图表，可切换为表格查看数据`" :style="{ height: `${height}px` }" />
  </section>
</template>

<script setup name="SramsChartPanel">
import { onBeforeUnmount, ref, shallowRef, watch } from 'vue'
import * as echarts from 'echarts'

const props = defineProps({
  title: { type: String, required: true },
  subtitle: { type: String, default: '' },
  chart: { type: Object, required: true },
  height: { type: Number, default: 300 }
})
const chartRef = ref(), tableView = ref(false), instance = shallowRef(null)
let observer = null

function dispose() { observer?.disconnect(); observer = null; instance.value?.dispose(); instance.value = null }
watch(chartRef, element => {
  dispose()
  if (!element) return
  instance.value = echarts.init(element)
  instance.value.setOption(props.chart.option)
  observer = new ResizeObserver(() => instance.value?.resize())
  observer.observe(element)
}, { flush: 'post' })
watch(() => props.chart.option, option => instance.value?.setOption(option, true), { flush: 'post' })
onBeforeUnmount(dispose)
</script>

<style scoped>
.chart-panel{margin-bottom:16px;padding:16px 16px 12px;background:var(--chart-surface,#fcfcfb);border:1px solid var(--chart-ring,rgba(11,11,11,.1));border-radius:8px}
.chart-head{display:flex;align-items:flex-start;justify-content:space-between;gap:12px;margin-bottom:8px}
.chart-head h3{margin:0;color:var(--chart-text,#0b0b0b);font-size:15px;font-weight:600}
.chart-head p{margin:4px 0 0;color:var(--chart-secondary,#52514e);font-size:12px}
.chart-body{width:100%}
</style>
