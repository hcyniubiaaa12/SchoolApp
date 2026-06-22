// Start.ets - 启动页（StartAbility内）
import { common, Want } from '@kit.AbilityKit';
import promptAction from '@ohos.promptAction';
import { PreferencesUtil } from '../common/utils/PreferencesUtil';

@Entry
@Component
struct Start {
  @State progress: number = 0;
  @State dotIndex: number = 0;
  @State isFirstLaunch: boolean = false;
  private timer: number = -1;
  private dotTimer: number = -1;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  async aboutToAppear() {
    try {
      const isFirstLaunch = await PreferencesUtil.isFirstLaunch(this.context as Context);
      this.isFirstLaunch = isFirstLaunch;
      if (isFirstLaunch) {
        promptAction.showToast({ message: '欢迎使用' });
        await PreferencesUtil.markFirstLaunchComplete(this.context as Context);
        this.isFirstLaunch = false;
      }
    } catch (err) {
      console.error('Failed to handle first launch: ' + JSON.stringify(err));
    }

    this.timer = setInterval(() => {
      this.progress += 1;
      if (this.progress >= 100) {
        clearInterval(this.timer);
        this.timer = -1;
        this.navigateToGuide();
      }
    }, 30);

    // 3个蓝色圆点循环动画
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

  private navigateToGuide(): void {
    // Ability内页面跳转，使用eventHub通知Ability加载引导页
    this.context.eventHub.emit('navigateToGuide');
  }

  private async resetFirstLaunch(): Promise<void> {
    try {
      await PreferencesUtil.resetFirstLaunch(this.context as Context);
      this.isFirstLaunch = true;
      promptAction.showToast({ message: '首次启动标记已重置' });
    } catch (err) {
      console.error('Failed to reset first launch: ' + JSON.stringify(err));
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

        // 调试按钮（仅开发用）
        Button('重置首次启动标记')
          .width(180)
          .height(32)
          .fontSize(12)
          .fontColor('#FFFFFFCC')
          .backgroundColor('#FFFFFF26')
          .borderRadius(16)
          .onClick(() => {
            this.resetFirstLaunch();
          })
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
      if (this.timer !== -1) {
        clearInterval(this.timer);
        this.timer = -1;
      }
      if (this.dotTimer !== -1) {
        clearInterval(this.dotTimer);
        this.dotTimer = -1;
      }
      this.navigateToGuide();
    })
  }
}
