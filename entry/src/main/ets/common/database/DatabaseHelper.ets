import relationalStore from '@ohos.data.relationalStore';
import { DB_NAME, INDEX_STUDENT_NAME, TABLE_STUDENT } from '../constants/StorageKeys';

const CREATE_STUDENT_TABLE_SQL = `CREATE TABLE IF NOT EXISTS ${TABLE_STUDENT} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  age INTEGER NOT NULL,
  score REAL NOT NULL,
  update_time TEXT NOT NULL
)`;

const CREATE_STUDENT_NAME_INDEX_SQL =
  `CREATE INDEX IF NOT EXISTS ${INDEX_STUDENT_NAME} ON ${TABLE_STUDENT}(name)`;

let rdbStoreInstance: relationalStore.RdbStore | null = null;
let rdbStoreCreating: Promise<relationalStore.RdbStore> | null = null;

async function initializeSchema(store: relationalStore.RdbStore): Promise<void> {
  await store.executeSql(CREATE_STUDENT_TABLE_SQL);
  await store.executeSql(CREATE_STUDENT_NAME_INDEX_SQL);
}

export class DatabaseHelper {
  static async getRdbStore(context: Context): Promise<relationalStore.RdbStore> {
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
}
