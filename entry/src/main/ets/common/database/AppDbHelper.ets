/**
 * AppDbHelper.ets - 产品业务 RDB 连接管理器（单例）
 *
 * 职责：统一管理 6 张业务表的建表与连接生命周期
 * 不与实验页的 DatabaseHelper/StudentDao 共用连接
 */
import { relationalStore } from '@kit.ArkData';

const DB_NAME: string = 'school_app_rdb.db';

// ===== DDL SQL =====

const CREATE_COURSE_TABLE_SQL: string =
  'CREATE TABLE IF NOT EXISTS course (' +
  '  id TEXT PRIMARY KEY,' +
  '  name TEXT NOT NULL,' +
  '  teacher TEXT,' +
  '  location TEXT,' +
  '  day_index INTEGER NOT NULL,' +
  '  start_time TEXT NOT NULL,' +
  '  end_time TEXT NOT NULL,' +
  '  start_week INTEGER NOT NULL,' +
  '  end_week INTEGER NOT NULL,' +
  '  course_type TEXT,' +
  '  color TEXT,' +
  '  credit TEXT,' +
  '  remark TEXT' +
  ')';

const CREATE_COURSE_INDEX_SQL: string =
  'CREATE INDEX IF NOT EXISTS idx_course_day ON course(day_index)';

const CREATE_SCORE_TABLE_SQL: string =
  'CREATE TABLE IF NOT EXISTS score (' +
  '  id TEXT PRIMARY KEY,' +
  '  course_name TEXT NOT NULL,' +
  '  score REAL NOT NULL,' +
  '  gpa REAL NOT NULL,' +
  '  credit TEXT,' +
  '  exam_time TEXT,' +
  '  semester TEXT' +
  ')';

const CREATE_SCORE_INDEX_SQL: string =
  'CREATE INDEX IF NOT EXISTS idx_score_gpa ON score(gpa DESC)';

const CREATE_BOOK_TABLE_SQL: string =
  'CREATE TABLE IF NOT EXISTS book (' +
  '  id TEXT PRIMARY KEY,' +
  '  title TEXT NOT NULL,' +
  '  author TEXT,' +
  '  publisher TEXT,' +
  '  isbn TEXT,' +
  '  cover TEXT,' +
  '  location TEXT,' +
  '  total_count INTEGER DEFAULT 0,' +
  '  available_count INTEGER DEFAULT 0,' +
  '  summary TEXT,' +
  '  is_favorited INTEGER DEFAULT 0' +
  ')';

const CREATE_BOOK_INDEX_SQL: string =
  'CREATE INDEX IF NOT EXISTS idx_book_title ON book(title)';

const CREATE_LOST_FOUND_TABLE_SQL: string =
  'CREATE TABLE IF NOT EXISTS lost_found (' +
  '  id TEXT PRIMARY KEY,' +
  '  type TEXT NOT NULL,' +
  '  category TEXT,' +
  '  item_name TEXT NOT NULL,' +
  '  location TEXT,' +
  '  time TEXT,' +
  '  description TEXT,' +
  '  contact_phone TEXT,' +
  '  image_path TEXT,' +
  '  publisher_id TEXT,' +
  '  publish_time TEXT,' +
  '  status TEXT DEFAULT \'pending\'' +
  ')';

const CREATE_LF_TYPE_INDEX_SQL: string =
  'CREATE INDEX IF NOT EXISTS idx_lf_type ON lost_found(type)';

const CREATE_FOOD_TABLE_SQL: string =
  'CREATE TABLE IF NOT EXISTS food (' +
  '  id TEXT PRIMARY KEY,' +
  '  name TEXT NOT NULL,' +
  '  canteen TEXT,' +
  '  image_path TEXT,' +
  '  rating INTEGER DEFAULT 0,' +
  '  signature_dish TEXT,' +
  '  tags TEXT,' +
  '  is_favorited INTEGER DEFAULT 0' +
  ')';

const CREATE_WEATHER_TABLE_SQL: string =
  'CREATE TABLE IF NOT EXISTS weather (' +
  '  id TEXT PRIMARY KEY,' +
  '  date_text TEXT NOT NULL,' +
  '  week_day TEXT,' +
  '  weather TEXT,' +
  '  temp_high INTEGER,' +
  '  temp_low INTEGER,' +
  '  icon TEXT' +
  ')';

let rdbStoreInstance: relationalStore.RdbStore | null = null;
let rdbStoreCreating: Promise<relationalStore.RdbStore> | null = null;

async function initializeSchema(store: relationalStore.RdbStore): Promise<void> {
  await store.executeSql(CREATE_COURSE_TABLE_SQL);
  await store.executeSql(CREATE_COURSE_INDEX_SQL);
  await store.executeSql(CREATE_SCORE_TABLE_SQL);
  await store.executeSql(CREATE_SCORE_INDEX_SQL);
  await store.executeSql(CREATE_BOOK_TABLE_SQL);
  await store.executeSql(CREATE_BOOK_INDEX_SQL);
  await store.executeSql(CREATE_LOST_FOUND_TABLE_SQL);
  await store.executeSql(CREATE_LF_TYPE_INDEX_SQL);
  await store.executeSql(CREATE_FOOD_TABLE_SQL);
  await store.executeSql(CREATE_WEATHER_TABLE_SQL);
}

export class AppDbHelper {
  /**
   * 获取 RDB 连接（单例 + 懒初始化）
   */
  static async getStore(context: Context): Promise<relationalStore.RdbStore> {
    if (rdbStoreInstance !== null) {
      return rdbStoreInstance;
    }

    if (rdbStoreCreating !== null) {
      return rdbStoreCreating;
    }

    rdbStoreCreating = relationalStore.getRdbStore(context, {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    }).then(async (store: relationalStore.RdbStore) => {
      await initializeSchema(store);
      rdbStoreInstance = store;
      rdbStoreCreating = null;
      return store;
    }).catch((err: Error) => {
      rdbStoreCreating = null;
      throw err;
    });

    return rdbStoreCreating;
  }

  /**
   * 检查表是否为空（用于首次启动判断是否需要导入初始数据）
   */
  static async isTableEmpty(context: Context, tableName: string): Promise<boolean> {
    const store = await AppDbHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates(tableName);
    const resultSet = await store.query(predicates, ['id']);
    const empty: boolean = !resultSet.goToFirstRow();
    resultSet.close();
    return empty;
  }
}
