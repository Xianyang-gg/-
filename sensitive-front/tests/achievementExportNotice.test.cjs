const { test } = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

// 使用可控的请求、弹窗和时钟验证异步交互，无需启动后端或浏览器。
function app(permissions = ['achievement:list']) {
  const source = fs.readFileSync(path.join(__dirname, '../src/utils/achievementExportNotice.js'), 'utf8')
    .replace(/^import .*$/gm, '').replace(/^export /gm, '')
  const user = { token: 'account-A', permissions }, timers = new Map(), requests = [], dialogs = [], routes = [], errors = [], scrolls = []
  let clock = 0, tokenChanged
  const context = {
    useUserStore: () => user,
    watch: (value, callback, options) => { tokenChanged = callback; if (options?.immediate) callback(value()) },
    nextTick: async () => {},
    ElMessage: { error: message => errors.push(message) },
    ElMessageBox: { confirm: (message, title, options) => new Promise((resolve, reject) => dialogs.push({ message, title, options, resolve, reject })) },
    listAchievementExportTasks: () => new Promise((resolve, reject) => requests.push({ resolve, reject })),
    setTimeout: callback => { timers.set(++clock, callback); return clock },
    clearTimeout: id => timers.delete(id),
    document: { getElementById: id => ({ scrollIntoView: () => scrolls.push(id) }) },
    console
  }
  vm.createContext(context)
  vm.runInContext(source, context)
  context.startAchievementExportNotifications({ push: async target => routes.push(target) })
  const flush = async () => { for (let i = 0; i < 8; i++) await Promise.resolve() }
  function tick() {
    const [id, callback] = timers.entries().next().value || []
    assert.ok(callback, '应存在下一次轮询')
    timers.delete(id)
    return callback()
  }
  async function poll(tasks) {
    const response = tick()
    requests.shift().resolve({ data: tasks })
    await response
    await flush()
  }
  return {
    user, timers, requests, dialogs, routes, errors, scrolls, flush, tick, poll,
    track: context.trackAchievementExport,
    changeAccount(token) { user.token = token; tokenChanged([token, user.permissions.some(permission => permission === '*:*:*' || permission === 'achievement:list')]) }
  }
}

test('历史任务不弹窗，排队及生成中不弹窗，完成后选择留在本页', async () => {
  const page = app()
  await page.poll([{ id: 1, status: 2 }])
  assert.equal(page.dialogs.length, 0)
  page.track(2)
  await page.poll([{ id: 2, status: 0 }])
  await page.poll([{ id: 2, status: 1 }])
  assert.equal(page.dialogs.length, 0)
  await page.poll([{ id: 2, status: 2 }])
  assert.equal(page.dialogs.length, 1)
  assert.equal(page.dialogs[0].options.confirmButtonText, '前往导出任务')
  assert.equal(page.dialogs[0].options.cancelButtonText, '留在本页')
  page.dialogs[0].reject('cancel')
  await page.flush()
  assert.equal(page.routes.length, 0)
  assert.equal(page.timers.size, 0, '已结束的任务停止轮询，不重复提示')
})

test('完成后确认跳转成果总览与导出，并定位导出任务区域', async () => {
  const page = app()
  await page.poll([])
  page.track(3)
  await page.poll([{ id: 3, status: 2 }])
  page.dialogs[0].resolve('confirm')
  await page.flush()
  assert.equal(page.routes[0].name, 'Index')
  assert.equal(page.routes[0].hash, '#export-tasks')
  assert.deepEqual(page.scrolls, ['export-tasks'])
})

test('刷新后恢复未完成任务，关闭完成提示保持当前页面', async () => {
  const page = app()
  await page.poll([{ id: 4, status: 1 }])
  await page.poll([{ id: 4, status: 2 }])
  assert.equal(page.dialogs.length, 1)
  page.dialogs[0].reject('close')
  await page.flush()
  assert.equal(page.routes.length, 0)
})

test('失败任务提示原因，停止监听，不弹出成功跳转提示', async () => {
  const page = app()
  await page.poll([])
  page.track(5)
  await page.poll([{ id: 5, status: 3, error_message: '佐证文件无法读取' }])
  assert.deepEqual(page.errors, ['佐证文件无法读取'])
  assert.equal(page.dialogs.length, 0)
  assert.equal(page.timers.size, 0)
})

test('切换账号丢弃旧账号的在途请求，退出后停止轮询', async () => {
  const page = app()
  await page.poll([])
  page.track(6)
  const request = page.tick()
  page.changeAccount('account-B')
  page.requests.shift().resolve({ data: [{ id: 6, status: 2 }] })
  await request
  await page.flush()
  assert.equal(page.dialogs.length, 0)
  await page.poll([{ id: 7, status: 0 }])
  page.changeAccount('')
  assert.equal(page.timers.size, 0)
})

test('完成提示打开后切换账号，旧提示不能触发跳转', async () => {
  const page = app()
  await page.poll([])
  page.track(8)
  await page.poll([{ id: 8, status: 2 }])
  page.changeAccount('account-B')
  page.dialogs[0].resolve('confirm')
  await page.flush()
  assert.equal(page.routes.length, 0)
})

test('无成果权限不查询任务，权限加载后恢复监听', async () => {
  const page = app([])
  assert.equal(page.timers.size, 0)
  assert.equal(page.requests.length, 0)
  page.user.permissions = ['achievement:list']
  page.changeAccount(page.user.token)
  await page.poll([{ id: 9, status: 1 }])
  await page.poll([{ id: 9, status: 2 }])
  assert.equal(page.dialogs.length, 1)
})
