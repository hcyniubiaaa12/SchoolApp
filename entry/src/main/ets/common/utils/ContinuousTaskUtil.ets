import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { common, wantAgent } from '@kit.AbilityKit';

// 封装长时任务（Continuous Task）：申请、停止
// 适用于后台长时间运行且用户可感知的任务（如音乐播放），使用 AUDIO_PLAYBACK 类型
export class ContinuousTaskUtil {
  // 申请长时任务（AUDIO_PLAYBACK 类型），配合 WantAgent 实现通知点击跳转
  static async startBackgroundRunning(context: common.UIAbilityContext): Promise<void> {
    try {
      // 构建 WantAgent，点击通知拉起 MainAbility
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [{
          bundleName: 'com.example.schoolapp',
          abilityName: 'MainAbility'
        }],
        operationType: wantAgent.OperationType.START_ABILITY,
        requestCode: 0,
        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
      };
      // getWantAgent 返回 Promise<WantAgent>，由推断决定类型
      const agent = await wantAgent.getWantAgent(wantAgentInfo);
      await backgroundTaskManager.startBackgroundRunning(context, backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, agent);
      console.info('>>> [ContinuousTask] 长时任务申请成功 AUDIO_PLAYBACK');
    } catch (err) {
      console.error('>>> [ContinuousTask] 长时任务申请失败: ' + JSON.stringify(err));
      throw err as Error;
    }
  }

  // 停止长时任务
  static async stopBackgroundRunning(context: common.UIAbilityContext): Promise<void> {
    try {
      await backgroundTaskManager.stopBackgroundRunning(context);
      console.info('>>> [ContinuousTask] 长时任务已停止');
    } catch (err) {
      console.error('>>> [ContinuousTask] 停止长时任务失败: ' + JSON.stringify(err));
      throw err as Error;
    }
  }
}
