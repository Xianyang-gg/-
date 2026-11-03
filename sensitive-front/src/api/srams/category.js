import { addAchievement, deleteAchievement, exportAchievement, getAchievement, listAchievement, recognizeAchievement, saveAchievementSort, updateAchievement } from './achievement'

export function createCategoryApi(categoryCode) {
  return {
    list: query => listAchievement({ ...query, categoryCode }),
    get: async id => {
      const response = await getAchievement(id)
      if (response.data.category_code !== categoryCode) throw new Error('该记录不属于当前业务模块')
      return response
    },
    create: data => addAchievement({ ...data, category_code: categoryCode }),
    update: (id, data) => updateAchievement(id, { ...data, category_code: categoryCode }),
    remove: ids => deleteAchievement(ids),
    sort: ids => saveAchievementSort(categoryCode, ids),
    export: (type, data) => exportAchievement(type, { ...data, categoryCode }),
    recognize: file => recognizeAchievement(categoryCode, file)
  }
}
