<template>
   <div class="profile-container">
      <!-- 用户卡片 Hero 区 -->
      <div class="profile-hero">
         <div class="hero-content">
            <div class="avatar-wrapper">
               <userAvatar />
            </div>
            <div class="user-identity">
               <h1 class="user-name">{{ state.user.nickName || state.user.userName }}</h1>
               <p class="user-role">{{ state.roleGroup }} · {{ state.user.dept?.deptName }}</p>
               <p class="user-meta">账号创建于 {{ formatDate(state.user.createTime) }}</p>
            </div>
         </div>
      </div>

      <!-- 联系信息卡片 -->
      <div class="profile-section">
         <div class="info-grid">
            <div class="info-card">
               <div class="info-label">邮箱</div>
               <div class="info-value">{{ state.user.email }}</div>
            </div>
            <div class="info-card">
               <div class="info-label">手机号码</div>
               <div class="info-value">{{ state.user.phonenumber }}</div>
            </div>
         </div>
      </div>

      <!-- 组织信息卡片 -->
      <div class="profile-section">
         <div class="info-grid">
            <div class="info-card">
               <div class="info-label">所属部门</div>
               <div class="info-value">{{ state.user.dept?.deptName }}</div>
               <div class="info-sub" v-if="state.postGroup">职位：{{ state.postGroup }}</div>
            </div>
            <div class="info-card">
               <div class="info-label">所属角色</div>
               <div class="info-value">{{ state.roleGroup }}</div>
            </div>
         </div>
      </div>

      <!-- 修改信息卡片 -->
      <div class="profile-section profile-edit">
         <div class="edit-header">
            <div class="tab-controls">
               <button
                  :class="['tab-button', { active: selectedTab === 'userinfo' }]"
                  @click="selectedTab = 'userinfo'"
               >
                  基本资料
               </button>
               <button
                  :class="['tab-button', { active: selectedTab === 'resetPwd' }]"
                  @click="selectedTab = 'resetPwd'"
               >
                  修改密码
               </button>
               <button v-if="hasAchievementPermission" :class="['tab-button', { active: selectedTab === 'achievement' }]" @click="selectedTab = 'achievement'">教师资料与证书</button>
            </div>
         </div>
         <div class="edit-content">
            <userInfo v-if="selectedTab === 'userinfo'" :user="state.user" />
            <resetPwd v-if="selectedTab === 'resetPwd'" />
            <div v-if="selectedTab === 'achievement' && hasAchievementPermission" class="teacher-profile-panel"><TeacherCenter /></div>
         </div>
      </div>
   </div>
</template>

<script setup name="Profile">
import userAvatar from "./userAvatar"
import userInfo from "./userInfo"
import resetPwd from "./resetPwd"
import { getUserProfile } from "@/api/system/user"
import TeacherCenter from '@/views/srams/profile/TeacherCenter.vue'
import useUserStore from '@/store/modules/user'

const route = useRoute()
const userStore = useUserStore()
const hasAchievementPermission = computed(() => userStore.permissions.some(permission => permission === '*:*:*' || permission === 'achievement:list'))
const selectedTab = ref("userinfo")
watch(() => route.params.activeTab, value => {
  selectedTab.value = ['resetPwd', 'achievement'].includes(value) ? value : 'userinfo'
}, { immediate: true })
const state = reactive({
  user: {},
  roleGroup: {},
  postGroup: {}
})

function formatDate(dateStr) {
  if (!dateStr) return ""
  const date = new Date(dateStr)
  return date.toLocaleDateString("zh-CN", { year: "numeric", month: "2-digit", day: "2-digit" })
}

function getUser() {
  getUserProfile().then(response => {
    state.user = response.data
    state.roleGroup = response.roleGroup
    state.postGroup = response.postGroup
  })
}

onMounted(() => {
  getUser()
})
</script>

<style lang="scss" scoped>
.profile-edit .edit-content .teacher-profile-panel :deep(.el-form) { max-width: 100%; }

:root {
  --color-bg: #f8fafc;
  --color-surface: #ffffff;
  --color-text-primary: #1f2937;
  --color-text-secondary: #6b7280;
  --color-text-tertiary: #9ca3af;
  --color-primary: #3b82f6;
  --color-border: #e5e7eb;
  --color-hover: rgba(59, 130, 246, 0.08);
  --shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.08);
  --shadow-md: 0 2px 6px rgba(0, 0, 0, 0.1);
  --transition: all 0.2s ease;
}

.profile-container {
  max-width: 900px;
  margin: 0 auto;
  padding: 24px;
  background-color: var(--color-bg);
  min-height: calc(100vh - 120px);
}

/* Hero Section */
.profile-hero {
  background-color: var(--color-surface);
  border-radius: 8px;
  padding: 40px 32px;
  margin-bottom: 24px;
  box-shadow: var(--shadow-sm);
  transition: var(--transition);

  .hero-content {
    display: flex;
    align-items: center;
    gap: 32px;

    @media (max-width: 600px) {
      flex-direction: column;
      text-align: center;
      gap: 24px;
    }
  }

  .avatar-wrapper {
    flex-shrink: 0;
    :deep(.user-info-head) {
      height: 100px;
      width: 100px;

      .img-circle {
        border-radius: 50%;
        box-shadow: var(--shadow-sm);
        transition: var(--transition);
        border: 2px solid var(--color-border);

        &:hover {
          transform: scale(1.05);
          box-shadow: var(--shadow-md);
        }
      }

      &:hover::after {
        border-radius: 50%;
      }
    }
  }

  .user-identity {
    flex: 1;
    min-width: 0;

    .user-name {
      font-size: 28px;
      font-weight: 600;
      color: var(--color-text-primary);
      margin: 0 0 8px 0;
      letter-spacing: -0.5px;
    }

    .user-role {
      font-size: 14px;
      color: var(--color-primary);
      margin: 0 0 8px 0;
      font-weight: 500;
    }

    .user-meta {
      font-size: 12px;
      color: var(--color-text-tertiary);
      margin: 0;
    }
  }
}

/* Info Section */
.profile-section {
  background-color: var(--color-surface);
  border-radius: 8px;
  padding: 32px;
  margin-bottom: 24px;
  box-shadow: var(--shadow-sm);
  transition: var(--transition);

  &:hover {
    box-shadow: var(--shadow-md);
  }
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 32px;

  @media (max-width: 600px) {
    grid-template-columns: 1fr;
    gap: 24px;
  }
}

.info-card {
  padding: 20px;
  background-color: var(--color-bg);
  border-radius: 6px;
  transition: var(--transition);
  border: 1px solid transparent;

  &:hover {
    border-color: var(--color-border);
  }

  .info-label {
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 1px;
    color: var(--color-text-secondary);
    margin-bottom: 12px;
    font-weight: 500;
  }

  .info-value {
    font-size: 16px;
    font-weight: 500;
    color: var(--color-text-primary);
    margin-bottom: 4px;
    word-break: break-all;
  }

  .info-sub {
    font-size: 12px;
    color: var(--color-text-tertiary);
    margin-top: 8px;
  }
}

/* Edit Section */
.profile-edit {
  padding: 0;
  overflow: hidden;

  .edit-header {
    padding: 24px 32px;
    border-bottom: 1px solid var(--color-border);
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .tab-controls {
    display: flex;
    gap: 0;

    .tab-button {
      padding: 12px 24px;
      background: none;
      border: none;
      font-size: 14px;
      color: var(--color-text-secondary);
      cursor: pointer;
      position: relative;
      transition: var(--transition);
      border-left: 3px solid transparent;
      margin-left: -3px;

      &:hover {
        color: var(--color-text-primary);
        background-color: var(--color-hover);
      }

      &.active {
        color: var(--color-primary);
        border-left-color: var(--color-primary);
        background-color: var(--color-hover);
        font-weight: 500;
      }
    }
  }

  .edit-content {
    padding: 32px;
    :deep(.el-form) {
      max-width: 600px;

      .el-form-item {
        margin-bottom: 24px;

        .el-form-item__label {
          color: var(--color-text-primary);
          font-weight: 500;
        }

        .el-input__wrapper {
          background-color: var(--color-surface);
          border: 1px solid var(--color-border);
          border-radius: 6px;
          transition: var(--transition);

          &:hover {
            border-color: var(--color-border);
          }

          &.is-focus {
            border-color: var(--color-primary);
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
          }
        }

        .el-input__inner {
          color: var(--color-text-primary);

          &::placeholder {
            color: var(--color-text-tertiary);
          }
        }

        .el-radio__label {
          color: var(--color-text-primary);
        }
      }

      .el-button {
        border-radius: 6px;
        font-weight: 500;
        padding: 10px 24px;
        transition: var(--transition);

        &.is-plain {
          border-color: var(--color-border);
          color: var(--color-text-secondary);

          &:hover {
            color: var(--color-text-primary);
            border-color: var(--color-text-secondary);
          }
        }

        &:not(.is-plain) {
          &:hover {
            filter: brightness(0.95);
          }
        }
      }
    }
  }
}
</style>
