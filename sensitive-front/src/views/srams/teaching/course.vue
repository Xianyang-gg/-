<template>
  <AchievementPage category-code="course" :api="courseApi" />
</template>

<script setup name="SramsCourse">
import AchievementPage from '../components/AchievementPage.vue'
import { courseApi } from '@/api/srams/teaching'
</script>
