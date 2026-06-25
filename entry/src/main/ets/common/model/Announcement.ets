/**
 * Announcement.ets - 公告模型
 */
export interface AnnouncementItem {
  id: string;
  title: string;
  summary: string;
  content: string;
  category: string;         // 分类：学校通知/学院通知/社团通知
  source: string;           // 来源部门
  publishTime: string;
  coverImage: string;       // 封面图（预留）
  isFavorited: boolean;
  isRead: boolean;
}
