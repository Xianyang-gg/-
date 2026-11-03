<template>
  <div class="app-container home">
    <section v-if="hasAchievementPermission" id="teacher-center" class="teacher-center-card">
      <h2>成果总览与导出</h2>
      <AchievementExport />
    </section>
    <el-empty v-else description="暂无可用的业务功能" />
  </div>
</template>

<script setup name="Index">
import { computed } from 'vue'
import useUserStore from '@/store/modules/user'
import AchievementExport from '@/views/srams/profile/AchievementExport.vue'

const userStore = useUserStore()
const hasAchievementPermission = computed(() => userStore.permissions.some(permission => permission === '*:*:*' || permission === 'achievement:list'))
</script>

<style scoped>
.home { min-height: calc(100vh - 84px); background: #f6f8fb; }
.teacher-center-card { padding: 24px; border: 1px solid #e5eaf0; border-radius: 8px; background: #fff; scroll-margin-top: 20px; }
.teacher-center-card h2 { margin: 0 0 24px; color: #243b53; font-size: 22px; }
</style>
