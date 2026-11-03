<template>
  <AchievementPage category-code="award_student" :api="studentApi" />
</template>

<script setup name="SramsAwardStudent">
import AchievementPage from '../components/AchievementPage.vue'
import { studentApi } from '@/api/srams/award'
</script>
