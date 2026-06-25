/**
 * Food.ets - 校园美食模型
 */
export interface FoodItem {
  id: string;
  name: string;
  canteen: string;         // 所属食堂/店铺
  imagePath: string;       // 美食图路径（预留）
  rating: number;          // 星级评分 1-5
  signatureDish: string;   // 特色菜
  tags: string[];          // 标签，如 ['川菜', '实惠']
  isFavorited: boolean;
}
