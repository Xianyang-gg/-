import request from '@/utils/request'

export const getCollegeDashboard = query => request({ url: '/achievement/dashboard/college', method: 'get', params: query })
export const getPersonalDashboard = query => request({ url: '/achievement/dashboard/personal', method: 'get', params: query })
export const getDashboardPeople = () => request({ url: '/achievement/dashboard/people', method: 'get' })
