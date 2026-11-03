<template>
  <AchievementPage category-code="tech_training" :api="hostedApi" />
</template>

<script setup name="SramsHostedTraining">
import AchievementPage from '../components/AchievementPage.vue'
import { hostedApi } from '@/api/srams/cooperation'
</script>
