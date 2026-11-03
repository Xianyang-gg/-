<template>
  <AchievementPage category-code="study_training" :api="studyApi" />
</template>

<script setup name="SramsStudyTraining">
import AchievementPage from '../components/AchievementPage.vue'
import { studyApi } from '@/api/srams/cooperation'
</script>
