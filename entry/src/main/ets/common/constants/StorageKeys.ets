export const PREFERENCES_NAME: string = 'school_app_prefs';
export const KEY_FIRST_LAUNCH: string = 'is_first_launch_lab';

// 用户信息存储键（登录/注册后持久化）
export const KEY_SAVED_USER_ID: string = 'saved_user_id';
export const KEY_SAVED_USERNAME: string = 'saved_username';
export const KEY_SAVED_PASSWORD: string = 'saved_password';
export const KEY_IS_LOGGED_IN: string = 'is_logged_in';

export const KV_STORE_ID: string = 'settings_store';
export const KEY_THEME_MODE: string = 'theme_mode';
export const KEY_FONT_SIZE: string = 'font_size';
export const DEFAULT_THEME_MODE: string = 'light';
export const DEFAULT_FONT_SIZE: number = 16;
export const MIN_FONT_SIZE: number = 14;
export const MAX_FONT_SIZE: number = 24;

export const DB_NAME: string = 'student.db';
export const TABLE_STUDENT: string = 'student';
export const INDEX_STUDENT_NAME: string = 'idx_student_name';

// 实验5 后台服务 —— 短时任务草稿存储键
export const KEY_DRAFT_CONTENT: string = 'draft_content';
export const KEY_SCROLL_POSITION: string = 'scroll_position';

// JSON 数据文件名常量（rawfile 与沙箱路径共用）
export const FILE_SCHEDULE: string = 'schedule.json';
export const FILE_SCORE: string = 'score.json';
export const FILE_BOOKS: string = 'books.json';
export const FILE_ANNOUNCEMENTS: string = 'announcements.json';
export const FILE_NEWS: string = 'news.json';
export const FILE_LOSTFOUND: string = 'lostfound.json';
export const FILE_FOOD: string = 'food.json';
export const FILE_MUSIC: string = 'music.json';
export const FILE_WEATHER: string = 'weather.json';
export const FILE_FAVORITES: string = 'favorites.json';

// 待办数据存储键（Preferences 持久化）
export const KEY_TODO_DATA: string = 'todo_data_json';
