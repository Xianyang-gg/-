<template>
   <div class="profile-toolbar"><el-button type="primary" @click="openEdit">修改</el-button></div>
   <el-form :model="user" label-width="100px" disabled>
      <el-form-item label="用户昵称" prop="nickName">
         <el-input :model-value="user.nickName" />
      </el-form-item>
      <el-form-item label="手机号码" prop="phonenumber">
         <el-input :model-value="user.phonenumber" />
      </el-form-item>
      <el-form-item label="邮箱" prop="email">
         <el-input :model-value="user.email" />
      </el-form-item>
      <el-form-item label="性别">
         <el-radio-group :model-value="user.sex">
            <el-radio value="0">男</el-radio>
            <el-radio value="1">女</el-radio>
         </el-radio-group>
      </el-form-item>
   </el-form>
   <el-dialog v-model="editVisible" title="修改基本资料" width="520px" :style="{ maxWidth: 'calc(100vw - 32px)' }" append-to-body destroy-on-close :close-on-click-modal="false" :close-on-press-escape="!saving" :show-close="!saving">
      <el-form ref="userRef" :model="form" :rules="rules" label-width="100px" :disabled="saving">
         <el-form-item label="用户昵称" prop="nickName"><el-input v-model="form.nickName" maxlength="30" placeholder="请输入用户昵称" /></el-form-item>
         <el-form-item label="手机号码" prop="phonenumber"><el-input v-model="form.phonenumber" maxlength="11" placeholder="请输入手机号码" /></el-form-item>
         <el-form-item label="邮箱" prop="email"><el-input v-model="form.email" maxlength="50" placeholder="请输入邮箱地址" /></el-form-item>
         <el-form-item label="性别"><el-radio-group v-model="form.sex"><el-radio value="0">男</el-radio><el-radio value="1">女</el-radio></el-radio-group></el-form-item>
      </el-form>
      <template #footer>
         <el-button :disabled="saving" @click="editVisible = false">取消</el-button>
         <el-button type="primary" :loading="saving" @click="submit">保存更改</el-button>
      </template>
   </el-dialog>
</template>

<script setup>
import { updateUserProfile } from "@/api/system/user"

const props = defineProps({
  user: {
    type: Object
  }
})

const { proxy } = getCurrentInstance()

const form = ref({})
const userRef = ref()
const editVisible = ref(false)
const saving = ref(false)
const rules = ref({
  nickName: [{ required: true, message: "用户昵称不能为空", trigger: "blur" }],
  email: [{ required: true, message: "邮箱地址不能为空", trigger: "blur" }, { type: "email", message: "请输入正确的邮箱地址", trigger: ["blur", "change"] }],
  phonenumber: [{ required: true, message: "手机号码不能为空", trigger: "blur" }, { pattern: /^1[3|4|5|6|7|8|9][0-9]\d{8}$/, message: "请输入正确的手机号码", trigger: "blur" }],
})

function openEdit() {
  form.value = { nickName: props.user.nickName, phonenumber: props.user.phonenumber, email: props.user.email, sex: props.user.sex }
  editVisible.value = true
}

async function submit() {
  if (saving.value || !await userRef.value.validate().catch(() => false)) return
  saving.value = true
  try {
    await updateUserProfile(form.value)
    Object.assign(props.user, form.value)
    editVisible.value = false
    proxy.$modal.msgSuccess("修改成功")
  } finally {
    saving.value = false
  }
}
</script>

<style scoped>
.profile-toolbar { display: flex; justify-content: flex-end; margin-bottom: 16px; }
</style>
