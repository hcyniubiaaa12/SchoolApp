import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { KEY_DRAFT_CONTENT, KEY_SCROLL_POSITION, PREFERENCES_NAME } from '../constants/StorageKeys';

// 草稿数据结构
export interface DraftData {
  content: string;
  scrollPos: number;
}

// 封装短时任务（Transient Task）
export class TransientTaskUtil {
  private static requestId: number = -1;
  // 本次申请的配额（actualDelayTime，通常 180000ms=3分钟）
  private static actualDelayTime: number = 0;
  // 累计后台消耗（跨多次前后台切换不丢失）
  private static totalConsumed: number = 0;
  // 当前后台会话的进入时间戳（-1 表示不在后台）
  private static backgroundEnterTime: number = -1;
  // 并发锁：防止多个 requestDelay() 同时调用
  private static requesting: boolean = false;

  // ========== 公开 API ==========

  /** 申请短时任务，返回 requestId（幂等 + 并发锁：防止重复申请） */
  static async requestDelay(): Promise<number> {
    if (TransientTaskUtil.requestId !== -1) {
      console.info('>>> [TransientTask] 短时任务已持有，复用 requestId: ' + TransientTaskUtil.requestId);
      return TransientTaskUtil.requestId;
    }
    // 并发锁：正在申请中则等待
    if (TransientTaskUtil.requesting) {
      console.info('>>> [TransientTask] 短时任务申请进行中，跳过重复调用');
      // 等到 requestId 被设置（轮询最多等 1 秒）
      for (let i = 0; i < 10 && TransientTaskUtil.requestId === -1; i++) {
        await new Promise<void>(resolve => setTimeout(resolve, 100));
      }
      if (TransientTaskUtil.requestId !== -1) {
        return TransientTaskUtil.requestId;
      }
    }
    TransientTaskUtil.requesting = true;
    try {
      const info: backgroundTaskManager.DelaySuspendInfo =
        backgroundTaskManager.requestSuspendDelay('保存学习草稿状态', () => {
          console.info('>>> [TransientTask] 短时任务即将超时回调触发');
        });
      TransientTaskUtil.requestId = info.requestId;
      TransientTaskUtil.actualDelayTime = info.actualDelayTime;
      TransientTaskUtil.totalConsumed = 0;
      TransientTaskUtil.backgroundEnterTime = -1;
      console.info('>>> [TransientTask] 申请成功 requestId: ' + info.requestId +
        ', 配额: ' + info.actualDelayTime + 'ms (≈' + (info.actualDelayTime / 60000).toFixed(1) + '分钟)');
      return info.requestId;
    } catch (err) {
      console.error('>>> [TransientTask] 申请失败: ' + JSON.stringify(err));
      throw err as Error;
    } finally {
      TransientTaskUtil.requesting = false;
    }
  }

  /** 取消短时任务并重置所有状态 */
  static cancelDelay(): void {
    if (TransientTaskUtil.requestId !== -1) {
      backgroundTaskManager.cancelSuspendDelay(TransientTaskUtil.requestId);
      console.info('>>> [TransientTask] 已取消 requestId: ' + TransientTaskUtil.requestId);
      TransientTaskUtil.requestId = -1;
      TransientTaskUtil.actualDelayTime = 0;
      TransientTaskUtil.totalConsumed = 0;
      TransientTaskUtil.backgroundEnterTime = -1;
    }
  }

  /** 应用退后台时调用 —— 开始计时 */
  static notifyEnterBackground(): void {
    if (TransientTaskUtil.requestId !== -1) {
      TransientTaskUtil.backgroundEnterTime = Date.now();
      console.info('>>> [TransientTask] 退后台，开始计时 | 已累计消耗: ' +
        TransientTaskUtil.totalConsumed + 'ms | 配额: ' + TransientTaskUtil.actualDelayTime + 'ms');
    }
  }

  /** 应用回前台时调用 —— 冻结本次后台消耗，累加到 totalConsumed */
  static notifyReturnForeground(): void {
    if (TransientTaskUtil.backgroundEnterTime > 0) {
      const sessionConsumed: number = Date.now() - TransientTaskUtil.backgroundEnterTime;
      TransientTaskUtil.totalConsumed += sessionConsumed;
      TransientTaskUtil.backgroundEnterTime = -1;
      console.info('>>> [TransientTask] 回前台 | 本次后台: ' + sessionConsumed + 'ms | ' +
        '累计消耗: ' + TransientTaskUtil.totalConsumed + 'ms | ' +
        '剩余: ' + Math.max(0, TransientTaskUtil.actualDelayTime - TransientTaskUtil.totalConsumed) + 'ms');
    }
  }

  /** 获取剩余时间（ms）。前台时 = 配额 - 累计消耗；后台时 = 配额 - 累计消耗 - 当前会话消耗 */
  static async getRemainingDelayTime(): Promise<number> {
    if (TransientTaskUtil.requestId === -1) {
      return 0;
    }
    let consumed: number = TransientTaskUtil.totalConsumed;
    if (TransientTaskUtil.backgroundEnterTime > 0) {
      // 当前正在后台，加上实时消耗
      consumed += (Date.now() - TransientTaskUtil.backgroundEnterTime);
    }
    return Math.max(0, TransientTaskUtil.actualDelayTime - consumed);
  }

  static getActualDelayTime(): number {
    return TransientTaskUtil.actualDelayTime;
  }

  static getTotalConsumed(): number {
    return TransientTaskUtil.totalConsumed;
  }

  static getRequestId(): number {
    return TransientTaskUtil.requestId;
  }

  static isActive(): boolean {
    return TransientTaskUtil.requestId !== -1;
  }

  // ========== 草稿保存 ==========

  static async saveDraft(context: common.Context, content: string, scrollPos: number): Promise<void> {
    const pref = await preferences.getPreferences(context, PREFERENCES_NAME);
    await pref.put(KEY_DRAFT_CONTENT, content);
    await pref.put(KEY_SCROLL_POSITION, scrollPos);
    await pref.flush();
    console.info('>>> [TransientTask] 草稿已保存 - length: ' + content.length + ', scroll: ' + scrollPos);
  }

  static async loadDraft(context: common.Context): Promise<DraftData> {
    const pref = await preferences.getPreferences(context, PREFERENCES_NAME);
    const content = (await pref.get(KEY_DRAFT_CONTENT, '')) as string;
    const scrollPos = (await pref.get(KEY_SCROLL_POSITION, 0)) as number;
    return { content, scrollPos };
  }
}
