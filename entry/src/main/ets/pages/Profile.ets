// Profile.ets - 个人中心页（ProfileAbility内）
import { common, Want } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import promptAction from '@ohos.promptAction';
import { KVStoreUtil } from '../common/utils/KVStoreUtil';
import {
  DEFAULT_FONT_SIZE,
  DEFAULT_THEME_MODE,
  MAX_FONT_SIZE,
  MIN_FONT_SIZE
} from '../common/constants/StorageKeys';

@Entry
@Component
struct Profile {
  @State username: string = '张小明';
  @State userId: string = '';
  @State major: string = '计算机科学与技术';
  @State showSettings: boolean = false;
  @State themeMode: string = DEFAULT_THEME_MODE;
  @State fontSize: number = DEFAULT_FONT_SIZE;

  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  // 功能列表数据
  private functionList: FunctionItemData[] = [
    { name: '学籍卡包', icon: '学' },
    { name: '2026春季校历', icon: '历' },
    { name: '我的成绩单', icon: '绩' },
    { name: '隐私与安全', icon: '安' },
    { name: '帮助与反馈', icon: '帮' },
    { name: '通用设置', icon: '设' }
  ];

  aboutToAppear() {
    // 从AppStorage获取ProfileAbility传入的参数
    console.log('>>> [Profile] aboutToAppear 被调用');
    const storedUserId: string = AppStorage.get('profileUserId') ?? '';
    const storedUsername: string = AppStorage.get('profileUsername') ?? '';
    const storedMajor: string = AppStorage.get('profileMajor') ?? '';
    console.log('>>> [Profile] 从AppStorage读取 - userId: ' + storedUserId + ', username: ' + storedUsername + ', major: ' + storedMajor);
    if (storedUserId) { this.userId = storedUserId; }
    if (storedUsername) { this.username = storedUsername; }
    if (storedMajor) { this.major = storedMajor; }
    this.loadSettings();
    console.log('>>> [Profile] 页面显示 - userId: ' + this.userId + ', username: ' + this.username + ', major: ' + this.major);
  }

  private async loadSettings(): Promise<void> {
    try {
      this.themeMode = await KVStoreUtil.getThemeMode(this.context as Context);
      this.fontSize = await KVStoreUtil.getFontSize(this.context as Context);
    } catch (err) {
      console.error('Failed to load settings: ' + JSON.stringify(err));
    }
  }

  private getPageBackgroundColor(): string {
    return this.themeMode === 'dark' ? '#1F1F1F' : '#F5F5F5';
  }

  private getCardBackgroundColor(): string {
    return this.themeMode === 'dark' ? '#2A2A2A' : '#FFFFFF';
  }

  private getPrimaryTextColor(): string {
    return this.themeMode === 'dark' ? '#F5F5F5' : '#333333';
  }

  private getSecondaryTextColor(): string {
    return this.themeMode === 'dark' ? '#C9CDD4' : '#666666';
  }

  private async setThemeMode(mode: string): Promise<void> {
    this.themeMode = mode;
    await KVStoreUtil.setThemeMode(this.context as Context, mode);
  }

  private async setFontSize(size: number): Promise<void> {
    this.fontSize = Math.round(size);
    await KVStoreUtil.setFontSize(this.context as Context, this.fontSize);
  }

  // 返回MainAbility（Ability级别跳转，携带返回结果）
  private navigateBack(): void {
    console.log('>>> [Profile] 点击返回，准备 terminateSelfWithResult');
    console.log('>>> [Profile] 返回参数 - userId: ' + this.userId + ', username: ' + this.username + ', major: ' + this.major);
    const resultWant: Want = {
      parameters: {
        userId: this.userId,
        username: this.username,
        major: this.major
      }
    };
    const abilityResult: common.AbilityResult = {
      resultCode: 0,
      want: resultWant
    };
    console.log('>>> [Profile] 调用 terminateSelfWithResult');
    this.context.terminateSelfWithResult(abilityResult);
  }

  // 清除登录状态
  private clearLoginStatus(): void {
    try {
      const pref = preferences.getPreferencesSync(this.context, { name: 'school_app_prefs' });
      pref.putSync('is_logged_in', false);
      pref.flushSync();
    } catch (err) {
      console.error('Failed to clear login status: ' + JSON.stringify(err));
    }
  }

  build() {
    Column() {
      if (this.showSettings) {
        this.buildSettingsPage();
      } else {
        this.buildProfilePage();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.getPageBackgroundColor())
  }

  @Builder
  private buildProfilePage() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor(this.getPrimaryTextColor())
          .onClick(() => { this.navigateBack(); })

        Blank()

        Text('我的')
          .fontSize(this.fontSize + 2)
          .fontWeight(600)
          .fontColor(this.getPrimaryTextColor())

        Blank()

        Text('设置')
          .fontSize(this.fontSize)
          .fontColor('#007DFF')
          .onClick(() => {
            this.showSettings = true;
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(this.getCardBackgroundColor())
      .alignItems(VerticalAlign.Center)

      // 内容区域
      Scroll() {
        Column({ space: 12 }) {
          // 头部信息区
          Row({ space: 16 }) {
            Stack() {
              Circle()
                .width(60)
                .height(60)
                .fill('#E8F3FF')
              Text(this.username.charAt(0))
                .fontSize(this.fontSize + 8)
                .fontColor('#007DFF')
            }

            Column({ space: 4 }) {
              Text(this.username)
                .fontSize(this.fontSize + 2)
                .fontWeight(700)
                .fontColor(this.getPrimaryTextColor())
              Text(`${this.major} - 2024级`)
                .fontSize(this.fontSize)
                .fontColor(this.getSecondaryTextColor())
              Row() {
                Text('学号: ')
                  .fontSize(this.fontSize)
                  .fontColor(this.getSecondaryTextColor())
                Text(this.userId)
                  .fontSize(this.fontSize)
                  .fontColor('#007DFF')
              }
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding(20)
          .backgroundColor(this.getCardBackgroundColor())
          .borderRadius(12)
          .alignItems(VerticalAlign.Center)

          // 数据统计区
          Row() {
            Column({ space: 4 }) {
              Text('12')
                .fontSize(this.fontSize + 4)
                .fontWeight(700)
                .fontColor(this.getPrimaryTextColor())
              Text('我的发布')
                .fontSize(this.fontSize - 2)
                .fontColor(this.getSecondaryTextColor())
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Column({ space: 4 }) {
              Text('45')
                .fontSize(this.fontSize + 4)
                .fontWeight(700)
                .fontColor(this.getPrimaryTextColor())
              Text('我的收藏')
                .fontSize(this.fontSize - 2)
                .fontColor(this.getSecondaryTextColor())
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Column({ space: 4 }) {
              Text('128')
                .fontSize(this.fontSize + 4)
                .fontWeight(700)
                .fontColor(this.getPrimaryTextColor())
              Text('积分')
                .fontSize(this.fontSize - 2)
                .fontColor(this.getSecondaryTextColor())
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .padding({ top: 16, bottom: 16 })
          .backgroundColor(this.getCardBackgroundColor())
          .borderRadius(12)
          .justifyContent(FlexAlign.SpaceAround)

          // 功能菜单区
          Column() {
            ForEach(this.functionList, (item: FunctionItemData) => {
              Row() {
                Text(item.icon)
                  .fontSize(this.fontSize + 2)
                  .fontColor(this.getSecondaryTextColor())
                  .width(24)
                  .textAlign(TextAlign.Center)

                Text(item.name)
                  .fontSize(this.fontSize)
                  .fontColor(this.getPrimaryTextColor())
                  .margin({ left: 12 })
                  .layoutWeight(1)

                Text('>')
                  .fontSize(this.fontSize)
                  .fontColor(this.getSecondaryTextColor())
              }
              .width('100%')
              .height(48)
              .padding({ left: 16, right: 16 })
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                if (item.name === '通用设置') {
                  this.showSettings = true;
                  return;
                }
                promptAction.showToast({ message: `${item.name}功能开发中` });
              })
            })
          }
          .width('100%')
          .backgroundColor(this.getCardBackgroundColor())
          .borderRadius(12)

          // 退出登录按钮
          Button('退出当前账号')
            .width('100%')
            .height(48)
            .fontSize(this.fontSize)
            .fontColor('#FF0000')
            .backgroundColor(this.getCardBackgroundColor())
            .borderRadius(12)
            .margin({ top: 12 })
            .onClick(() => {
              // 清除登录状态
              this.clearLoginStatus();
              // 退出登录，返回StartAbility的登录页
              const want: Want = {
                bundleName: 'com.example.schoolapp',
                abilityName: 'StartAbility'
              };
              this.context.startAbility(want)
                .then(() => {
                  console.log('===== [Profile] startAbility to StartAbility 成功 =====');
                  const resultWant: Want = {
                    parameters: {
                      userId: this.userId,
                      username: this.username,
                      major: this.major
                    }
                  };
                  const abilityResult: common.AbilityResult = {
                    resultCode: 0,
                    want: resultWant
                  };
                  this.context.terminateSelfWithResult(abilityResult);
                })
                .catch((err: Error) => {
                  promptAction.showToast({ message: '跳转失败: ' + err.message });
                });
            })

          // 版本信息
          Text('校通Plus Version 4.2.0 (Build 20260401)')
            .fontSize(this.fontSize - 4)
            .fontColor(this.getSecondaryTextColor())
            .margin({ top: 16, bottom: 30 })
        }
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
  }

  @Builder
  private buildSettingsPage() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor(this.getPrimaryTextColor())
          .onClick(() => {
            this.showSettings = false;
          })

        Blank()

        Text('通用设置')
          .fontSize(18)
          .fontWeight(600)
          .fontColor(this.getPrimaryTextColor())

        Blank()

        Row()
          .width(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(this.getCardBackgroundColor())
      .alignItems(VerticalAlign.Center)

      Column({ space: 16 }) {
        Column({ space: 12 }) {
          Text('主题模式')
            .fontSize(16)
            .fontColor(this.getPrimaryTextColor())

          Row({ space: 12 }) {
            Button('浅色')
              .layoutWeight(1)
              .height(40)
              .fontColor(this.themeMode === 'light' ? '#FFFFFF' : '#007DFF')
              .backgroundColor(this.themeMode === 'light' ? '#007DFF' : '#EAF3FF')
              .borderRadius(20)
              .onClick(() => {
                this.setThemeMode('light');
              })
            Button('深色')
              .layoutWeight(1)
              .height(40)
              .fontColor(this.themeMode === 'dark' ? '#FFFFFF' : '#007DFF')
              .backgroundColor(this.themeMode === 'dark' ? '#007DFF' : '#EAF3FF')
              .borderRadius(20)
              .onClick(() => {
                this.setThemeMode('dark');
              })
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.getCardBackgroundColor())
        .borderRadius(12)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 12 }) {
          Text(`字体大小：${this.fontSize}`)
            .fontSize(16)
            .fontColor(this.getPrimaryTextColor())

          Slider({
            value: this.fontSize,
            min: MIN_FONT_SIZE,
            max: MAX_FONT_SIZE,
            step: 1,
            style: SliderStyle.OutSet
          })
            .width('100%')
            .showSteps(true)
            .onChange((value: number) => {
              this.setFontSize(value);
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.getCardBackgroundColor())
        .borderRadius(12)
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)
      .padding(16)
    }
  }
}

interface FunctionItemData {
  name: string;
  icon: string;
}
