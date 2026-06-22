import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { TransientTaskUtil } from '../common/utils/TransientTaskUtil';

const DOMAIN = 0x0000;
const PREF_NAME = 'school_app_prefs';
const KEY_FIRST_LAUNCH = 'is_first_launch';
const KEY_IS_LOGGED_IN = 'is_logged_in';

export default class StartAbility extends UIAbility {
  private pref: preferences.Preferences | null = null;
  private isFirstLaunch: boolean = true;
  private isLoggedIn: boolean = false;
  private windowStage: window.WindowStage | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'StartAbility onCreate');
    console.log('>>> [StartAbility] onCreate 被调用');

    // 初始化偏好设置，读取首次启动和登录状态
    this.initPreferences();
    console.log('>>> [StartAbility] initPreferences 完成后 - isFirstLaunch: ' + this.isFirstLaunch + ', isLoggedIn: ' + this.isLoggedIn);

    // 注册eventHub事件监听，用于Ability内页面跳转
    this.registerEventHub();
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'StartAbility onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'StartAbility onWindowStageCreate');
    this.windowStage = windowStage;

    // 检查是否有精确到页面的启动参数（演示精确到页面启动）
    const targetPage = this.launchWant?.parameters?.['targetPage'] as string;
    if (targetPage) {
      // 精确到页面启动：直接加载指定页面
      hilog.info(DOMAIN, 'testTag', 'Exact page launch detected, loading page: %{public}s', targetPage);
      windowStage.loadContent(targetPage, (err) => {
        if (err.code) {
          hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
          return;
        }
        hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      });
      return;
    }

    // 根据是否是首次登录决定加载哪个页面或跳转到其他Ability
    if (this.isFirstLaunch) {
      // 首次启动：加载启动页，启动页会引导到引导页
      hilog.info(DOMAIN, 'testTag', 'First launch, loading Start page');
      windowStage.loadContent('pages/Start', (err) => {
        if (err.code) {
          hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
          return;
        }
        hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      });
    } else if (!this.isLoggedIn) {
      // 非首次但未登录：直接加载登录页
      hilog.info(DOMAIN, 'testTag', 'Not logged in, loading Login page');
      console.log('>>> [StartAbility] 未登录，加载 Login 页面');
      windowStage.loadContent('pages/Login', (err) => {
        if (err.code) {
          hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
          return;
        }
        hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      });
    } else {
      // 已登录：直接加载首页，不再跳 MainAbility（消除跨 Ability 时序问题）
      hilog.info(DOMAIN, 'testTag', 'Already logged in, loading Index directly');
      console.log('>>> [StartAbility] 已登录，直接加载 Index 页面');
      const savedUserId = this.getSavedUserId();
      const savedUsername = this.getSavedUsername();
      console.log('>>> [StartAbility] 用户参数 - userId: ' + savedUserId + ', username: ' + savedUsername);
      // 设置 AppStorage 后加载 Index（替代原来跳 MainAbility 的逻辑）
      AppStorage.setOrCreate('userId', savedUserId);
      AppStorage.setOrCreate('username', savedUsername);
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(DOMAIN, 'testTag', 'Failed to load Index. Cause: %{public}s', JSON.stringify(err));
          return;
        }
        hilog.info(DOMAIN, 'testTag', 'Succeeded in loading Index from StartAbility.');
      });
    }
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'StartAbility onWindowStageDestroy');
    this.windowStage = null;
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'StartAbility onForeground');
    TransientTaskUtil.notifyReturnForeground();
    this.ensureTransientTask();
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'StartAbility onBackground');
    console.log('>>> [StartAbility] onBackground 触发');
    TransientTaskUtil.notifyEnterBackground();
    this.saveDraftOnBackground();
  }

  // 前台时持有短时任务配额
  private async ensureTransientTask(): Promise<void> {
    if (TransientTaskUtil.isActive()) {
      return;
    }
    try {
      await TransientTaskUtil.requestDelay();
      console.log('>>> [StartAbility] 前台已申请短时任务 requestId: ' + TransientTaskUtil.getRequestId());
    } catch (err) {
      console.error('>>> [StartAbility] 前台申请短时任务失败: ' + JSON.stringify(err));
    }
  }

  private async saveDraftOnBackground(): Promise<void> {
    try {
      const draftContent: string = AppStorage.get<string>('lab_draft_content') ?? '';
      const scrollPos: number = AppStorage.get<number>('lab_scroll_position') ?? 0;
      await TransientTaskUtil.saveDraft(this.context, draftContent, scrollPos);
      console.log('>>> [StartAbility] 草稿已保存 - length: ' + draftContent.length + ', scroll: ' + scrollPos);
    } catch (err) {
      console.error('>>> [StartAbility] 保存草稿失败: ' + JSON.stringify(err));
    }
  }

  // 注册eventHub事件监听
  private registerEventHub(): void {
    // 导航到引导页
    this.context.eventHub.on('navigateToGuide', () => {
      this.loadPage('pages/Guide');
    });

    // 导航到登录页
    this.context.eventHub.on('navigateToLogin', () => {
      this.loadPage('pages/Login');
    });

    // 导航到注册页
    this.context.eventHub.on('navigateToRegist', () => {
      this.loadPage('pages/Regist');
    });

    // 标记首次启动完成
    this.context.eventHub.on('markFirstLaunchComplete', () => {
      this.markFirstLaunchComplete();
    });

    // 标记登录状态
    this.context.eventHub.on('markLoginStatus', (isLoggedIn: boolean) => {
      this.markLoginStatus(isLoggedIn);
    });
  }

  // 加载指定页面
  private loadPage(page: string): void {
    if (this.windowStage) {
      this.windowStage.loadContent(page, (err) => {
        if (err.code) {
          hilog.error(DOMAIN, 'testTag', 'Failed to load page %{public}s. Cause: %{public}s', page, JSON.stringify(err));
        } else {
          hilog.info(DOMAIN, 'testTag', 'Loaded page: %{public}s', page);
        }
      });
    }
  }

  // 初始化偏好设置，读取首次启动和登录状态
  private initPreferences(): void {
    try {
      this.pref = preferences.getPreferencesSync(this.context, { name: PREF_NAME });
      this.isFirstLaunch = this.pref.getSync(KEY_FIRST_LAUNCH, true) as boolean;
      this.isLoggedIn = this.pref.getSync(KEY_IS_LOGGED_IN, false) as boolean;
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to init preferences. Cause: %{public}s', JSON.stringify(err));
      this.isFirstLaunch = true;
      this.isLoggedIn = false;
    }
  }


  // 标记首次启动完成
  private markFirstLaunchComplete(): void {
    try {
      if (this.pref) {
        this.pref.putSync(KEY_FIRST_LAUNCH, false);
        this.pref.flushSync();
        this.isFirstLaunch = false;
        hilog.info(DOMAIN, 'testTag', 'First launch marked as complete');
      }
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to mark first launch complete. Cause: %{public}s', JSON.stringify(err));
    }
  }

  // 标记登录状态
  private markLoginStatus(isLoggedIn: boolean): void {
    try {
      if (this.pref) {
        this.pref.putSync(KEY_IS_LOGGED_IN, isLoggedIn);
        this.pref.flushSync();
        this.isLoggedIn = isLoggedIn;
        hilog.info(DOMAIN, 'testTag', 'Login status marked as: %{public}s', String(isLoggedIn));
      }
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to mark login status. Cause: %{public}s', JSON.stringify(err));
    }
  }

  // 获取已保存的用户ID
  private getSavedUserId(): string {
    try {
      if (this.pref) {
        return this.pref.getSync('saved_user_id', '') as string;
      }
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to get saved userId');
    }
    return '';
  }

  // 获取已保存的用户名
  private getSavedUsername(): string {
    try {
      if (this.pref) {
        return this.pref.getSync('saved_username', '') as string;
      }
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to get saved username');
    }
    return '';
  }
}
