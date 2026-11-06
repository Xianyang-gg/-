export function businessParams({ categoryCodes, levels }) {
  const params = { categoryCodes: categoryCodes.join(',') || undefined }
  for (const [code, values] of Object.entries(levels)) {
    if ((!categoryCodes.length || categoryCodes.includes(code)) && values.length) params[`level_${code}`] = values.join(',')
  }
  return params
}
