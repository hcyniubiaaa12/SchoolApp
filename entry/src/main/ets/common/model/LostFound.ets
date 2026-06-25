/**
 * LostFound.ets - 失物招领模型
 */
export interface LostFoundItem {
  id: string;
  type: 'lost' | 'found';  // 失物 / 拾物
  category: string;         // 分类：校园卡/电子产品/书籍/其他
  itemName: string;
  location: string;
  time: string;
  description: string;
  contactPhone: string;
  imagePath: string;        // 图片路径（预留）
  publisherId: string;
  publishTime: string;
  status: 'pending' | 'resolved';
}
