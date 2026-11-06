<template>
  <section class="module-tile">
    <header><h3>{{ breakdown.group }}</h3><p>{{ subtitle }}</p></header>
    <div class="tile-value">{{ fmtCount(breakdown.total) }}<small>项</small></div>
    <div v-if="multiple && breakdown.total > 0" class="segments" role="img" :aria-label="ariaLabel">
      <span v-for="item in breakdown.items.filter(entry => entry.value > 0)" :key="item.code" :style="{ flexGrow: item.value, background: item.color }" />
    </div>
    <ul>
      <li v-for="item in breakdown.items" :key="item.code">
        <i v-if="multiple" :style="{ background: item.color }" /><span>{{ item.name }}</span>
        <strong>{{ fmtCount(item.value) }}</strong><em v-if="multiple">{{ share(item.value) }}</em>
      </li>
    </ul>
  </section>
</template>

<script setup name="SramsModuleTile">
import { computed } from 'vue'
import { fmtCount } from './charts'

const props = defineProps({ breakdown: { type: Object, required: true }, subtitle: { type: String, default: '' } })
const multiple = computed(() => props.breakdown.items.length > 1)
function share(value) { return props.breakdown.total ? `${(value / props.breakdown.total * 100).toFixed(1)}%` : '—' }
const ariaLabel = computed(() => props.breakdown.items.map(item => `${item.name} ${item.value} 项`).join('，'))
</script>

<style scoped>
.module-tile{margin-bottom:16px;padding:16px;background:var(--chart-surface,#fcfcfb);border:1px solid var(--chart-ring,rgba(11,11,11,.1));border-radius:8px}
header h3{margin:0;color:var(--chart-text,#0b0b0b);font-size:15px;font-weight:600}
header p{margin:4px 0 0;color:var(--chart-secondary,#52514e);font-size:12px}
.tile-value{margin:20px 0 4px;color:var(--chart-text,#0b0b0b);font-size:36px;font-weight:600;line-height:1.2}
.tile-value small{margin-left:4px;color:var(--chart-secondary,#52514e);font-size:13px;font-weight:400}
.segments{display:flex;gap:2px;height:8px;margin:12px 0 16px;border-radius:4px;overflow:hidden}
.segments span{flex-basis:0;min-width:2px}
ul{margin:12px 0 0;padding:0;list-style:none}
li{display:flex;align-items:center;gap:8px;padding:8px 0;border-top:1px solid var(--chart-ring,rgba(11,11,11,.1));font-size:13px}
li i{flex:none;width:10px;height:10px;border-radius:2px}
li span{flex:1;min-width:0;color:var(--chart-secondary,#52514e)}
li strong{color:var(--chart-text,#0b0b0b);font-weight:600}
li em{width:52px;color:var(--chart-muted,#898781);font-style:normal;text-align:right}
</style>
