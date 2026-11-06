const { test } = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')
const { ref, reactive, computed } = require('vue')
const { parse } = require('@vue/compiler-sfc')

const read = name => fs.readFileSync(path.join(__dirname, '../src/views/srams/dashboard', name), 'utf8')
const plain = value => JSON.parse(JSON.stringify(value))
function run(context, file, expose) {
  vm.createContext(context)
  vm.runInContext(read('filters.js').replace(/^export /gm, ''), context)
  const script = parse(read(file)).descriptor.scriptSetup.content.replace(/^import .*$/gm, '')
  vm.runInContext(script + `\nglobalThis.app = { ${expose} }`, context)
  return context.app
}

test('级别按业务分组且可直接跨业务多选，切换业务清除范围外的级别', () => {
  const props = reactive({
    modelValue: { categoryCodes: ['paper', 'media', 'patent'], levels: { paper: ['SCI', 'EI'], media: ['省'] } },
    categories: [
      { code: 'paper', group: '论文和专利', levelOptions: ['SCI', 'EI'] },
      { code: 'media', group: '媒体报道', levelOptions: ['国家', '省'] },
      { code: 'patent', group: '论文和专利', levelOptions: [] }
    ]
  })
  const app = run({ computed, defineProps: () => props, defineEmits: () => (_, value) => { props.modelValue = value } },
    'BusinessFilter.vue', 'selectCategories, selectLevels, levelCategories, selectedLevels, businessParams')
  assert.deepEqual(plain(app.levelCategories.value.map(item => item.code)), ['paper', 'media'])
  app.selectCategories(['paper', 'patent'])
  assert.deepEqual(plain(props.modelValue.levels), { paper: ['SCI', 'EI'] })
  app.selectCategories(['paper', 'media'])
  assert.equal(props.modelValue.levels.media, undefined, '重新选择业务不恢复旧级别')
  app.selectLevels(['paper:SCI', 'paper:EI', 'media:国家', 'media:省'])
  assert.deepEqual(plain(app.businessParams(props.modelValue)), { categoryCodes: 'paper,media', level_paper: 'SCI,EI', level_media: '国家,省' })
  app.selectCategories([])
  assert.deepEqual(plain(app.levelCategories.value.map(item => item.code)), ['paper', 'media'])
  assert.deepEqual(plain(app.selectedLevels.value), ['paper:SCI', 'paper:EI', 'media:国家', 'media:省'])
  app.selectLevels(['media:省'])
  assert.deepEqual(plain(app.businessParams(props.modelValue)), { level_media: '省' }, '不选业务也可直接选级别')
  app.selectLevels([])
  assert.deepEqual(plain(app.businessParams(props.modelValue)), {})
  app.selectCategories(['patent'])
  assert.deepEqual(plain(app.levelCategories.value), [], '无级别业务没有级别选项')
  app.selectCategories([])
  assert.deepEqual(plain(app.levelCategories.value.map(item => item.code)), ['paper', 'media'], '清空业务恢复全部级别选项')
})

for (const name of ['college', 'personal']) test(`${name}大屏提交业务与各自级别，重置清除全部筛选`, async () => {
  const requests = []
  const getDashboard = async params => {
    requests.push(plain(params))
    return { data: { categories: [], person: { userId: 1 } } }
  }
  const app = run({
    ref, computed, onMounted() {}, useRoute: () => ({ query: {} }), useSettingsStore: () => ({ isDark: false }),
    getCollegeDashboard: getDashboard, getPersonalDashboard: getDashboard
  }, `${name}.vue`, 'businessFilter, dates, search, reset')
  app.businessFilter.value = { categoryCodes: ['paper', 'media'], levels: { paper: ['SCI', 'EI'], media: ['省'], textbook: ['普通教材'] } }
  app.dates.value = ['2026-01-01', '2026-12-31']
  await app.search()
  assert.equal(requests.at(-1).categoryCodes, 'paper,media')
  assert.equal(requests.at(-1).level_paper, 'SCI,EI')
  assert.equal(requests.at(-1).level_media, '省')
  assert.equal(requests.at(-1).level_textbook, undefined, '不提交未选择业务的残留级别')
  assert.equal(requests.at(-1).levelCode, undefined)
  assert.equal(requests.at(-1).startDate, '2026-01-01')
  app.businessFilter.value = { categoryCodes: [], levels: { paper: ['SCI'], media: ['省'] } }
  await app.search()
  assert.equal(requests.at(-1).categoryCodes, undefined)
  assert.equal(requests.at(-1).level_paper, 'SCI')
  assert.equal(requests.at(-1).level_media, '省')
  await app.reset()
  assert.deepEqual(plain(app.businessFilter.value), { categoryCodes: [], levels: {} })
  const params = requests.at(-1)
  assert.equal(params.categoryCodes, undefined)
  assert.equal(params.startDate, undefined)
  assert.ok(!Object.keys(params).some(key => key.startsWith('level_')))
})
