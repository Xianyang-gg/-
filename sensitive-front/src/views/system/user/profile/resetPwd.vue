<template>
  <div class="profile-toolbar"><el-button type="primary" @click="openEdit">修改</el-button></div>
  <el-form label-width="100px">
    <el-form-item label="登录密码">密码不会显示，点击“修改”更新密码</el-form-item>
  </el-form>
  <el-dialog v-model="editVisible" title="修改密码" width="520px" :style="{ maxWidth: 'calc(100vw - 32px)' }" append-to-body destroy-on-close :close-on-click-modal="false" :close-on-press-escape="!saving" :show-close="!saving" @closed="clearPassword">
    <el-form ref="pwdRef" :model="user" :rules="rules" label-width="100px" :disabled="saving">
      <el-form-item label="旧密码" prop="oldPassword"><el-input v-model="user.oldPassword" placeholder="请输入旧密码" type="password" show-password /></el-form-item>
      <el-form-item label="新密码" prop="newPassword" :rules="infoPwdValidator"><el-input v-model="user.newPassword" placeholder="请输入新密码" type="password" show-password /></el-form-item>
      <el-form-item label="确认密码" prop="confirmPassword"><el-input v-model="user.confirmPassword" placeholder="请确认新密码" type="password" show-password /></el-form-item>
    </el-form>
    <template #footer>
      <el-button :disabled="saving" @click="editVisible = false">取消</el-button>
      <el-button type="primary" :loading="saving" @click="submit">保存更改</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { usePasswordRule } from "@/utils/passwordRule"
import { updateUserPwd } from "@/api/system/user"

const { proxy } = getCurrentInstance()
const { infoPwdValidator } = usePasswordRule()
const pwdRef = ref()
const editVisible = ref(false)
const saving = ref(false)

const user = reactive({
  oldPassword: undefined,
  newPassword: undefined,
  confirmPassword: undefined
})

const equalToPassword = (rule, value, callback) => {
  if (user.newPassword !== value) {
    callback(new Error("两次输入的密码不一致"))
  } else {
    callback()
  }
}

const rules = ref({
  oldPassword: [{ required: true, message: "旧密码不能为空", trigger: "blur" }],
  confirmPassword: [{ required: true, message: "确认密码不能为空", trigger: "blur" }, { required: true, validator: equalToPassword, trigger: "blur" }]
})

function clearPassword() {
  user.oldPassword = undefined
  user.newPassword = undefined
  user.confirmPassword = undefined
}

function openEdit() {
  clearPassword()
  editVisible.value = true
}

async function submit() {
  if (saving.value || !await pwdRef.value.validate().catch(() => false)) return
  saving.value = true
  try {
    await updateUserPwd(user.oldPassword, user.newPassword)
    editVisible.value = false
    clearPassword()
    proxy.$modal.msgSuccess("修改成功")
  } finally {
    saving.value = false
  }
}
</script>

<style scoped>
.profile-toolbar { display: flex; justify-content: flex-end; margin-bottom: 16px; }
</style>
