// 数据大屏图表配置：纯函数，不依赖 echarts，便于 node 测试。
// 颜色按固定槽位分配，跟随实体不跟随排名；文字一律使用文字色，不使用系列色。
const LIGHT = {
  surface: '#fcfcfb', text: '#0b0b0b', secondary: '#52514e', muted: '#898781', grid: '#e1e0d9', axis: '#c3c2b7', ring: 'rgba(11,11,11,0.10)',
  series: ['#2a78d6', '#eb6834', '#1baf7a', '#eda100', '#e87ba4', '#008300', '#6250d6', '#e34948']
}
const DARK = {
  surface: '#1a1a19', text: '#f0efec', secondary: '#c3c2b7', muted: '#898781', grid: '#2c2c2a', axis: '#383835', ring: 'rgba(255,255,255,0.10)',
  series: ['#3987e5', '#d95926', '#199e70', '#c98500', '#d55181', '#008300', '#9085e9', '#e66767']
}
export const GROUPS = ['项目', '获奖', '教材和课程', '论文和专利', '交流合作', '媒体报道']
const FONT = 'system-ui, -apple-system, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif'

export function palette(dark) { return dark ? DARK : LIGHT }
/** 页面根节点上的配色变量，卡片与指标块继承，深浅色在一处切换。 */
export function surfaceVars(dark) {
  const p = palette(dark)
  return { '--chart-surface': p.surface, '--chart-text': p.text, '--chart-secondary': p.secondary, '--chart-muted': p.muted, '--chart-ring': p.ring }
}
export function fmtCount(value) { return Number(value || 0).toLocaleString('zh-CN') }
export function fmtMoney(value) { return Number(value || 0).toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) }
function share(value, total) { return total ? `${(value / total * 100).toFixed(1)}%` : '—' }
function groupColor(group, p) { return p.series[GROUPS.indexOf(group)] || p.muted }

function base(p, tooltip = 'item') {
  return {
    aria: { enabled: true },
    textStyle: { fontFamily: FONT, color: p.secondary },
    tooltip: {
      trigger: tooltip, confine: true, backgroundColor: p.surface, borderColor: p.ring, borderWidth: 1,
      textStyle: { color: p.text, fontSize: 12 }, axisPointer: { type: 'shadow', shadowStyle: { color: 'rgba(137,135,129,0.12)' } }
    },
    legend: { type: 'scroll', top: 0, icon: 'roundRect', itemWidth: 10, itemHeight: 10, textStyle: { color: p.secondary, fontSize: 12 }, pageTextStyle: { color: p.muted } }
  }
}
function categoryAxis(p, data, extra = {}) {
  return { type: 'category', data, axisLine: { lineStyle: { color: p.axis } }, axisTick: { show: false }, axisLabel: { color: p.muted, fontSize: 12 }, ...extra }
}
function valueAxis(p, extra = {}) {
  return { type: 'value', minInterval: 1, splitLine: { lineStyle: { color: p.grid, width: 1, type: 'solid' } }, axisLine: { show: false }, axisLabel: { color: p.muted, fontSize: 12 }, ...extra }
}
function donut(p, name, items) {
  return {
    name, type: 'pie', radius: ['48%', '70%'], center: ['50%', '46%'], avoidLabelOverlap: true, minAngle: 2,
    itemStyle: { borderColor: p.surface, borderWidth: 2, borderRadius: 4 }, label: { show: false }, labelLine: { show: false },
    emphasis: { scale: true, scaleSize: 4 }, data: items.map(item => ({ name: item.name, value: item.value, itemStyle: { color: item.color } }))
  }
}
function donutOption(p, name, items, total) {
  const values = Object.fromEntries(items.map(item => [item.name, item.value]))
  return {
    ...base(p, 'item'),
    tooltip: { ...base(p).tooltip, formatter: params => `${params.marker}${params.name}<br/>${fmtCount(params.value)} 项（${share(params.value, total)}）` },
    legend: { ...base(p).legend, top: 'auto', bottom: 0, formatter: label => `${label}  ${fmtCount(values[label])}` },
    series: [donut(p, name, items)]
  }
}

export function groupTotals(categories = []) {
  return GROUPS.map(group => ({ group, total: categories.filter(c => c.group === group).reduce((sum, c) => sum + Number(c.total || 0), 0) }))
}

/** 六个业务模块占比环形图。 */
export function groupPie(categories = [], dark = false) {
  const p = palette(dark), groups = groupTotals(categories)
  const total = groups.reduce((sum, g) => sum + g.total, 0)
  const items = groups.map(g => ({ name: g.group, value: g.total, color: groupColor(g.group, p) }))
  return {
    empty: total === 0,
    option: donutOption(p, '业务模块', items, total),
    table: { columns: [{ prop: 'name', label: '业务模块' }, { prop: 'value', label: '数量' }, { prop: 'share', label: '占比' }],
      rows: items.map(item => ({ name: item.name, value: fmtCount(item.value), share: share(item.value, total) })) }
  }
}

/** 某个模块的子项分布：子项≥3 时用环形图，否则交给 ModuleTile 用数字与细分段条展示。 */
export function moduleBreakdown(categories = [], group, dark = false) {
  const p = palette(dark)
  const items = categories.filter(c => c.group === group).map((c, index) => ({ code: c.code, name: c.label, value: Number(c.total || 0), color: p.series[index] }))
  const total = items.reduce((sum, item) => sum + item.value, 0)
  return {
    group, total, items, empty: total === 0, useChart: items.length >= 3,
    option: donutOption(p, group, items, total),
    table: { columns: [{ prop: 'name', label: '子项' }, { prop: 'value', label: '数量' }, { prop: 'share', label: '占比' }],
      rows: items.map(item => ({ name: item.name, value: fmtCount(item.value), share: share(item.value, total) })) }
  }
}
/** 年度趋势：按模块堆叠的柱状图，年份升序、中间缺失的年份补 0。 */
export function yearBar(years = [], categories = [], dark = false) {
  const p = palette(dark)
  const groupOf = Object.fromEntries(categories.map(c => [c.code, c.group]))
  const present = years.map(y => Number(y.year)).filter(Number.isFinite)
  const axis = []
  if (present.length) for (let y = Math.min(...present); y <= Math.max(...present); y++) axis.push(y)
  const cells = Object.fromEntries(GROUPS.map(g => [g, axis.map(() => 0)]))
  for (const row of years) {
    const group = groupOf[row.code], index = axis.indexOf(Number(row.year))
    if (group && index >= 0) cells[group][index] += Number(row.total || 0)
  }
  const top = axis.map((_, i) => GROUPS.reduce((last, g, gi) => (cells[g][i] > 0 ? gi : last), -1))
  const series = GROUPS.map((group, gi) => ({
    name: group, type: 'bar', stack: 'year', barMaxWidth: 24,
    itemStyle: { color: groupColor(group, p), borderColor: p.surface, borderWidth: 1 },
    data: cells[group].map((value, i) => ({ value, itemStyle: top[i] === gi ? { borderRadius: [4, 4, 0, 0] } : {} }))
  }))
  return {
    empty: axis.length === 0,
    option: { ...base(p, 'axis'), grid: { left: 8, right: 16, top: 40, bottom: 8, containLabel: true },
      xAxis: categoryAxis(p, axis.map(String)), yAxis: valueAxis(p), series },
    table: { columns: [{ prop: 'year', label: '年度' }, ...GROUPS.map(g => ({ prop: g, label: g })), { prop: 'total', label: '合计' }],
      rows: axis.map((year, i) => ({ year: String(year), ...Object.fromEntries(GROUPS.map(g => [g, fmtCount(cells[g][i])])), total: fmtCount(GROUPS.reduce((s, g) => s + cells[g][i], 0)) })) }
  }
}

/** 排行横向条形图（专业、负责人）：单一系列用一个颜色，最大的在最上面。 */
export function rankBar(rows = [], label, dark = false) {
  const p = palette(dark)
  const sorted = [...rows].map(r => ({ name: r.name, value: Number(r.total || 0) })).sort((a, b) => b.value - a.value)
  return {
    empty: sorted.every(r => r.value === 0),
    option: { ...base(p, 'axis'), legend: { show: false }, grid: { left: 8, right: 40, top: 8, bottom: 8, containLabel: true },
      xAxis: valueAxis(p), yAxis: categoryAxis(p, sorted.map(r => r.name), { inverse: true, axisLabel: { color: p.secondary, fontSize: 12, width: 120, overflow: 'truncate' } }),
      series: [{ name: label, type: 'bar', barMaxWidth: 18, itemStyle: { color: p.series[0], borderRadius: [0, 4, 4, 0] },
        label: { show: true, position: 'right', color: p.secondary, fontSize: 12, formatter: params => fmtCount(params.value) }, data: sorted.map(r => r.value) }] },
    table: { columns: [{ prop: 'rank', label: '排名' }, { prop: 'name', label }, { prop: 'value', label: '成果数量' }],
      rows: sorted.map((r, i) => ({ rank: i + 1, name: r.name, value: fmtCount(r.value) })) }
  }
}

/** 四类项目经费：合同经费与到账经费同为万元，同一坐标轴分组柱状图。 */
export function fundingBar(funding = [], dark = false) {
  const p = palette(dark)
  const names = funding.map(f => f.label)
  const measure = (name, key, color) => ({ name, type: 'bar', barMaxWidth: 24, barGap: '20%', itemStyle: { color, borderRadius: [4, 4, 0, 0] }, data: funding.map(f => Number(f[key] || 0)) })
  return {
    empty: funding.every(f => !Number(f.contractWan) && !Number(f.receivedWan)),
    option: { ...base(p, 'axis'), tooltip: { ...base(p, 'axis').tooltip, valueFormatter: value => `${fmtMoney(value)} 万元` },
      grid: { left: 8, right: 16, top: 40, bottom: 8, containLabel: true },
      xAxis: categoryAxis(p, names, { axisLabel: { color: p.muted, fontSize: 12, interval: 0, width: 84, overflow: 'break' } }), yAxis: valueAxis(p, { minInterval: 0, name: '万元', nameTextStyle: { color: p.muted } }),
      series: [measure('合同经费', 'contractWan', p.series[0]), measure('到账经费', 'receivedWan', p.series[1])] },
    table: { columns: [{ prop: 'name', label: '项目类别' }, { prop: 'contract', label: '合同经费（万元）' }, { prop: 'received', label: '到账经费（万元）' }],
      rows: funding.map(f => ({ name: f.label, contract: fmtMoney(f.contractWan), received: fmtMoney(f.receivedWan) })) }
  }
}

/** 个人页：各子项本人负责与参与的数量，堆叠横向条形图，只列有数据的子项。 */
export function roleBar(categories = [], dark = false) {
  const p = palette(dark)
  const rows = categories.filter(c => Number(c.total || 0) > 0)
    .map(c => ({ name: c.label, owned: Number(c.owned || 0), participated: Number(c.participated || 0), total: Number(c.total || 0) }))
    .sort((a, b) => b.total - a.total)
  const segment = (name, key, color, isTop) => ({
    name, type: 'bar', stack: 'role', barMaxWidth: 18, itemStyle: { color, borderColor: p.surface, borderWidth: 1 },
    data: rows.map(r => ({ value: r[key], itemStyle: isTop(r) ? { borderRadius: [0, 4, 4, 0] } : {} }))
  })
  return {
    empty: rows.length === 0,
    option: { ...base(p, 'axis'), grid: { left: 8, right: 16, top: 40, bottom: 8, containLabel: true },
      xAxis: valueAxis(p), yAxis: categoryAxis(p, rows.map(r => r.name), { inverse: true, axisLabel: { color: p.secondary, fontSize: 12, width: 130, overflow: 'truncate' } }),
      series: [segment('本人负责', 'owned', p.series[0], r => r.participated === 0), segment('本人参与', 'participated', p.series[1], r => r.participated > 0)] },
    table: { columns: [{ prop: 'name', label: '子项' }, { prop: 'owned', label: '本人负责' }, { prop: 'participated', label: '本人参与' }, { prop: 'total', label: '合计' }],
      rows: rows.map(r => ({ name: r.name, owned: fmtCount(r.owned), participated: fmtCount(r.participated), total: fmtCount(r.total) })) }
  }
}
