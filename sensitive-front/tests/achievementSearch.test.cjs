const { test } = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')
const { reactive, ref, computed } = require('vue')
const { parse } = require('@vue/compiler-sfc')

// 执行页面实际的查询逻辑，捕获列表和导出请求，验证条件不会丢失或残留。
async function page(summary = false) {
  const requests = [], exports = []
  const snapshot = params => JSON.parse(JSON.stringify(params))
  const api = {
    list: async params => { requests.push(snapshot(params)); return { data: { rows: [], total: 0 } } },
    export: async (type, params) => { exports.push({ type, params: snapshot(params) }); return { data: { id: 1 } } }
  }
  const categories = [{ code: 'project_major', fields: [{ key: 'apply_date', label: '立项时间', type: 'date' }, { key: 'finish_date', label: '结项时间', type: 'date' }, { key: 'contract_wan', label: '合同经费', type: 'money' }] }]
  const context = {
    reactive, ref, computed,
    defineProps: () => ({ categoryCode: 'project_major', api }),
    getCurrentInstance: () => ({ proxy: { $modal: { msgSuccess() {} } } }),
    useRouter: () => ({ push() {} }), useRoute: () => ({ query: {} }), watch() {},
    onMounted: callback => { context.mount = callback },
    getAchievementMetadata: async () => ({ data: { categories, userId: 1 } }),
    getAchievementPeople: async () => ({ data: [] }),
    getAchievementDeptTree: async () => ({ data: [{ id: 2, label: '信息工程学院', children: [{ id: 10, label: '软件技术' }] }] }),
    listAchievement: api.list, exportAchievement: api.export,
    trackAchievementExport() {}
  }
  vm.createContext(context)
  vm.runInContext(fs.readFileSync(path.join(__dirname, '../src/views/srams/config.js'), 'utf8').replace(/^export /gm, ''), context)
  const file = summary ? 'profile/AchievementExport.vue' : 'components/AchievementPage.vue'
  const script = parse(fs.readFileSync(path.join(__dirname, '../src/views/srams', file), 'utf8')).descriptor.scriptSetup.content
  vm.runInContext(script.replace(/^import .*$/gm, '') + '\nglobalThis.page = { query, dates, departments, selected, search, resetSearch, filter, exportData' + (summary ? '' : ', fieldDates, searchFields') + ' }', context)
  await context.mount()
  return { ...context.page, requests, exports }
}

test('业务查询提交全部字段，0 和第二个日期区间均保留，导出使用已查询条件', async () => {
  const app = await page()
  Object.assign(app.query, { ownerId: 8, majorDeptId: 10, levelCode: '国家级', detail_project_type: '工程中心', detail_issuing_unit: '学院', detail_contract_wanMin: 0, detail_contract_wanMax: 10 })
  app.dates.value = ['2026-01-01', '2026-12-31']
  app.fieldDates.finish_date = ['2026-10-01', '2026-10-31']
  await app.search()
  const params = app.requests.at(-1)
  assert.equal(params.ownerId, 8)
  assert.equal(params.majorDeptId, 10)
  assert.equal(app.departments.value[0].children[0].id, 10)
  assert.equal(params.levelCode, '国家级')
  assert.equal(params.detail_issuing_unit, '学院')
  assert.equal(params.detail_project_type, '工程中心')
  assert.equal(params.detail_contract_wanMin, 0)
  assert.equal(params.startDate, '2026-01-01')
  assert.equal(params.detail_finish_dateEnd, '2026-10-31')
  assert.equal(app.searchFields.value.some(field => field.key === 'apply_date'), false, '主日期使用现有区间，不重复显示')
  app.query.majorDeptId = 20
  app.fieldDates.finish_date[1] = '2027-01-01'
  await app.exportData('1')
  assert.deepEqual(app.exports[0].params, params)
})

test('重置清除所有业务及日期筛选，保留每页条数', async () => {
  const app = await page()
  Object.assign(app.query, { pageSize: 20, pageNum: 4, majorDeptId: 10, memberName: '学生', detail_contract_wanMin: 0, detail_issuing_unit: '学院', sort: 'owner' })
  app.fieldDates.finish_date = ['2026-10-01', '2026-10-31']
  await app.search()
  await app.resetSearch()
  const params = app.requests.at(-1)
  assert.equal(params.pageNum, 1)
  assert.equal(params.pageSize, 20)
  assert.equal(params.sort, 'custom')
  assert.ok(Object.entries(params).filter(([key]) => !['pageNum', 'pageSize', 'sort'].includes(key)).every(([, value]) => value === undefined))
})

test('总览查询和导出包含新增条件，重置后清空', async () => {
  const app = await page(true)
  Object.assign(app.query, { majorDeptId: 10, categoryGroup: '项目', levelCode: '国家级' })
  await app.search()
  await app.exportData('1')
  for (const key of ['majorDeptId', 'categoryGroup', 'levelCode']) assert.equal(app.exports[0].params[key], app.requests.at(-1)[key])
  await app.resetSearch()
  const params = app.requests.at(-1)
  assert.equal(params.majorDeptId, undefined)
  assert.equal(params.categoryGroup, '')
  assert.equal(params.levelCode, '')
})

for (const summary of [false, true]) test(`${summary ? '总览' : '业务页'}三种勾选导出均保留已查询的部门 ID`, async () => {
  const app = await page(summary)
  app.query.majorDeptId = 2
  await app.search()
  app.selected.value = [{ id: 101 }, { id: 102 }]
  app.query.majorDeptId = 20
  for (const type of ['1', '2', '3']) {
    await app.exportData(type)
    assert.equal(app.exports.at(-1).type, Number(type))
    assert.equal(app.exports.at(-1).params.majorDeptId, 2)
    assert.deepEqual(app.exports.at(-1).params.ids, [101, 102])
  }
})
