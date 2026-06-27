/**
 * User.ets - 用户模型
 */
export interface User {
  userId: string;      // 学号
  username: string;    // 昵称
  password: string;    // 登录密码
  phone: string;       // 手机号
  college: string;     // 学院
  major: string;       // 专业
  avatar: string;      // 头像路径（预留）
}
