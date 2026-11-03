<template>
  <div class="register">
    <div class="auth-marble auth-marble--one"></div>
    <div class="auth-marble auth-marble--two"></div>

    <main class="auth-layout">
      <el-form ref="registerRef" :model="registerForm" :rules="registerRules" class="register-form">
        <div class="register-header">
          <div class="register-badge">
            <img :src="logo" alt="" class="badge-logo" />
          </div>
          <div>
            <h3 class="title">{{ title }}</h3>
            <p class="subtitle">创建账户，开始进入系统</p>
          </div>
        </div>

        <el-form-item prop="username">
          <el-input
            v-model="registerForm.username"
            type="text"
            auto-complete="off"
            placeholder="账号"
          >
            <template #prefix><svg-icon icon-class="user" class="el-input__icon input-icon" /></template>
          </el-input>
        </el-form-item>
        <el-form-item prop="password" :rules="registerPwdValidator">
          <el-input
            v-model="registerForm.password"
            type="password"
            auto-complete="off"
            placeholder="密码"
            @keyup.enter="handleRegister"
          >
            <template #prefix><svg-icon icon-class="password" class="el-input__icon input-icon" /></template>
          </el-input>
        </el-form-item>
        <el-form-item prop="confirmPassword">
          <el-input
            v-model="registerForm.confirmPassword"
            type="password"
            auto-complete="off"
            placeholder="确认密码"
            @keyup.enter="handleRegister"
          >
            <template #prefix><svg-icon icon-class="password" class="el-input__icon input-icon" /></template>
          </el-input>
        </el-form-item>
        <el-form-item prop="code" v-if="captchaEnabled" class="register-code-item">
          <div class="code-input-wrapper">
            <el-input
              v-model="registerForm.code"
              auto-complete="off"
              placeholder="验证码"
              @keyup.enter="handleRegister"
            >
              <template #prefix><svg-icon icon-class="validCode" class="el-input__icon input-icon" /></template>
            </el-input>
            <div class="register-code" @click="getCode" title="点击刷新">
              <img :src="codeUrl" class="register-code-img"/>
            </div>
          </div>
        </el-form-item>
        <el-form-item class="register-submit">
          <el-button
            :loading="loading"
            type="primary"
            class="register-btn"
            @click.prevent="handleRegister"
          >
            <span v-if="!loading">注 册</span>
            <span v-else>注 册 中...</span>
          </el-button>
        </el-form-item>

        <div class="register-actions">
          <router-link class="link-type" :to="'/login'">使用已有账户登录</router-link>
        </div>
      </el-form>

      <aside class="auth-note" aria-hidden="true">
        <p class="note-mark">// create softly :)</p>
        <p class="note-face">(｡•̀ᴗ-)✧</p>
        <p class="note-copy">A fresh account, polished in blue marble.</p>
      </aside>
    </main>
    <!--  底部  -->
    <div class="el-register-footer">
      <span>{{ footerContent }}</span>
    </div>
  </div>
</template>

<script setup>
import { ElMessageBox } from "element-plus"
import { getCodeImg, register } from "@/api/login"
import defaultSettings from '@/settings'
import { usePasswordRule } from "@/utils/passwordRule"
import logo from '@/assets/logo/sensitive-logo.svg'

const title = import.meta.env.VITE_APP_TITLE
const footerContent = defaultSettings.footerContent
const router = useRouter()
const { proxy } = getCurrentInstance()
const { registerPwdValidator } = usePasswordRule()

const registerForm = ref({
  username: "",
  password: "",
  confirmPassword: "",
  code: "",
  uuid: ""
})

const equalToPassword = (rule, value, callback) => {
  if (registerForm.value.password !== value) {
    callback(new Error("两次输入的密码不一致"))
  } else {
    callback()
  }
}

const registerRules = {
  username: [
    { required: true, trigger: "blur", message: "请输入您的账号" },
    { min: 2, max: 20, message: "用户账号长度必须介于 2 和 20 之间", trigger: "blur" }
  ],
  confirmPassword: [
    { required: true, trigger: "blur", message: "请再次输入您的密码" },
    { required: true, validator: equalToPassword, trigger: "blur" }
  ],
  code: [{ required: true, trigger: "change", message: "请输入验证码" }]
}

const codeUrl = ref("")
const loading = ref(false)
const captchaEnabled = ref(true)

function handleRegister() {
  proxy.$refs.registerRef.validate(valid => {
    if (valid) {
      loading.value = true
      register(registerForm.value).then(res => {
        const username = registerForm.value.username
        ElMessageBox.alert("<font color='red'>恭喜你，您的账号 " + username + " 注册成功！</font>", "系统提示", {
          dangerouslyUseHTMLString: true,
          type: "success",
        }).then(() => {
          router.push("/login")
        }).catch(() => {})
      }).catch(() => {
        loading.value = false
        if (captchaEnabled) {
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
      registerForm.value.uuid = res.uuid
    }
  })
}

getCode()
</script>

<style lang='scss' scoped>
.register {
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

.register::before,
.register::after {
  position: absolute;
  inset: 0;
  content: "";
  pointer-events: none;
}

.register::before {
  opacity: 0.82;
  background:
    linear-gradient(126deg, transparent 0 19%, rgba(60, 91, 128, 0.16) 19.08%, rgba(255, 255, 255, 0.58) 19.42%, transparent 20.3% 100%),
    linear-gradient(132deg, transparent 0 23%, rgba(94, 132, 178, 0.12) 23.08%, transparent 23.8% 100%),
    linear-gradient(148deg, transparent 0 54%, rgba(87, 126, 174, 0.16) 54.15%, rgba(255, 255, 255, 0.54) 54.5%, transparent 55.6% 100%),
    linear-gradient(158deg, transparent 0 71%, rgba(155, 177, 202, 0.18) 71.1%, transparent 72.2% 100%),
    linear-gradient(24deg, transparent 0 62%, rgba(255, 255, 255, 0.78) 62.35%, rgba(96, 145, 202, 0.12) 62.9%, transparent 64% 100%);
}

.register::after {
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

.register-form {
  position: relative;
  width: 100%;
  max-width: calc(100vw - 40px);
  padding: 34px 34px 28px;
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

  .el-form-item {
    margin-bottom: 18px;
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

      &::placeholder {
        color: #a0acbd;
      }
    }
  }

  .input-icon {
    width: 16px;
    height: 16px;
    margin-right: 8px;
    color: #9aa8bb;
    transition: var(--auth-transition);
  }

  .el-input.is-focus .input-icon {
    color: var(--auth-primary);
  }
}

.register-header {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 28px;
}

.register-badge {
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

  .badge-logo {
    width: 38px;
    height: 38px;
    display: block;
    filter: drop-shadow(0 6px 10px rgba(24, 91, 166, 0.18));
  }
}

.title {
  margin: 0 0 6px;
  color: var(--auth-ink);
  font-size: 26px;
  font-weight: 700;
  letter-spacing: 0;
}

.subtitle {
  margin: 0;
  color: var(--auth-muted);
  font-size: 14px;
}

.register-code-item {
  .code-input-wrapper {
    display: flex;
    gap: 8px;
    align-items: stretch;

    .el-input {
      flex: 1;
      min-width: 0;
    }
  }
}

.register-code {
  flex: 0 0 110px;
  height: 46px;
  cursor: pointer;
  overflow: hidden;
  border: 1px solid var(--auth-border);
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.78);
  transition: var(--auth-transition);

  &:hover {
    border-color: rgba(47, 125, 246, 0.42);
    box-shadow: 0 4px 12px rgba(47, 125, 246, 0.14);
  }
}

.register-code-img {
  display: block;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.register-submit {
  margin-bottom: 14px !important;
}

.register-btn {
  width: 100% !important;
  height: 44px !important;
  margin: 0 !important;
  color: #fff !important;
  border: none !important;
  border-radius: 10px !important;
  background: linear-gradient(135deg, #2f7df6, #79bfff) !important;
  box-shadow: 0 12px 22px rgba(47, 125, 246, 0.26) !important;
  font-size: 14px !important;
  font-weight: 600 !important;
  letter-spacing: 2px !important;
  transition: all 0.2s ease !important;
}

.register-btn:hover:not(:disabled) {
  transform: translateY(-2px) !important;
  box-shadow: 0 16px 28px rgba(47, 125, 246, 0.34) !important;
}

.register-actions {
  display: flex;
  justify-content: flex-end;
  font-size: 13px;

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
    max-width: 340px;
    margin: 0;
    font-size: clamp(15px, 1.4vw, 20px);
    line-height: 1.7;
    color: rgba(70, 91, 120, 0.62);
  }
}

.el-register-footer {
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

html.dark .register {
  --auth-ink: #eef5ff;
  --auth-muted: #a7b5c8;
  --auth-border: rgba(255, 255, 255, 0.12);
  background:
    linear-gradient(118deg, rgba(128, 187, 255, 0.08) 0 1px, transparent 1px 100%),
    radial-gradient(circle at 68% 18%, rgba(45, 95, 153, 0.3), transparent 32%),
    linear-gradient(135deg, #0f1726 0%, #162132 48%, #0f1726 100%);

  .register-form {
    background: rgba(20, 29, 43, 0.82);
    border-color: rgba(255, 255, 255, 0.1);
    box-shadow: 0 24px 60px rgba(0, 0, 0, 0.4);
  }

  .register-form .el-input .el-input__wrapper {
    background-color: rgba(255, 255, 255, 0.05);
    border-color: var(--auth-border);

    &:hover {
      background-color: rgba(255, 255, 255, 0.08);
      border-color: var(--auth-primary);
    }

    &.is-focus {
      background-color: rgba(255, 255, 255, 0.1);
    }
  }

  .register-form .el-input__inner {
    color: #f0f2f5;
  }

  .register-actions .link-type {
    color: #60a5fa;
  }

  .el-register-footer {
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
  .register {
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
  .register {
    padding: 44px 16px 64px;
  }

  .register-form {
    width: calc(100vw - 32px);
    padding: 28px 22px 24px;
  }

  .register-header {
    align-items: flex-start;
    margin-bottom: 26px;
  }

  .register-badge {
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

  .register-form .el-input .el-input__wrapper {
    height: 42px;
  }

  .register-code-item .code-input-wrapper {
    gap: 8px;

    .register-code {
      flex-basis: 98px;
      height: 42px;
    }
  }
}
</style>
