import { distributedKVStore } from '@kit.ArkData';
import {
  DEFAULT_FONT_SIZE,
  DEFAULT_THEME_MODE,
  KEY_FONT_SIZE,
  KEY_THEME_MODE,
  KV_STORE_ID
} from '../constants/StorageKeys';

let kvManager: distributedKVStore.KVManager | null = null;
let kvStore: distributedKVStore.SingleKVStore | null = null;

async function getLabKVStore(context: Context): Promise<distributedKVStore.SingleKVStore> {
  if (kvStore !== null) {
    return kvStore;
  }

  if (kvManager === null) {
    const config: distributedKVStore.KVManagerConfig = {
      context: context,
      bundleName: 'com.example.schoolapp'
    };
    kvManager = distributedKVStore.createKVManager(config);
  }

  const options: distributedKVStore.Options = {
    createIfMissing: true,
    encrypt: false,
    backup: false,
    autoSync: false,
    kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
    securityLevel: distributedKVStore.SecurityLevel.S1
  };

  kvStore = await kvManager.getKVStore(KV_STORE_ID, options) as distributedKVStore.SingleKVStore;
  return kvStore;
}

export class KVStoreUtil {
  static async getThemeMode(context: Context): Promise<string> {
    const store = await getLabKVStore(context);
    const value = await store.get(KEY_THEME_MODE);
    return value ? value.toString() : DEFAULT_THEME_MODE;
  }

  static async setThemeMode(context: Context, mode: string): Promise<void> {
    const store = await getLabKVStore(context);
    await store.put(KEY_THEME_MODE, mode);
  }

  static async getFontSize(context: Context): Promise<number> {
    const store = await getLabKVStore(context);
    const value = await store.get(KEY_FONT_SIZE);
    if (!value) {
      return DEFAULT_FONT_SIZE;
    }
    return Number(value.toString());
  }

  static async setFontSize(context: Context, size: number): Promise<void> {
    const store = await getLabKVStore(context);
    await store.put(KEY_FONT_SIZE, size);
  }
}
