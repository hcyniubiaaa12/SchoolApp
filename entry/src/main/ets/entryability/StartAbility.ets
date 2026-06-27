import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { TransientTaskUtil } from '../common/utils/TransientTaskUtil';
import { UserDao } from '../common/database/UserDao';

const DOMAIN = 0x0000;
const PREF_NAME = 'school_app_prefs';
// 注意：必须与 StorageKeys.KEY_FIRST_LAUNCH 一致，否则首次启动标记永不生效
const KEY_FIRST_LAUNCH = 'is_first_launch_lab';
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

    // 每次启动都先显示启动页（splash），由启动页内部判断下一步去向
    hilog.info(DOMAIN, 'testTag', 'Loading Start page');
    windowStage.loadContent('pages/Start', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
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

    // 导航到启动页（引导页第1页侧滑返回）
    this.context.eventHub.on('navigateToStart', () => {
      this.loadPage('pages/Start');
    });

    // 导航到登录页
    this.context.eventHub.on('navigateToLogin', () => {
      this.loadPage('pages/Login');
    });

    // 导航到注册页
    this.context.eventHub.on('navigateToRegist', () => {
      this.loadPage('pages/Regist');
    });

    // 导航到首页（已登录用户，设置用户信息后加载）
    this.context.eventHub.on('navigateToIndex', () => {
      const savedUserId = UserDao.getCurrentUserIdSync(this.context);
      const user = UserDao.findByIdSync(this.context, savedUserId);
      AppStorage.setOrCreate('userId', savedUserId);
      AppStorage.setOrCreate('username', user.username);
      this.loadPage('pages/Index');
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

}
