/**
 * Todo.ets - 待办模型
 */
export interface TodoItem {
  id: string;
  content: string;
  category: 'study' | 'life' | 'other';
  isCompleted: boolean;
  remindTime: string;       // 提醒时间，格式 'YYYY-MM-DD HH:mm'
  createTime: string;
}
