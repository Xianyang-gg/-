<template>
  <AchievementPage category-code="project_horizontal" :api="horizontalApi" />
</template>

<script setup name="SramsProjectHorizontal">
import AchievementPage from '../components/AchievementPage.vue'
import { horizontalApi } from '@/api/srams/project'
</script>
