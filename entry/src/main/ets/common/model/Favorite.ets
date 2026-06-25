/**
 * Favorite.ets - 收藏模型
 */
export interface FavoriteItem {
  id: string;
  targetId: string;         // 被收藏对象的 id
  type: 'announcement' | 'news' | 'book' | 'food';
  title: string;
  summary: string;
  saveTime: string;
}
