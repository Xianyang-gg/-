<template>
  <AchievementPage category-code="paper" :api="paperApi" />
</template>

<script setup name="SramsPaper">
import AchievementPage from '../components/AchievementPage.vue'
import { paperApi } from '@/api/srams/research'
</script>
