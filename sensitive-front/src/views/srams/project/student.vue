<template>
  <AchievementPage category-code="project_student" :api="studentApi" />
</template>

<script setup name="SramsProjectStudent">
import AchievementPage from '../components/AchievementPage.vue'
import { studentApi } from '@/api/srams/project'
</script>
