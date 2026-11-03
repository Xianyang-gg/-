export const pageConfig = {
  project_major: { name: '项目名称', date: 'apply_date', roles: [], level: true },
  project_research: { name: '项目名称', date: 'apply_date', roles: [], level: true },
  project_horizontal: { name: '项目名称', date: 'start_date', roles: [] },
  project_student: { name: '项目名称', date: 'grant_date', roles: [] },
  award_teacher: { name: '获奖名称', date: 'award_date', roles: ['winner'] },
  award_student: { name: '奖项名称', date: 'award_date', roles: ['student', 'supervisor'] },
  course: { name: '课程名称', date: 'start_date', roles: ['participant'] },
  textbook: { name: '教材名称', date: 'publish_date', roles: ['co_editor'] },
  paper: { name: '论文名称', date: 'publish_date', roles: ['author'] },
  patent: { name: '专利或软著名称', date: 'apply_date', roles: [] },
  patent_transfer: { name: '专利名称', date: 'transfer_date', roles: [] },
  visit: { name: '接待主题', date: 'visit_date', roles: [] },
  tech_training: { name: '交流或培训主题', date: 'event_date', roles: [] },
  study_training: { name: '培训或会议名称', date: 'event_date', roles: ['participant'] },
  media: { name: '报道标题', date: 'publish_date', roles: [] }
}

export const roleLabels = {
  member: '成员', student: '获奖学生', supervisor: '指导教师', participant: '参加人员',
  author: '其他作者', first_author: '第一作者', editor: '主编', co_editor: '参编',
  inventor: '发明人', winner: '获奖人', accompany: '陪同人', lecturer: '主讲人'
}

export function attachmentName(file) {
  return file.mime_type === 'image/jpeg' ? file.original_name.replace(/\.(png|jpe?g)$/i, '') + '.jpg' : file.original_name
}
