import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { notificationManager } from '@kit.NotificationKit';

// 封装代理提醒（Agent-powered Reminder）：发布、取消、查询
// 应用退出后系统代理提醒，支持倒计时类型
export class ReminderUtil {
  // 发布倒计时提醒（seconds 秒后触发）
  static async publishReminder(seconds: number, title: string, content: string): Promise<number> {
    try {
      // TIMER 类型字段为 triggerTimeInSeconds（倒计时秒数）
      const reminderRequest: reminderAgentManager.ReminderRequestTimer = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER,
        actionButton: [
          {
            title: '关闭',
            type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CLOSE
          }
        ],
        title: title,
        content: content,
        notificationId: 100,
        ringDuration: 5,
        slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
        triggerTimeInSeconds: seconds
      };
      const reminderId: number = await reminderAgentManager.publishReminder(reminderRequest);
      console.info('>>> [Reminder] 代理提醒发布成功 reminderId: ' + reminderId + ', ' + seconds + '秒后触发');
      return reminderId;
    } catch (err) {
      console.error('>>> [Reminder] 代理提醒发布失败: ' + JSON.stringify(err));
      throw err as Error;
    }
  }

  // 取消提醒
  static async cancelReminder(reminderId: number): Promise<void> {
    try {
      await reminderAgentManager.cancelReminder(reminderId);
      console.info('>>> [Reminder] 代理提醒已取消 reminderId: ' + reminderId);
    } catch (err) {
      console.error('>>> [Reminder] 取消提醒失败: ' + JSON.stringify(err));
      throw err as Error;
    }
  }

  // 查询有效提醒
  static async getValidReminders(): Promise<reminderAgentManager.ReminderRequest[]> {
    try {
      const reminders = await reminderAgentManager.getValidReminders();
      console.info('>>> [Reminder] 有效提醒数量: ' + reminders.length);
      return reminders;
    } catch (err) {
      console.error('>>> [Reminder] 查询提醒失败: ' + JSON.stringify(err));
      throw err as Error;
    }
  }
}
