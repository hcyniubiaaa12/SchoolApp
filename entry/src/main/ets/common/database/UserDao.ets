/**
 * UserDao.ets - 用户数据访问（Preferences 存储）
 *
 * 用户信息以 JSON 对象存储，按 userId 索引，支持多用户。
 * 键名: saved_users_json
 * 结构: { "userId1": { User }, "userId2": { User } }
 */
import { preferences } from '@kit.ArkData';
import { User } from '../model/User';
import { PREFERENCES_NAME, KEY_IS_LOGGED_IN, KEY_CURRENT_USER_ID } from '../constants/StorageKeys';

const KEY_USERS_JSON: string = 'saved_users_json';

function getPrefs(context: Context): Promise<preferences.Preferences> {
  return preferences.getPreferences(context, PREFERENCES_NAME);
}

function getPrefsSync(context: Context): preferences.Preferences {
  return preferences.getPreferencesSync(context, { name: PREFERENCES_NAME });
}

/** 读取全部用户数据的 JSON 对象 */
async function readUsersMap(context: Context): Promise<Record<string, User>> {
  const pref = await getPrefs(context);
  const raw: string = (await pref.get(KEY_USERS_JSON, '{}')) as string;
  try {
    return JSON.parse(raw) as Record<string, User>;
  } catch {
    return {};
  }
}

/** 同步读取全部用户数据 */
function readUsersMapSync(context: Context): Record<string, User> {
  const pref = getPrefsSync(context);
  const raw: string = pref.getSync(KEY_USERS_JSON, '{}') as string;
  try {
    return JSON.parse(raw) as Record<string, User>;
  } catch {
    return {};
  }
}

/** 覆写全部用户数据 */
async function writeUsersMap(context: Context, map: Record<string, User>): Promise<void> {
  const pref = await getPrefs(context);
  await pref.put(KEY_USERS_JSON, JSON.stringify(map));
  await pref.flush();
}

export class UserDao {

  /** 注册：保存用户信息 */
  static async save(context: Context, user: User): Promise<void> {
    const map = await readUsersMap(context);
    map[user.userId] = user;
    await writeUsersMap(context, map);
  }

  /** 查用户（同步） */
  static findByIdSync(context: Context, userId: string): User {
    const map = readUsersMapSync(context);
    const user = map[userId];
    if (user) {
      return user;
    }
    // 未找到时返回空用户，由调用方处理
    return { userId: userId, username: userId, password: '', phone: '', college: '', major: '', avatar: '' };
  }

  /** 查用户（异步） */
  static async findById(context: Context, userId: string): Promise<User> {
    const map = await readUsersMap(context);
    const user = map[userId];
    if (user) {
      return user;
    }
    return { userId: userId, username: userId, password: '', phone: '', college: '', major: '', avatar: '' };
  }

  /** 验证登录 */
  static async login(context: Context, userId: string, password: string): Promise<boolean> {
    // 演示账号免密登录
    if (userId === '20240101001' || userId === '20240101002') {
      return true;
    }
    const map = await readUsersMap(context);
    const user = map[userId];
    if (!user) {
      return false;
    }
    return user.password === password;
  }

  /** 标记登录态 */
  static async setLoggedIn(context: Context, status: boolean): Promise<void> {
    const pref = await getPrefs(context);
    await pref.put(KEY_IS_LOGGED_IN, status);
    await pref.flush();
  }

  /** 设置当前登录用户 ID */
  static async setCurrentUserId(context: Context, userId: string): Promise<void> {
    const pref = await getPrefs(context);
    await pref.put(KEY_CURRENT_USER_ID, userId);
    await pref.flush();
  }

  /** 获取当前登录用户 ID（同步） */
  static getCurrentUserIdSync(context: Context): string {
    const pref = getPrefsSync(context);
    return pref.getSync(KEY_CURRENT_USER_ID, '') as string;
  }

  /** 修改昵称/学院/专业 */
  static async updateProfile(context: Context, userId: string, data: Partial<User>): Promise<void> {
    const map = await readUsersMap(context);
    const user = map[userId];
    if (!user) { return; }
    if (data.username !== undefined) { user.username = data.username; }
    if (data.college !== undefined) { user.college = data.college; }
    if (data.major !== undefined) { user.major = data.major; }
    map[userId] = user;
    await writeUsersMap(context, map);
  }

  /** 修改密码 */
  static async updatePassword(context: Context, userId: string, oldPwd: string, newPwd: string): Promise<'ok' | 'wrong_pwd' | 'not_found'> {
    const map = await readUsersMap(context);
    const user = map[userId];
    if (!user) {
      return 'not_found';
    }
    if (user.password !== oldPwd) {
      return 'wrong_pwd';
    }
    user.password = newPwd;
    map[userId] = user;
    await writeUsersMap(context, map);
    return 'ok';
  }
}
