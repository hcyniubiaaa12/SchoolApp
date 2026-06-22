import { WorkSchedulerExtensionAbility, workScheduler } from '@kit.BackgroundTasksKit';
import { common } from '@kit.AbilityKit';
import { StudentDao } from '../database/StudentDao';
import { DatabaseHelper } from '../database/DatabaseHelper';

// 延迟任务扩展能力：系统在满足条件（Wi-Fi + 充电）时回调
// onWorkStart 中复用实验4的 StudentDao 读取学生表，模拟日志上报
export default class DataSyncExtensionAbility extends WorkSchedulerExtensionAbility {
  onWorkStart(workInfo: workScheduler.WorkInfo): void {
    console.info('>>> [DataSync] onWorkStart 触发: ' + JSON.stringify(workInfo));
    this.doSync();
  }

  onWorkStop(workInfo: workScheduler.WorkInfo): void {
    console.info('>>> [DataSync] onWorkStop: ' + JSON.stringify(workInfo));
  }

  private async doSync(): Promise<void> {
    try {
      const context: common.Context = this.context as common.Context;
      // 复用实验4 数据库，读取学生表
      await DatabaseHelper.getRdbStore(context);
      const students = await StudentDao.queryAll(context);
      console.info('>>> [DataSync] 读取学生数据 ' + students.length + ' 条，模拟日志上报');

      // 模拟日志上报：打印前几条
      const reportCount: number = Math.min(students.length, 3);
      for (let i = 0; i < reportCount; i++) {
        console.info('>>> [DataSync] 上报记录 ' + (i + 1) + ': ' + JSON.stringify(students[i]));
      }
      console.info('>>> [DataSync] 数据同步完成，共上报 ' + students.length + ' 条');
    } catch (err) {
      console.error('>>> [DataSync] 数据同步失败: ' + JSON.stringify(err));
    }
  }
}
