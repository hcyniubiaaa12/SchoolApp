import { workScheduler } from '@kit.BackgroundTasksKit';
import { common } from '@kit.AbilityKit';

const WORK_ID: number = 1;
const BUNDLE_NAME: string = 'com.example.schoolapp';
const ABILITY_NAME: string = 'DataSyncExtensionAbility';

// 封装延迟任务（Deferred Task）：注册、取消
// 适用于实时性要求不高、可延迟执行的任务，设置触发条件（Wi-Fi + 充电）
export class DeferredTaskUtil {
  // 注册延迟任务（网络 WiFi + 充电条件）
  static async startWork(context: common.Context): Promise<void> {
    try {
      const workInfo: workScheduler.WorkInfo = {
        workId: WORK_ID,
        networkType: workScheduler.NetworkType.NETWORK_TYPE_WIFI,
        isCharging: true,
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME
      };
      workScheduler.startWork(workInfo);
      console.info('>>> [DeferredTask] 延迟任务注册成功 workId: ' + WORK_ID);
    } catch (err) {
      console.error('>>> [DeferredTask] 延迟任务注册失败: ' + JSON.stringify(err));
      throw err as Error;
    }
  }

  // 取消延迟任务
  static async stopWork(context: common.Context): Promise<void> {
    try {
      const workInfo: workScheduler.WorkInfo = {
        workId: WORK_ID,
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME
      };
      workScheduler.stopWork(workInfo);
      console.info('>>> [DeferredTask] 延迟任务已取消 workId: ' + WORK_ID);
    } catch (err) {
      console.error('>>> [DeferredTask] 延迟任务取消失败: ' + JSON.stringify(err));
      throw err as Error;
    }
  }

  // 查询已注册的延迟任务
  static async getWorkStatus(): Promise<workScheduler.WorkInfo[]> {
    try {
      return await workScheduler.obtainAllWorks();
    } catch (err) {
      console.error('>>> [DeferredTask] 查询任务状态失败: ' + JSON.stringify(err));
      return [];
    }
  }
}
