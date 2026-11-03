<template>
  <AchievementPage category-code="project_major" :api="majorApi" />
</template>

<script setup name="SramsProjectMajor">
import AchievementPage from '../components/AchievementPage.vue'
import { majorApi } from '@/api/srams/project'
</script>
