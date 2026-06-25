/**
 * News.ets - 资讯模型
 */
export interface NewsItem {
  id: string;
  title: string;
  summary: string;
  content: string;
  source: string;           // 来源
  publishTime: string;
  coverImage: string;       // 封面图（预留）
  isFavorited: boolean;
}
