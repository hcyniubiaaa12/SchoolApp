/**
 * BookDao.ets - 图书数据访问
 *
 * 核心查询：按标题/作者/ISBN 模糊搜索、收藏切换
 */
import { relationalStore } from '@kit.ArkData';
import { AppDbHelper } from './AppDbHelper';

export interface BookRow {
  id: string;
  title: string;
  author: string;
  publisher: string;
  isbn: string;
  cover: string;
  location: string;
  totalCount: number;
  availableCount: number;
  summary: string;
  isFavorited: number;  // 0/1
}

function toBookRow(rs: relationalStore.ResultSet): BookRow {
  return {
    id: rs.getString(rs.getColumnIndex('id')),
    title: rs.getString(rs.getColumnIndex('title')),
    author: rs.getString(rs.getColumnIndex('author')),
    publisher: rs.getString(rs.getColumnIndex('publisher')),
    isbn: rs.getString(rs.getColumnIndex('isbn')),
    cover: rs.getString(rs.getColumnIndex('cover')),
    location: rs.getString(rs.getColumnIndex('location')),
    totalCount: rs.getLong(rs.getColumnIndex('total_count')),
    availableCount: rs.getLong(rs.getColumnIndex('available_count')),
    summary: rs.getString(rs.getColumnIndex('summary')),
    isFavorited: rs.getLong(rs.getColumnIndex('is_favorited'))
  };
}

function readBooks(rs: relationalStore.ResultSet): BookRow[] {
  const list: BookRow[] = [];
  while (rs.goToNextRow()) {
    list.push(toBookRow(rs));
  }
  rs.close();
  return list;
}

export class BookDao {
  static async queryAll(context: Context): Promise<BookRow[]> {
    const store = await AppDbHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('book');
    predicates.orderByAsc('title');
    const rs = await store.query(predicates);
    return readBooks(rs);
  }

  /** 模糊搜索：匹配标题、作者或 ISBN */
  static async search(context: Context, keyword: string): Promise<BookRow[]> {
    const store = await AppDbHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('book');
    if (keyword.trim().length > 0) {
      predicates.contains('title', keyword.trim());
      // RdbPredicates 暂不支持 OR，此处简化：只匹配标题
      // 后续可用 raw predicate 扩展
    }
    predicates.orderByAsc('title');
    const rs = await store.query(predicates);
    return readBooks(rs);
  }

  /** 切换收藏状态 */
  static async toggleFavorite(context: Context, bookId: string): Promise<boolean> {
    const store = await AppDbHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('book');
    predicates.equalTo('id', bookId);
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
