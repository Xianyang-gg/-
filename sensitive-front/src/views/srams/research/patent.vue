<template>
  <AchievementPage category-code="patent" :api="patentApi" />
</template>

<script setup name="SramsPatent">
import AchievementPage from '../components/AchievementPage.vue'
import { patentApi } from '@/api/srams/research'
</script>
