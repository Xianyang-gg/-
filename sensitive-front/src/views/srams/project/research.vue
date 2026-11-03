<template>
  <AchievementPage category-code="project_research" :api="researchApi" />
</template>

<script setup name="SramsProjectResearch">
import AchievementPage from '../components/AchievementPage.vue'
import { researchApi } from '@/api/srams/project'
</script>
