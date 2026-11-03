<template>
  <div class="login">
    <div class="auth-marble auth-marble--one"></div>
    <div class="auth-marble auth-marble--two"></div>

    <main class="auth-layout">
      <section class="login-card">
        <div class="login-header">
          <div class="login-badge">
            <img :src="logo" alt="" class="badge-logo" />
          </div>
          <div>
            <h3 class="title">{{ title }}</h3>
            <p class="subtitle">欢迎回来，请登录您的账户</p>
          </div>
        </div>

        <el-form ref="loginRef" :model="loginForm" :rules="loginRules" class="login-form">
          <el-form-item prop="username">
            <el-input
              v-model="loginForm.username"
              type="text"
              autocomplete="off"
              placeholder="账号 / 用户名"
              clearable
            >
              <template #prefix><svg-icon icon-class="user" class="el-input__icon input-icon" /></template>
            </el-input>
          </el-form-item>

          <el-form-item prop="password">
            <el-input
              v-model="loginForm.password"
              type="password"
              autocomplete="off"
              placeholder="密码"
              show-password
              @keyup.enter="handleLogin"
            >
              <template #prefix><svg-icon icon-class="password" class="el-input__icon input-icon" /></template>
            </el-input>
          </el-form-item>

          <el-form-item prop="code" v-if="captchaEnabled" class="login-code-item">
            <div class="code-input-wrapper">
              <el-input
                v-model="loginForm.code"
                autocomplete="off"
                placeholder="验证码"
                maxlength="4"
                @keyup.enter="handleLogin"
              >
                <template #prefix><svg-icon icon-class="validCode" class="el-input__icon input-icon" /></template>
              </el-input>
              <div class="login-code" @click="getCode" title="点击刷新">
                <img :src="codeUrl" class="login-code-img" />
              </div>
            </div>
          </el-form-item>

          <div class="login-actions">
            <el-checkbox v-model="loginForm.rememberMe">记住密码</el-checkbox>
            <router-link v-if="register" class="link-type" :to="'/register'">立即注册</router-link>
          </div>

          <el-form-item class="login-submit">
            <el-button
              :loading="loading"
              type="primary"
              class="login-btn"
              @click.prevent="handleLogin"
              native-type="submit"
            >
              <span v-if="!loading">登 录</span>
              <span v-else>登 录 中...</span>
            </el-button>
          </el-form-item>
        </el-form>
      </section>

      <aside class="auth-note" aria-hidden="true">
        <p class="note-mark">// welcome back :)</p>
        <p class="note-face">(｡•̀ᴗ-)✧</p>
        <p class="note-copy">Blue marble, calm access.</p>
      </aside>
    </main>
    <!--  底部  -->
    <div class="el-login-footer">
      <span>{{ footerContent }}</span>
    </div>
  </div>
</template>

<script setup>
import { getCodeImg } from "@/api/login"
import Cookies from "js-cookie"
import { encrypt, decrypt } from "@/utils/jsencrypt"
import useUserStore from '@/store/modules/user'
import defaultSettings from '@/settings'
import logo from '@/assets/logo/sensitive-logo.svg'

const title = import.meta.env.VITE_APP_TITLE
const footerContent = defaultSettings.footerContent
const userStore = useUserStore()
const route = useRoute()
const router = useRouter()
const { proxy } = getCurrentInstance()

const loginForm = ref({
  username: "admin",
  password: "admin123",
  rememberMe: false,
  code: "",
  uuid: ""
})

const loginRules = {
  username: [{ required: true, trigger: "blur", message: "请输入您的账号" }],
  password: [{ required: true, trigger: "blur", message: "请输入您的密码" }],
  code: [{ required: true, trigger: "change", message: "请输入验证码" }]
}

const codeUrl = ref("")
const loading = ref(false)
// 验证码开关
const captchaEnabled = ref(true)
// 注册开关
const register = ref(false)
const redirect = ref(undefined)

watch(route, (newRoute) => {
    redirect.value = newRoute.query && newRoute.query.redirect
}, { immediate: true })

function handleLogin() {
  proxy.$refs.loginRef.validate(valid => {
    if (valid) {
      loading.value = true
      // 勾选了需要记住密码设置在 cookie 中设置记住用户名和密码
      if (loginForm.value.rememberMe) {
        Cookies.set("username", loginForm.value.username, { expires: 30 })
        Cookies.set("password", encrypt(loginForm.value.password), { expires: 30 })
        Cookies.set("rememberMe", loginForm.value.rememberMe, { expires: 30 })
      } else {
        // 否则移除
        Cookies.remove("username")
        Cookies.remove("password")
        Cookies.remove("rememberMe")
      }
      // 调用action的登录方法
      userStore.login(loginForm.value).then(() => {
        const query = route.query
        const otherQueryParams = Object.keys(query).reduce((acc, cur) => {
          if (cur !== "redirect") {
            acc[cur] = query[cur]
          }
          return acc
        }, {})
        router.push({ path: redirect.value || "/", query: otherQueryParams })
      }).catch(() => {
        loading.value = false
        // 重新获取验证码
        if (captchaEnabled.value) {
          getCode()
        }
      })
    }
  })
}

function getCode() {
  getCodeImg().then(res => {
    captchaEnabled.value = res.captchaEnabled === undefined ? true : res.captchaEnabled
    if (captchaEnabled.value) {
      codeUrl.value = "data:image/gif;base64," + res.img
      loginForm.value.uuid = res.uuid
    }
  })
}

function getCookie() {
  const username = Cookies.get("username")
  const password = Cookies.get("password")
  const rememberMe = Cookies.get("rememberMe")
  loginForm.value = {
    username: username === undefined ? loginForm.value.username : username,
    password: password === undefined ? loginForm.value.password : decrypt(password),
    rememberMe: rememberMe === undefined ? false : Boolean(rememberMe)
  }
}

getCode()
getCookie()
</script>

<style lang='scss' scoped>
.login {
  position: relative;
  min-height: 100vh;
  padding: 72px 56px 64px;
  overflow: hidden;
  --auth-primary: #2f7df6;
  --auth-primary-soft: #73b7ff;
  --auth-ink: #1b2b44;
  --auth-muted: #6e7e96;
  --auth-border: rgba(91, 128, 174, 0.18);
  --auth-line: rgba(71, 104, 148, 0.12);
  --auth-transition: all 0.2s ease;
  background:
    linear-gradient(118deg, transparent 0 13%, rgba(96, 130, 170, 0.18) 13.2%, transparent 14.2% 100%),
    linear-gradient(142deg, transparent 0 31%, rgba(45, 112, 192, 0.16) 31.25%, rgba(255, 255, 255, 0.52) 31.75%, transparent 33.4% 100%),
    linear-gradient(154deg, transparent 0 47%, rgba(128, 158, 195, 0.2) 47.2%, transparent 48.3% 100%),
    linear-gradient(28deg, transparent 0 62%, rgba(255, 255, 255, 0.72) 62.25%, rgba(94, 143, 202, 0.12) 62.7%, transparent 64.2% 100%),
    radial-gradient(ellipse at 20% 18%, rgba(255, 255, 255, 0.94), transparent 34%),
    radial-gradient(ellipse at 64% 18%, rgba(183, 216, 251, 0.68), transparent 36%),
    radial-gradient(ellipse at 86% 76%, rgba(228, 235, 245, 0.86), transparent 42%),
    repeating-radial-gradient(circle at 18% 30%, rgba(78, 105, 140, 0.055) 0 1px, transparent 1px 9px),
    linear-gradient(135deg, #fbfdff 0%, #eef7ff 42%, #ffffff 100%);
}

.login::before,
.login::after {
  position: absolute;
  inset: 0;
  content: "";
  pointer-events: none;
}

.login::before {
  opacity: 0.82;
  background:
    linear-gradient(126deg, transparent 0 19%, rgba(60, 91, 128, 0.16) 19.08%, rgba(255, 255, 255, 0.58) 19.42%, transparent 20.3% 100%),
    linear-gradient(132deg, transparent 0 23%, rgba(94, 132, 178, 0.12) 23.08%, transparent 23.8% 100%),
    linear-gradient(148deg, transparent 0 54%, rgba(87, 126, 174, 0.16) 54.15%, rgba(255, 255, 255, 0.54) 54.5%, transparent 55.6% 100%),
    linear-gradient(158deg, transparent 0 71%, rgba(155, 177, 202, 0.18) 71.1%, transparent 72.2% 100%),
    linear-gradient(24deg, transparent 0 62%, rgba(255, 255, 255, 0.78) 62.35%, rgba(96, 145, 202, 0.12) 62.9%, transparent 64% 100%);
}

.login::after {
  opacity: 0.48;
  mix-blend-mode: multiply;
  background:
    repeating-radial-gradient(circle at 30% 38%, rgba(52, 83, 121, 0.06) 0 1px, transparent 1px 7px),
    repeating-radial-gradient(circle at 75% 56%, rgba(255, 255, 255, 0.5) 0 1px, transparent 1px 11px),
    linear-gradient(114deg, transparent 0 36%, rgba(73, 109, 154, 0.12) 36.1%, transparent 36.9% 100%),
    radial-gradient(ellipse at 35% 62%, rgba(255, 255, 255, 0.42), transparent 38%);
}

.auth-marble {
  position: absolute;
  border-radius: 50%;
  filter: blur(4px);
  opacity: 0.62;
  pointer-events: none;

  &--one {
    width: 420px;
    height: 420px;
    top: -150px;
    right: 14%;
    background: radial-gradient(circle, rgba(93, 159, 239, 0.18), transparent 70%);
  }

  &--two {
    width: 360px;
    height: 360px;
    bottom: -130px;
    left: 8%;
    background: radial-gradient(circle, rgba(255, 255, 255, 0.74), transparent 70%);
  }
}

.auth-layout {
  position: relative;
  z-index: 1;
  display: grid;
  grid-template-columns: minmax(360px, 440px) minmax(280px, 1fr);
  align-items: center;
  gap: min(10vw, 132px);
  width: min(1180px, 100%);
  min-height: calc(100vh - 136px);
  margin: 0 auto;
  transform: translateX(-5vw);
}

.login-card {
  position: relative;
  width: 100%;
  max-width: calc(100vw - 40px);
  padding: 34px 34px 30px;
  overflow: hidden;
  background: rgba(255, 255, 255, 0.76);
  backdrop-filter: blur(24px);
  border: 1px solid rgba(255, 255, 255, 0.86);
  border-radius: 18px;
  box-shadow: 0 26px 70px rgba(47, 88, 140, 0.18), 0 8px 22px rgba(52, 92, 143, 0.08);
  transition: var(--auth-transition);

  &::before {
    position: absolute;
    inset: 0;
    content: "";
    pointer-events: none;
    background:
      linear-gradient(135deg, rgba(255, 255, 255, 0.9), transparent 38%),
      linear-gradient(152deg, transparent 0 62%, rgba(91, 151, 225, 0.08) 63%, transparent 68%);
  }

  > * {
    position: relative;
    z-index: 1;
  }

  &:hover {
    box-shadow: 0 30px 82px rgba(47, 88, 140, 0.21), 0 10px 26px rgba(52, 92, 143, 0.1);
  }
}

.login-header {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 30px;

  .login-badge {
    flex: 0 0 58px;
    width: 58px;
    height: 58px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    border-radius: 16px;
    background: linear-gradient(135deg, #2f7df6, #7fc5ff);
    box-shadow: 0 12px 26px rgba(47, 125, 246, 0.28);
    font-size: 28px;
    transition: var(--auth-transition);

    .badge-logo {
      width: 38px;
      height: 38px;
      display: block;
      filter: drop-shadow(0 6px 10px rgba(24, 91, 166, 0.18));
    }

    &:hover {
      transform: translateY(-1px);
      box-shadow: 0 15px 32px rgba(47, 125, 246, 0.34);
    }
  }

  .title {
    margin: 0 0 6px;
    font-size: 26px;
    font-weight: 700;
    color: var(--auth-ink);
    letter-spacing: 0;
  }

  .subtitle {
    margin: 0;
    font-size: 14px;
    color: var(--auth-muted);
    font-weight: 400;
  }
}

.login-form {
  .el-form-item {
    margin-bottom: 20px;

    &:last-of-type {
      margin-bottom: 0;
    }
  }

  .el-input {
    --el-input-text-color: var(--auth-ink);
    --el-input-border-color: var(--auth-border);
    --el-input-focus-border-color: var(--auth-primary);
    --el-input-bg-color: rgba(255, 255, 255, 0.86);
    --el-input-hover-border-color: var(--auth-primary);
    --el-input-border-radius: 8px;

    .el-input__wrapper {
      height: 46px;
      padding: 0 14px;
      border: 1px solid var(--auth-border);
      border-radius: 10px;
      background-color: rgba(255, 255, 255, 0.78);
      transition: var(--auth-transition);
      box-shadow: none;

      &:hover {
        border-color: rgba(47, 125, 246, 0.42);
        background-color: rgba(255, 255, 255, 0.94);
      }

      &.is-focus {
        border-color: var(--auth-primary);
        background-color: #fff;
        box-shadow: 0 0 0 3px rgba(47, 125, 246, 0.1);
      }
    }

    .el-input__inner {
      color: var(--auth-ink);
      font-size: 14px;
      font-weight: 400;

      &::placeholder {
        color: #a0acbd;
      }
    }

    .input-icon {
      width: 16px;
      height: 16px;
      margin-right: 8px;
      color: #9aa8bb;
      transition: var(--auth-transition);
    }
  }

  .el-input.is-focus .input-icon {
    color: var(--auth-primary);
  }

  .login-code-item {
    margin-bottom: 20px;

    .code-input-wrapper {
      display: flex;
      gap: 8px;
      align-items: stretch;

      .el-input {
        flex: 1;
        min-width: 0;
      }

      .login-code {
        flex: 0 0 110px;
        height: 46px;
        cursor: pointer;
        border-radius: 10px;
        overflow: hidden;
        transition: var(--auth-transition);
        border: 1px solid var(--auth-border);
        background: rgba(255, 255, 255, 0.78);

        &:hover {
          border-color: rgba(47, 125, 246, 0.42);
          box-shadow: 0 4px 12px rgba(47, 125, 246, 0.14);
        }

        .login-code-img {
          width: 100%;
          height: 100%;
          object-fit: cover;
          display: block;
        }
      }
    }
  }

  .login-submit {
    margin-bottom: 0;

    .login-btn {
      width: 100%;
    }
  }
}

.login-actions {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin: 16px 0 24px;
  font-size: 13px;

  .el-checkbox {
    --el-checkbox-text-color: var(--auth-muted);
    --el-checkbox-input-border-color: var(--auth-border);
    --el-checkbox-input-border-color-hover: var(--auth-primary);
  }

  .link-type {
    color: var(--auth-primary);
    text-decoration: none;
    font-weight: 500;
    transition: var(--auth-transition);

    &:hover {
      color: #2563eb;
      text-decoration: underline;
    }
  }
}

.login-btn {
  width: 100% !important;
  height: 44px !important;
  margin: 0 !important;
  font-size: 14px !important;
  font-weight: 600 !important;
  letter-spacing: 2px !important;
  border: none !important;
  border-radius: 10px !important;
  background: linear-gradient(135deg, #2f7df6, #79bfff) !important;
  color: #fff !important;
  box-shadow: 0 12px 22px rgba(47, 125, 246, 0.26) !important;
  transition: all 0.2s ease !important;
}

.login-btn:hover:not(:disabled) {
  transform: translateY(-2px) !important;
  box-shadow: 0 16px 28px rgba(47, 125, 246, 0.34) !important;
}

.login-btn:active:not(:disabled) {
  transform: translateY(0) !important;
}

.login-btn:disabled {
  opacity: 0.8;
  cursor: not-allowed;
}

.el-login-footer {
  height: 40px;
  line-height: 40px;
  position: fixed;
  bottom: 0;
  width: 100%;
  text-align: center;
  color: rgba(69, 89, 115, 0.58);
  font-size: 12px;
  letter-spacing: 0.5px;
  background: rgba(255, 255, 255, 0.44);
  backdrop-filter: blur(10px);
  border-top: 1px solid rgba(0, 0, 0, 0.05);
}

.auth-note {
  min-width: 0;
  color: rgba(27, 43, 68, 0.7);
  font-style: italic;
  text-align: left;
  transform: rotate(-3deg);
  user-select: none;

  .note-mark {
    margin: 0 0 12px;
    font-size: clamp(20px, 2vw, 32px);
    font-weight: 600;
    color: rgba(47, 125, 246, 0.72);
  }

  .note-face {
    margin: 0 0 18px;
    font-size: clamp(52px, 7vw, 110px);
    line-height: 0.95;
    color: rgba(27, 43, 68, 0.18);
    text-shadow: 0 18px 36px rgba(67, 117, 177, 0.12);
  }

  .note-copy {
    max-width: 320px;
    margin: 0;
    font-size: clamp(15px, 1.4vw, 20px);
    line-height: 1.7;
    color: rgba(70, 91, 120, 0.62);
  }
}

html.dark .login {
  --auth-ink: #eef5ff;
  --auth-muted: #a7b5c8;
  --auth-border: rgba(255, 255, 255, 0.12);
  background:
    linear-gradient(118deg, rgba(128, 187, 255, 0.08) 0 1px, transparent 1px 100%),
    radial-gradient(circle at 68% 18%, rgba(45, 95, 153, 0.3), transparent 32%),
    linear-gradient(135deg, #0f1726 0%, #162132 48%, #0f1726 100%);

  .login-card {
    background: rgba(20, 29, 43, 0.82);
    border-color: rgba(255, 255, 255, 0.1);
    box-shadow: 0 24px 60px rgba(0, 0, 0, 0.4);
  }

  .login-header .title {
    color: #f0f2f5;
  }

  .login-form {
    .el-input .el-input__wrapper {
      background-color: rgba(255, 255, 255, 0.05);
      border-color: var(--auth-border);

      &:hover {
        background-color: rgba(255, 255, 255, 0.08);
        border-color: var(--color-primary);
      }

      &.is-focus {
        background-color: rgba(255, 255, 255, 0.1);
      }
    }

    .el-input__inner {
      color: #f0f2f5;
    }
  }

  .login-actions .link-type {
    color: #60a5fa;
  }

  .el-login-footer {
    background: rgba(0, 0, 0, 0.3);
    border-top-color: rgba(255, 255, 255, 0.05);
  }

  .auth-note {
    color: rgba(238, 245, 255, 0.68);

    .note-mark {
      color: rgba(120, 190, 255, 0.76);
    }

    .note-face {
      color: rgba(238, 245, 255, 0.18);
    }

    .note-copy {
      color: rgba(207, 221, 238, 0.6);
    }
  }
}

@media (max-width: 960px) {
  .login {
    padding: 52px 24px 64px;
  }

  .auth-layout {
    grid-template-columns: minmax(320px, 440px);
    justify-content: center;
    min-height: calc(100vh - 116px);
    transform: none;
  }

  .auth-note {
    display: none;
  }
}

@media (max-width: 600px) {
  .login {
    padding: 44px 16px 64px;
  }

  .login-card {
    width: calc(100vw - 32px);
    padding: 28px 22px 24px;
  }

  .login-header {
    align-items: flex-start;
    margin-bottom: 26px;

    .login-badge {
      flex-basis: 50px;
      width: 50px;
      height: 50px;
    }

    .title {
      font-size: 20px;
    }

    .subtitle {
      font-size: 13px;
    }
  }

  .login-form .el-input {
    .el-input__wrapper {
      height: 42px;
    }
  }

  .login-form .login-code-item .code-input-wrapper {
    gap: 8px;

    .login-code {
      flex-basis: 98px;
      height: 42px;
    }
  }
}
</style>
