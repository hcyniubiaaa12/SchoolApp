/**
 * FoodDao.ets - 校园美食数据访问
 *
 * 核心操作：按评分/食堂筛选、收藏切换
 */
import { relationalStore } from '@kit.ArkData';
import { AppDbHelper } from './AppDbHelper';

export interface FoodRow {
  id: string;
  name: string;
  canteen: string;
  imagePath: string;
  rating: number;
  signatureDish: string;
  tags: string;
  isFavorited: number;  // 0/1
}

function toRow(rs: relationalStore.ResultSet): FoodRow {
  return {
    id: rs.getString(rs.getColumnIndex('id')),
    name: rs.getString(rs.getColumnIndex('name')),
    canteen: rs.getString(rs.getColumnIndex('canteen')),
    imagePath: rs.getString(rs.getColumnIndex('image_path')),
    rating: rs.getLong(rs.getColumnIndex('rating')),
    signatureDish: rs.getString(rs.getColumnIndex('signature_dish')),
    tags: rs.getString(rs.getColumnIndex('tags')),
    isFavorited: rs.getLong(rs.getColumnIndex('is_favorited'))
  };
}

function readList(rs: relationalStore.ResultSet): FoodRow[] {
  const list: FoodRow[] = [];
  while (rs.goToNextRow()) {
    list.push(toRow(rs));
  }
  rs.close();
  return list;
}

export class FoodDao {
  static async queryAll(context: Context): Promise<FoodRow[]> {
    const store = await AppDbHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('food');
    predicates.orderByDesc('rating');
    const rs = await store.query(predicates);
    return readList(rs);
  }

  static async queryByCanteen(context: Context, canteen: string): Promise<FoodRow[]> {
    const store = await AppDbHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('food');
    predicates.equalTo('canteen', canteen);
    predicates.orderByDesc('rating');
    const rs = await store.query(predicates);
    return readList(rs);
  }

  static async toggleFavorite(context: Context, foodId: string): Promise<boolean> {
    const store = await AppDbHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('food');
    predicates.equalTo('id', foodId);
    const rs = await store.query(predicates, ['is_favorited']);
    let newVal: number = 1;
    if (rs.goToFirstRow()) {
      newVal = rs.getLong(0) === 0 ? 1 : 0;
    }
    rs.close();
    const bucket: relationalStore.ValuesBucket = { is_favorited: newVal };
    await store.update(bucket, predicates);
    return newVal === 1;
  }
}
