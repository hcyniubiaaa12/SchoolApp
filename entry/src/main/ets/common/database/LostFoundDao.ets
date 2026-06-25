/**
 * LostFoundDao.ets - 失物招领数据访问
 *
 * 核心操作：按类型/分类筛选、发布新信息
 */
import { relationalStore } from '@kit.ArkData';
import { AppDbHelper } from './AppDbHelper';

export interface LostFoundRow {
  id: string;
  type: string;      // 'lost' | 'found'
  category: string;
  itemName: string;
  location: string;
  time: string;
  description: string;
  contactPhone: string;
  imagePath: string;
  publisherId: string;
  publishTime: string;
  status: string;    // 'pending' | 'resolved'
}

function toRow(rs: relationalStore.ResultSet): LostFoundRow {
  return {
    id: rs.getString(rs.getColumnIndex('id')),
    type: rs.getString(rs.getColumnIndex('type')),
    category: rs.getString(rs.getColumnIndex('category')),
    itemName: rs.getString(rs.getColumnIndex('item_name')),
    location: rs.getString(rs.getColumnIndex('location')),
    time: rs.getString(rs.getColumnIndex('time')),
    description: rs.getString(rs.getColumnIndex('description')),
    contactPhone: rs.getString(rs.getColumnIndex('contact_phone')),
    imagePath: rs.getString(rs.getColumnIndex('image_path')),
    publisherId: rs.getString(rs.getColumnIndex('publisher_id')),
    publishTime: rs.getString(rs.getColumnIndex('publish_time')),
    status: rs.getString(rs.getColumnIndex('status'))
  };
}

function readList(rs: relationalStore.ResultSet): LostFoundRow[] {
  const list: LostFoundRow[] = [];
  while (rs.goToNextRow()) {
    list.push(toRow(rs));
  }
  rs.close();
  return list;
}

export class LostFoundDao {
  static async queryAll(context: Context): Promise<LostFoundRow[]> {
    const store = await AppDbHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('lost_found');
    predicates.orderByDesc('publish_time');
    const rs = await store.query(predicates);
    return readList(rs);
  }

  /** 按失物/拾物筛选 */
  static async queryByType(context: Context, type: string): Promise<LostFoundRow[]> {
    const store = await AppDbHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('lost_found');
    predicates.equalTo('type', type);
    predicates.orderByDesc('publish_time');
    const rs = await store.query(predicates);
    return readList(rs);
  }

  /** 按分类筛选 */
  static async queryByCategory(context: Context, category: string): Promise<LostFoundRow[]> {
    const store = await AppDbHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('lost_found');
    predicates.equalTo('category', category);
    predicates.orderByDesc('publish_time');
    const rs = await store.query(predicates);
    return readList(rs);
  }

  static async insert(context: Context, data: LostFoundRow): Promise<void> {
    const store = await AppDbHelper.getStore(context);
    const bucket: relationalStore.ValuesBucket = {
      id: data.id,
      type: data.type,
      category: data.category,
      item_name: data.itemName,
      location: data.location,
      time: data.time,
      description: data.description,
      contact_phone: data.contactPhone,
      image_path: data.imagePath,
      publisher_id: data.publisherId,
      publish_time: data.publishTime,
      status: data.status
    };
    await store.insert('lost_found', bucket);
  }

  /** 按 id 查询 */
  static async queryById(context: Context, id: string): Promise<LostFoundRow | null> {
    const store = await AppDbHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('lost_found');
    predicates.equalTo('id', id);
    const rs = await store.query(predicates);
    if (rs.goToFirstRow()) {
      const row = toRow(rs);
      rs.close();
      return row;
    }
    rs.close();
    return null;
  }

  /** 按 id 删除 */
  static async deleteById(context: Context, id: string): Promise<void> {
    const store = await AppDbHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('lost_found');
    predicates.equalTo('id', id);
    await store.delete(predicates);
  }

  /** 更新失物/拾物信息 */
  static async update(context: Context, data: LostFoundRow): Promise<void> {
    const store = await AppDbHelper.getStore(context);
    const bucket: relationalStore.ValuesBucket = {
      type: data.type,
      category: data.category,
      item_name: data.itemName,
      location: data.location,
      time: data.time,
      description: data.description,
      contact_phone: data.contactPhone
    };
    const predicates = new relationalStore.RdbPredicates('lost_found');
    predicates.equalTo('id', data.id);
    await store.update(bucket, predicates);
  }

  /** 按 publisherId 查询（我的发布） */
  static async queryByPublisher(context: Context, publisherId: string): Promise<LostFoundRow[]> {
    const store = await AppDbHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('lost_found');
    predicates.equalTo('publisher_id', publisherId);
    predicates.orderByDesc('publish_time');
    const rs = await store.query(predicates);
    return readList(rs);
  }
}
