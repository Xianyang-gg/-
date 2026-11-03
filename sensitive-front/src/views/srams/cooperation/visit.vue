<template>
  <AchievementPage category-code="visit" :api="visitApi" />
</template>

<script setup name="SramsVisit">
import AchievementPage from '../components/AchievementPage.vue'
import { visitApi } from '@/api/srams/cooperation'
</script>
