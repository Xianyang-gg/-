<template>
  <AchievementPage category-code="textbook" :api="textbookApi" />
</template>

<script setup name="SramsTextbook">
import AchievementPage from '../components/AchievementPage.vue'
import { textbookApi } from '@/api/srams/teaching'
</script>
