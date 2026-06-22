import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { TransientTaskUtil } from '../common/utils/TransientTaskUtil';

const DOMAIN = 0x0000;

// 用户信息接口定义
interface UserInfo {
  userId: string;
  username: string;
}

export default class MainAbility extends UIAbility {
  // 接收到的用户信息
  private userId: string = '';
  private username: string = '';

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'MainAbility onCreate');
    console.log('>>> [MainAbility] onCreate 被调用');
    console.log('>>> [MainAbility] 准备解析 Want 参数');

    // 解析从StartAbility传入的参数
    this.parseWantParams(want);
    console.log('>>> [MainAbility] 解析后 - userId: ' + this.userId + ', username: ' + this.username);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'MainAbility onNewWant');
    // 单实例模式下，再次启动时解析新参数
    this.parseWantParams(want);
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'MainAbility onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'MainAbility onWindowStageCreate');

    // 将用户信息存入AppStorage，供页面读取
    AppStorage.setOrCreate('userId', this.userId);
    AppStorage.setOrCreate('username', this.username);

    // 加载首页
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
    // 不在 onWindowStageCreate 中申请短时任务 —— onForeground 会在之后触发，统一在那里处理
    // 避免两个生命周期并发调用 ensureTransientTask() 导致竞争
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'MainAbility onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'MainAbility onForeground');
    // 通知短时任务追踪器：已回到前台
    TransientTaskUtil.notifyReturnForeground();
    // 前台时持有短时任务配额，保证退后台后仍可执行短时保存操作
    this.ensureTransientTask();
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'MainAbility onBackground');
    console.log('>>> [MainAbility] onBackground 触发');
    // 通知短时任务追踪器：已进入后台，开始计时
    TransientTaskUtil.notifyEnterBackground();
    // 执行草稿保存（短时任务已在前台申请）
    this.saveDraftOnBackground();
  }

  // 前台时申请短时任务（若未持有），保证退后台后短时操作可执行
  private async ensureTransientTask(): Promise<void> {
    if (TransientTaskUtil.isActive()) {
      return;
    }
    try {
      await TransientTaskUtil.requestDelay();
      console.log('>>> [MainAbility] 前台已申请短时任务 requestId: ' + TransientTaskUtil.getRequestId());
    } catch (err) {
      console.error('>>> [MainAbility] 前台申请短时任务失败: ' + JSON.stringify(err));
    }
  }

  private async saveDraftOnBackground(): Promise<void> {
    try {
      const draftContent: string = AppStorage.get<string>('lab_draft_content') ?? '';
      const scrollPos: number = AppStorage.get<number>('lab_scroll_position') ?? 0;
      await TransientTaskUtil.saveDraft(this.context, draftContent, scrollPos);
      console.log('>>> [MainAbility] 草稿已保存 - length: ' + draftContent.length + ', scroll: ' + scrollPos);
    } catch (err) {
      console.error('>>> [MainAbility] 保存草稿失败: ' + JSON.stringify(err));
    }
  }

  // 处理Ability返回结果（startAbilityForResult回调）
  onAbilityResult(requestCode: number, resultCode: number, wantResult: Want): void {
    hilog.info(DOMAIN, 'testTag', 'onAbilityResult - requestCode: %{public}d, resultCode: %{public}d',
      requestCode, resultCode);
    console.log('>>> [MainAbility] onAbilityResult 被调用');
    console.log('>>> [MainAbility] requestCode: ' + requestCode + ', resultCode: ' + resultCode);
    if (wantResult && wantResult.parameters) {
      const resultParams = wantResult.parameters as Record<string, string>;
      hilog.info(DOMAIN, 'testTag', 'Received result - userId: %{public}s, username: %{public}s',
        resultParams['userId'] ?? '', resultParams['username'] ?? '');
      console.log('>>> [MainAbility] 收到返回结果 - userId: ' + (resultParams['userId'] ?? '') +
        ', username: ' + (resultParams['username'] ?? ''));
    }
  }

  // 解析Want参数，获取用户ID和用户昵称
  private parseWantParams(want: Want): void {
    try {
      const parameters = want.parameters as Record<string, string>;
      if (parameters) {
        this.userId = parameters['userId'] ?? '';
        this.username = parameters['username'] ?? '';
        hilog.info(DOMAIN, 'testTag', 'Received params - userId: %{public}s, username: %{public}s',
          this.userId, this.username);
      }
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to parse want params. Cause: %{public}s', JSON.stringify(err));
    }
  }

  // 获取用户信息，供页面调用
  public getUserInfo(): UserInfo {
    return {
      userId: this.userId,
      username: this.username
    };
  }
}
