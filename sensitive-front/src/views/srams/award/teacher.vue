<template>
  <AchievementPage category-code="award_teacher" :api="teacherApi" />
</template>

<script setup name="SramsAwardTeacher">
import AchievementPage from '../components/AchievementPage.vue'
import { teacherApi } from '@/api/srams/award'
</script>
