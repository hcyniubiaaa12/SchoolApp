/**
 * Book.ets - 图书模型
 */
export interface BookItem {
  id: string;
  title: string;           // 书名
  author: string;          // 作者
  publisher: string;       // 出版社
  isbn: string;            // ISBN
  cover: string;           // 封面图片路径（预留）
  location: string;        // 馆藏位置
  totalCount: number;      // 总数量
  availableCount: number;  // 剩余可借数量
  summary: string;         // 简介
  isFavorited: boolean;    // 是否收藏
}
