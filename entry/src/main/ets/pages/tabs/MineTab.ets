/**
 * MineTab.ets - 我的 Tab 页
 * 个人信息卡片 + 功能列表 + 设置模块 + 退出登录
 */
import { router } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import promptAction from '@ohos.promptAction';
import { KVStoreUtil } from '../../common/utils/KVStoreUtil';

interface FunctionItem {
  name: string;
  icon: string;
  symbol?: Resource;
  target?: string;
}

@Component
export struct MineTab {
  @Prop @Watch('onDarkChange') isDarkMode: boolean = false;
  @State darkPrimary: string = '#1D2129';
  @State darkSecondary: string = '#86909C';
  @StorageLink('fontScale') @Watch('onFontScaleChange') fontScale: number = 1.0;
  @State fsTitle: number = 30;
  @State fsMid: number = 28;
  @State fsBody: number = 26;
  @State fsSmall: number = 24;
  @State fsTiny: number = 22;

  private onDarkChange(): void {
    this.darkPrimary = this.isDarkMode ? '#E8E8E8' : '#1D2129';
    this.darkSecondary = this.isDarkMode ? '#A0A0A0' : '#86909C';
  }

  private onFontScaleChange(): void {
    this.fsTitle = Math.round(30 * this.fontScale);
    this.fsMid = Math.round(28 * this.fontScale);
    this.fsBody = Math.round(26 * this.fontScale);
    this.fsSmall = Math.round(24 * this.fontScale);
    this.fsTiny = Math.round(22 * this.fontScale);
  }
  @Prop username: string = '用户';
  @Prop userId: string = '';
  @Prop major: string = '计算机科学与技术';
  @State cacheSize: string = '64.2MB';
  onProfileEditClick?: () => void;
  onSettingClick?: () => void;
  onTabSwitch?: (tabIndex: number) => void;

  // 功能列表项（带路由目标）
  private functionList: FunctionItem[] = [
    { name: '我的收藏', icon: '❤️', symbol: $r('sys.symbol.heart_fill'), target: 'pages/mine/FavoritePage' },
    { name: '我的待办', icon: '📝', symbol: $r('sys.symbol.doc_text'), target: 'pages/mine/TodoPage' },
    { name: '我的课程', icon: '📅', symbol: $r('sys.symbol.calendar'), target: '' },
    { name: '我的成绩', icon: '📊', target: '' },
    { name: '失物发布', icon: '📋', symbol: $r('sys.symbol.doc_text'), target: 'pages/life/LostFoundPublishPage' },
    { name: '帮助中心', icon: '❓', symbol: $r('sys.symbol.questionmark_circle'), target: '' },
    { name: '意见反馈', icon: '💬', symbol: $r('sys.symbol.message'), target: '' }
  ];

  // 设置项
  private settingList: FunctionItem[] = [
    { name: '深色模式', icon: '🌙', symbol: $r('sys.symbol.moon') },
    { name: '字体大小', icon: '🔤', symbol: $r('sys.symbol.textformat') },
    { name: '通知设置', icon: '🔔', symbol: $r('sys.symbol.bell') },
    { name: '清理缓存', icon: '🗑️', symbol: $r('sys.symbol.trash') }
  ];

  private navigateTo(target: string): void {
    if (target === '') {
      promptAction.showToast({ message: '功能开发中，敬请期待' });
      return;
    }
    router.pushUrl({ url: target })
      .catch(() => {
        promptAction.showToast({ message: '页面打开失败' });
      });
  }

  // 退出登录：仅清除登录态，保留注册数据供下次登录
  private doLogout(): void {
    try {
      const pref = preferences.getPreferencesSync(getContext(this), { name: 'school_app_prefs' });
      pref.putSync('is_logged_in', false);
      pref.flushSync();
    } catch (err) {
      console.error('>>> [MineTab] 清除登录态失败: ' + JSON.stringify(err));
    }
    try {
      router.clear();
      router.pushUrl({ url: 'pages/Login' });
    } catch (err) {
      console.error('>>> [MineTab] 跳转登录页失败: ' + JSON.stringify(err));
    }
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Text('我的')
          .fontSize(this.fsTitle)
          .fontWeight(600)
          .fontColor(this.darkPrimary)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        SymbolGlyph($r('sys.symbol.gearshape'))
          .fontSize(this.fsSmall)
          .onClick(() => {
            if (this.onSettingClick) {
              this.onSettingClick();
            }
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .backgroundColor(this.isDarkMode ? '#252540' : $r('app.color.card_white'))

      Scroll() {
        Column({ space: 16 }) {
          // 个人信息卡片
          Row({ space: 16 }) {
            // 头像 — 圆形 80px
            Stack() {
              Circle()
                .width(80)
                .height(80)
                .fill($r('app.color.primary_light'))
              Text(this.username.charAt(0))
                .fontSize(32)
                .fontColor($r('app.color.primary'))
            }
            .onClick(() => {
              if (this.onProfileEditClick) {
                this.onProfileEditClick();
              } else {
                this.navigateTo('pages/mine/ProfileEditPage');
              }
            })

            Column({ space: 4 }) {
              Text(this.username)
                .fontSize(this.fsMid)
                .fontWeight(700)
                .fontColor(this.darkPrimary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(`学号: ${this.userId}`)
                .fontSize(this.fsSmall)
                .fontColor(this.darkSecondary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(`${this.major}`)
                .fontSize(this.fsTiny)
                .fontColor(this.darkSecondary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text('>')
              .fontSize(this.fsSmall)
              .fontColor(this.darkSecondary)
          }
          .width('100%')
          .padding(20)
          .backgroundColor(this.isDarkMode ? '#252540' : $r('app.color.card_white'))
          .borderRadius(8)
          .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
          .onClick(() => {
            this.navigateTo('pages/mine/ProfileEditPage');
          })

          // 功能列表
          Column() {
            ForEach(this.functionList, (item: FunctionItem) => {
              Row() {
                if (item.symbol) {
                  SymbolGlyph(item.symbol)
                    .fontSize(this.fsSmall)
                    .width(32)
                } else {
                  Text(item.icon)
                    .fontSize(this.fsSmall)
                    .width(32)
                    .textAlign(TextAlign.Center)
                }

                Text(item.name)
                  .fontSize(this.fsBody)
                  .fontColor(this.darkPrimary)
                  .margin({ left: 12 })
                  .layoutWeight(1)

                Text('>')
                  .fontSize(this.fsSmall)
                  .fontColor(this.darkSecondary)
              }
              .width('100%')
              .height(48)
              .padding({ left: 16, right: 16 })
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                if (item.name === '我的课程' || item.name === '我的成绩') {
                  if (this.onTabSwitch) {
                    this.onTabSwitch(2);
                  }
                  return;
                }
                if (item.target) {
                  this.navigateTo(item.target);
                } else {
                  promptAction.showToast({ message: item.name + '功能开发中' });
                }
              })
            }, (item: FunctionItem) => item.name)
          }
          .width('100%')
          .backgroundColor(this.isDarkMode ? '#252540' : $r('app.color.card_white'))
          .borderRadius(8)
          .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })

          // 设置模块
          Column() {
            ForEach(this.settingList, (item: FunctionItem) => {
              Row() {
                if (item.symbol) {
                  SymbolGlyph(item.symbol)
                    .fontSize(this.fsSmall)
                    .width(32)
                } else {
                  Text(item.icon)
                    .fontSize(this.fsSmall)
                    .width(32)
                    .textAlign(TextAlign.Center)
                }

                Text(item.name)
                  .fontSize(this.fsBody)
                  .fontColor(this.darkPrimary)
                  .margin({ left: 12 })
                  .layoutWeight(1)

                if (item.name === '深色模式') {
                  Toggle({ type: ToggleType.Switch, isOn: this.isDarkMode })
                    .selectedColor($r('app.color.primary'))
                    .width(48)
                    .onChange((val: boolean) => {
                      AppStorage.Set('isDarkMode', val);
                      const dmCtx: Context = getContext(this);
                      KVStoreUtil.setThemeMode(dmCtx, val ? 'dark' : 'light');
                    })
                } else if (item.name === '清理缓存') {
                  Text(this.cacheSize)
                    .fontSize(this.fsSmall)
                    .fontColor($r('app.color.warm_orange'))
                    .margin({ right: 8 })
                    .onClick(() => {
                      this.cacheSize = '0.0MB';
                      promptAction.showToast({ message: '缓存清理完成' });
                    })
                } else {
                  Text('>')
                    .fontSize(this.fsSmall)
                    .fontColor(this.darkSecondary)
                    .onClick(() => {
                      if (item.name === '通知设置') {
                        promptAction.showToast({ message: '通知设置页开发中' });
                      }
                    })
                }
              }
              .width('100%')
              .height(48)
              .padding({ left: 16, right: 16 })
              .alignItems(VerticalAlign.Center)
            }, (item: FunctionItem) => item.name)
          }
          .width('100%')
          .backgroundColor(this.isDarkMode ? '#252540' : $r('app.color.card_white'))
          .borderRadius(8)
          .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })

          // 退出登录按钮
          Button('退出登录')
            .width('100%')
            .height(48)
            .fontSize(this.fsBody)
            .fontColor($r('app.color.warm_orange'))
            .backgroundColor(this.isDarkMode ? '#252540' : $r('app.color.card_white'))
            .borderRadius(8)
            .border({ width: 1, color: $r('app.color.warm_orange') })
            .onClick(() => {
              this.doLogout();
            })

          // 底部关于区
          Column({ space: 4 }) {
            Text('高校校园助手 V1.0.0')
              .fontSize(this.fsSmall)
              .fontColor(this.darkSecondary)
            Text('校园助手开发团队')
              .fontSize(this.fsTiny)
              .fontColor(this.darkSecondary)
            Text('© 2026 All Rights Reserved')
              .fontSize(this.fsTiny)
              .fontColor(this.darkSecondary)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .margin({ top: 24, bottom: 30 })
        }
        .padding({ left: 20, right: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isDarkMode ? '#1A1A2E' : $r('app.color.background'))
  }
}
