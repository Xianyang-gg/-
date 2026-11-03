<template>
  <AchievementPage category-code="patent_transfer" :api="transferApi" />
</template>

<script setup name="SramsPatentTransfer">
import AchievementPage from '../components/AchievementPage.vue'
import { transferApi } from '@/api/srams/research'
</script>
