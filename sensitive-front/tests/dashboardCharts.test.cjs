const { test } = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

// 执行数据大屏的图表配置纯函数，验证汇总口径、补零、排序与固定配色。
const context = {}
vm.createContext(context)
vm.runInContext(fs.readFileSync(path.join(__dirname, '../src/views/srams/dashboard/charts.js'), 'utf8').replace(/^export /gm, '')
  + '\nglobalThis.charts = { GROUPS, palette, groupPie, moduleBreakdown, yearBar, rankBar, fundingBar, roleBar, fmtMoney }', context)
const plain = value => JSON.parse(JSON.stringify(value))
const exported = Object.fromEntries(Object.entries(context.charts).map(([key, value]) => [key, typeof value === 'function' ? (...args) => plain(value(...args)) : plain(value)]))
const { GROUPS, palette, groupPie, moduleBreakdown, yearBar, rankBar, fundingBar, roleBar, fmtMoney } = exported

const catalog = [
  ['project_major', '按专业申报的项目', '项目'], ['project_research', '教科研项目', '项目'], ['project_horizontal', '横向项目', '项目'], ['project_student', '指导学生项目', '项目'],
  ['award_teacher', '教师获奖及荣誉称号', '获奖'], ['award_student', '指导学生获奖', '获奖'], ['course', '课程', '教材和课程'], ['textbook', '教材', '教材和课程'],
  ['paper', '论文', '论文和专利'], ['patent', '专利及软件著作权', '论文和专利'], ['patent_transfer', '专利转让', '论文和专利'],
  ['visit', '接待参观与企业洽谈', '交流合作'], ['tech_training', '举办技术交流和公开培训', '交流合作'], ['study_training', '参加培训进修', '交流合作'], ['media', '媒体报道', '媒体报道']
]
function categories(totals = {}, owned = {}) {
  return catalog.map(([code, label, group]) => ({ code, label, group, total: totals[code] || 0, owned: owned[code] || 0, participated: (totals[code] || 0) - (owned[code] || 0) }))
}

test('模块占比按固定顺序汇总，颜色跟随模块而非数量排名', () => {
  const chart = groupPie(categories({ project_major: 2, project_research: 3, media: 7 }))
  const data = chart.option.series[0].data
  assert.deepEqual(data.map(item => item.name), GROUPS)
  assert.deepEqual(data.map(item => item.value), [5, 0, 0, 0, 0, 7])
  assert.equal(data[0].itemStyle.color, palette(false).series[0])
  assert.equal(data[5].itemStyle.color, palette(false).series[5], '数量最多的媒体报道仍用第6个槽位')
  assert.equal(chart.table.rows[5].share, '58.3%')
  assert.equal(chart.empty, false)
  assert.equal(groupPie(categories()).empty, true)
})

test('子项≥3 的模块用环形图，其余用数字卡片', () => {
  const data = categories({ paper: 4, patent: 1 })
  assert.equal(moduleBreakdown(data, '项目').useChart, true)
  assert.equal(moduleBreakdown(data, '获奖').useChart, false)
  assert.equal(moduleBreakdown(data, '媒体报道').items.length, 1)
  const research = moduleBreakdown(data, '论文和专利')
  assert.equal(research.total, 5)
  assert.deepEqual(research.items.map(item => item.value), [4, 1, 0])
  assert.equal(moduleBreakdown(data, '交流合作').empty, true)
})

test('年度趋势补齐缺失年份，只给每列最上方的分段加圆角', () => {
  const chart = yearBar([{ year: 2023, code: 'paper', total: 1 }, { year: 2026, code: 'course', total: 2 }, { year: 2026, code: 'paper', total: 1 }], categories())
  assert.deepEqual(chart.option.xAxis.data, ['2023', '2024', '2025', '2026'])
  assert.deepEqual(chart.table.rows.map(row => row.total), ['1', '0', '0', '3'])
  const series = name => chart.option.series.find(item => item.name === name)
  assert.deepEqual(series('论文和专利').data[3].itemStyle.borderRadius, [4, 4, 0, 0])
  assert.equal(series('教材和课程').data[3].itemStyle.borderRadius, undefined)
  assert.equal(yearBar([], categories()).empty, true)
})

test('排行降序且最大值在最上方；经费按万元保留两位小数', () => {
  const rank = rankBar([{ name: '甲', total: 1 }, { name: '乙', total: 5 }], '专业')
  assert.deepEqual(rank.option.yAxis.data, ['乙', '甲'])
  assert.equal(rank.option.yAxis.inverse, true)
  assert.equal(rankBar([], '专业').empty, true)
  const funding = fundingBar([{ code: 'project_major', label: '按专业申报的项目', contractWan: 10.5, receivedWan: 0 }])
  assert.equal(funding.table.rows[0].contract, fmtMoney(10.5))
  assert.equal(funding.table.rows[0].contract, '10.50')
  assert.equal(funding.option.series.length, 2)
  assert.equal(fundingBar([{ label: '横向项目', contractWan: 0, receivedWan: 0 }]).empty, true)
})

test('个人负责与参与只列有数据的子项，按合计降序', () => {
  const chart = roleBar(categories({ paper: 3, course: 1, project_major: 2 }, { paper: 1, project_major: 2 }))
  assert.deepEqual(chart.table.rows.map(row => row.name), ['论文', '按专业申报的项目', '课程'])
  const [owned, participated] = chart.option.series
  assert.deepEqual(owned.data.map(item => item.value), [1, 2, 0])
  assert.deepEqual(participated.data.map(item => item.value), [2, 0, 1])
  assert.deepEqual(owned.data[1].itemStyle.borderRadius, [0, 4, 4, 0], '没有参与时负责分段是最右端')
  assert.equal(owned.data[0].itemStyle.borderRadius, undefined)
})

test('配色不超过8个槽位且互不重复，深色模式使用对应的深色步长', () => {
  for (const dark of [false, true]) {
    const series = palette(dark).series
    assert.equal(series.length, 8)
    assert.equal(new Set(series).size, 8)
  }
  assert.ok(GROUPS.length <= 8)
  assert.notEqual(palette(true).surface, palette(false).surface)
  assert.equal(groupPie(categories({ media: 1 }), true).option.series[0].data[0].itemStyle.color, palette(true).series[0])
})
