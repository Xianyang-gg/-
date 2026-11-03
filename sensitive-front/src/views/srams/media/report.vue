<template>
  <AchievementPage category-code="media" :api="reportApi" />
</template>

<script setup name="SramsMediaReport">
import AchievementPage from '../components/AchievementPage.vue'
import { reportApi } from '@/api/srams/media'
</script>
