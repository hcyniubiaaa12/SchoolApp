// Start.ets - 启动页（每次打开APP都显示，内部判断下一步去向）
// 首次启动 → 引导页；已登录 → 首页；未登录 → 登录页
import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import promptAction from '@ohos.promptAction';
import { PreferencesUtil } from '../common/utils/PreferencesUtil';

const PREF_NAME: string = 'school_app_prefs';
const KEY_IS_LOGGED_IN: string = 'is_logged_in';

@Entry
@Component
struct Start {
  @State progress: number = 0;
  @State dotIndex: number = 0;
  private wasFirstLaunch: boolean = false;
  private timer: number = -1;
  private dotTimer: number = -1;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  async aboutToAppear() {
    try {
      // 判断是否首次启动
      this.wasFirstLaunch = await PreferencesUtil.isFirstLaunch(this.context as Context);
      if (this.wasFirstLaunch) {
        promptAction.showToast({ message: '欢迎使用' });
        await PreferencesUtil.markFirstLaunchComplete(this.context as Context);
      }
    } catch (err) {
      console.error('Failed to handle first launch: ' + JSON.stringify(err));
    }

    // 动画循环：进度条
    this.timer = setInterval(() => {
      this.progress += 1;
      if (this.progress >= 100) {
        this.afterSplash();
      }
    }, 30);

    // 3个白色圆点循环动画
    this.dotTimer = setInterval(() => {
      this.dotIndex = (this.dotIndex + 1) % 3;
    }, 400);
  }

  aboutToDisappear() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
    if (this.dotTimer !== -1) {
      clearInterval(this.dotTimer);
    }
  }

  // 启动动画结束后统一跳转
  private afterSplash(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
    if (this.dotTimer !== -1) {
      clearInterval(this.dotTimer);
      this.dotTimer = -1;
    }

    if (this.wasFirstLaunch) {
      // 首次启动 → 引导页
      this.context.eventHub.emit('navigateToGuide');
    } else {
      // 非首次 → 根据登录状态跳转
      this.navigateByLoginStatus();
    }
  }

  // 检查登录状态并跳转
  private async navigateByLoginStatus(): Promise<void> {
    try {
      const pref = await preferences.getPreferences(this.context as Context, { name: PREF_NAME });
      const isLoggedIn = (await pref.get(KEY_IS_LOGGED_IN, false)) as boolean;
      if (isLoggedIn) {
        // 已登录 → 首页
        this.context.eventHub.emit('navigateToIndex');
      } else {
        // 未登录 → 登录页
        this.context.eventHub.emit('navigateToLogin');
      }
    } catch (err) {
      // 出错时默认跳登录页
      console.error('Failed to check login status: ' + JSON.stringify(err));
      this.context.eventHub.emit('navigateToLogin');
    }
  }

  build() {
    Column() {
      // 上半部分留白
      Column()
        .layoutWeight(1)

      // 中心内容区域
      Column({ space: 20 }) {
        // Logo图标（蓝色圆角方背景+logo图标）
        Stack() {
          Row()
            .width(120)
            .height(120)
            .borderRadius(24)
            .linearGradient({
              direction: GradientDirection.Bottom,
              colors: [['#1677FF', 0], ['#4096FF', 1]]
            })

          Image($r('app.media.logo'))
            .width(72)
            .height(72)
            .objectFit(ImageFit.Contain)
            .fillColor('#FFFFFF')
        }

        // APP名称
        Text('高校校园助手')
          .fontSize(36)
          .fontWeight(700)
          .fontColor('#FFFFFF')

        // Slogan
        Text('HarmonyOS NEXT 版')
          .fontSize(24)
          .fontColor('#FFFFFFCC')

        Text('智慧校园 · 悦享生活')
          .fontSize(24)
          .fontColor('#FFFFFFCC')
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // 下半部分留白
      Column()
        .layoutWeight(1)

      // 底部：加载指示器 + 开发团队
      Column({ space: 16 }) {
        // 3个白色圆点循环指示
        Row({ space: 8 }) {
          Circle()
            .width(8)
            .height(8)
            .fill(this.dotIndex === 0 ? '#FFFFFF' : '#FFFFFF66')
          Circle()
            .width(8)
            .height(8)
            .fill(this.dotIndex === 1 ? '#FFFFFF' : '#FFFFFF66')
          Circle()
            .width(8)
            .height(8)
            .fill(this.dotIndex === 2 ? '#FFFFFF' : '#FFFFFF66')
        }

        Text('校园助手开发团队')
          .fontSize(22)
          .fontColor('#FFFFFFCC')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 40 })
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      direction: GradientDirection.Top,
      colors: [['#1677FF', 0], ['#4096FF', 1]]
    })
    .onClick(() => {
      this.afterSplash();
    })
  }
}
