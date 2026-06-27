// Index.ets - 首页（MainAbility内）
// P0 重做: 5 底部 Tab（首页/校园信息/学习助手/生活服务/我的），默认首页
import { common, Want } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import { KVStoreUtil } from '../common/utils/KVStoreUtil';
import {
  DEFAULT_FONT_SIZE,
  MAX_FONT_SIZE,
  MIN_FONT_SIZE
} from '../common/constants/StorageKeys';
import { DataInitializer } from '../common/database/DataInitializer';
import { HomeTab, QuickEntryItem } from './tabs/HomeTab';
import { CampusInfoTab } from './tabs/CampusInfoTab';
import { StudyTab } from './tabs/StudyTab';
import { LifeServiceTab } from './tabs/LifeServiceTab';
import { MineTab } from './tabs/MineTab';

const NAV_PROFILE: string = 'Profile';
const NAV_SETTING: string = 'Setting';
const NAV_HELP: string = 'Help';
const LAB_ENTRY_NAME: string = '数据存储实验';
const BG_TASK_ENTRY_NAME: string = '后台服务实验';

@Entry
@Component
struct Index {
  navPathStack: NavPathStack = new NavPathStack();
  @State username: string = '用户';
  @State userId: string = '';
  // P0: 默认加载首页 Tab (索引 0)
  @State currentTab: number = 0;
  @State swiperIndex: number = 0;
  @State courseRefreshSignal: number = 0;
  @State lfRefreshSignal: number = 0;
  @StorageLink('isDarkMode') isDarkMode: boolean = false;

  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {
    // 从 AppStorage 获取 MainAbility 传入的参数
    console.log('>>> [Index] aboutToAppear 被调用');
    const storedUserId: string = AppStorage.get('userId') ?? '';
    const storedUsername: string = AppStorage.get('username') ?? '';
    console.log('>>> [Index] 从 AppStorage 读取 - userId: ' + storedUserId + ', username: ' + storedUsername);
    if (storedUserId) { this.userId = storedUserId; }
    if (storedUsername) { this.username = storedUsername; }
    console.log('>>> [Index] 页面显示 - userId: ' + this.userId + ', username: ' + this.username);
    // 首次启动：导入初始数据到 RDB
    DataInitializer.seedIfEmpty(this.context);
    // 加载深色模式偏好（先默认浅色，再异步读取覆盖）
    AppStorage.Set('isDarkMode', false);
    KVStoreUtil.getThemeMode(this.context).then((mode: string) => {
      if (mode === 'dark') {
        AppStorage.Set('isDarkMode', true);
      }
    });
    // 初始化字体缩放
    KVStoreUtil.getFontSize(this.context).then((size: number) => {
      AppStorage.Set('fontScale', size / DEFAULT_FONT_SIZE);
    });
  }

  onPageShow(): void {
    // 每次页面显示时刷新各 Tab 数据（如编辑课程/发布失物后返回）
    this.courseRefreshSignal++;
    this.lfRefreshSignal++;
  }

  // 跳转到 ProfileAbility（从 TabBar「我的」点击时的备选，下个版本收敛到 MineTab）
  private navigateToProfile(): void {
    const want: Want = {
      bundleName: 'com.example.schoolapp',
      abilityName: 'ProfileAbility',
      parameters: {
        userId: this.userId,
        username: this.username,
        major: '计算机科学与技术'
      }
    };
    this.context.startAbility(want)
      .then(() => {
        console.log('===== [Index] startAbility to ProfileAbility 成功 =====');
      })
      .catch((err: Error) => {
        console.error('===== [Index] startAbility to ProfileAbility 失败: ' + err.message + ' =====');
      });
  }

  // 跳转实验页
  private navigateToDataStorageLab(): void {
    router.pushUrl({ url: 'pages/DataStorageLab' })
      .catch((err: Error) => {
        promptAction.showToast({ message: '打开实验页失败: ' + err.message });
      });
  }

  private navigateToBackgroundTaskLab(): void {
    router.pushUrl({ url: 'pages/BackgroundTaskLab' })
      .catch((err: Error) => {
        promptAction.showToast({ message: '打开实验页失败: ' + err.message });
      });
  }

  // 处理九宫格入口点击
  private handleQuickEntryClick(entry: QuickEntryItem): void {
    console.log('>>> [Index] 九宫格点击: ' + entry.name);
    // 数据存储实验和后台服务实验通过九宫格里对应名称匹配
    if (entry.name === '数据存储实验') {
      this.navigateToDataStorageLab();
    } else if (entry.name === '后台服务实验') {
      this.navigateToBackgroundTaskLab();
    }
    // 学习助手相关：切换到学习助手 Tab
    else if (entry.name === '课程表' || entry.name === '成绩查询' || entry.name === '图书馆') {
      this.currentTab = 2;
      if (entry.name !== '课程表') {
        promptAction.showToast({ message: entry.name + '功能已开放，已为你打开学习助手' });
      }
    }
    // 校园信息相关：切换到校园信息 Tab
    else if (entry.name === '校园公告' || entry.name === '校园地图') {
      this.currentTab = 1;
    }
    // 生活服务相关：切换到生活服务 Tab
    else if (entry.name === '失物招领' || entry.name === '校园美食' || entry.name === '音乐播放') {
      this.currentTab = 3;
    }
    // 待办提醒：跳转我的 → 待办页
    else if (entry.name === '待办提醒') {
      router.pushUrl({ url: 'pages/mine/TodoPage' })
        .catch((err: Error) => {
          console.error('[Index] todo page error: ' + err.message);
        });
    }
  }

  build() {
    Navigation(this.navPathStack) {
      // 使用官方 Tabs 组件实现底部导航（替代手工 Row + Column，解决内容溢出遮挡 Tab 问题）
      Tabs({ barPosition: BarPosition.End, index: this.currentTab }) {
        TabContent() {
          HomeTab({
            isDarkMode: this.isDarkMode,
            username: this.username,
            onSearchClick: () => {
              router.pushUrl({ url: 'pages/common/SearchPage' })
                .catch((err: Error) => {
                  promptAction.showToast({ message: '打开搜索页失败' });
                  console.error('[Index] search page error: ' + err.message);
                });
            },
            onMessageClick: () => {
              router.pushUrl({ url: 'pages/common/MessageCenterPage' })
                .catch((err: Error) => {
                  promptAction.showToast({ message: '打开消息中心失败' });
                  console.error('[Index] message page error: ' + err.message);
                });
            },
            onQuickEntryClick: (entry: QuickEntryItem) => {
              this.handleQuickEntryClick(entry);
            },
            onWeatherClick: () => {
              router.pushUrl({ url: 'pages/common/WeatherDetailPage' })
                .catch((err: Error) => {
                  promptAction.showToast({ message: '打开天气页失败' });
                  console.error('[Index] weather page error: ' + err.message);
                });
            }
          })
        }
        .tabBar(this.buildTabBar('首页', 0, $r('sys.symbol.house')))

        TabContent() {
          CampusInfoTab({ isDarkMode: this.isDarkMode })
        }
        .tabBar(this.buildTabBar('校园信息', 1, $r('sys.symbol.building')))

        TabContent() {
          StudyTab({ uiContext: this.context, refreshSignal: this.courseRefreshSignal, isDarkMode: this.isDarkMode })
        }
        .tabBar(this.buildTabBar('学习助手', 2, $r('sys.symbol.book')))

        TabContent() {
          LifeServiceTab({ uiContext: this.context, isDarkMode: this.isDarkMode, refreshSignal: this.lfRefreshSignal })
        }
        .tabBar(this.buildTabBar('生活服务', 3, $r('sys.symbol.bag')))

        TabContent() {
          MineTab({
            isDarkMode: this.isDarkMode,
            username: this.username,
            userId: this.userId,
            onProfileEditClick: () => {
              router.pushUrl({ url: 'pages/mine/ProfileEditPage' })
                .catch((err: Error) => {
                  promptAction.showToast({ message: '打开编辑页失败' });
                  console.error('[Index] profile edit error: ' + err.message);
                });
            },
            onSettingClick: () => {
              // 跳转设置页（NavDestination 内）
              this.navPathStack.pushPath({ name: NAV_SETTING, param: { type: 'setting' } as PageTypeParam });
            },
            onTabSwitch: (tabIndex: number) => {
              this.currentTab = tabIndex;
            }
          })
        }
        .tabBar(this.buildTabBar('我的', 4, $r('sys.symbol.person')))
      }
      .onChange((index: number) => {
        this.currentTab = index;
      })
      .scrollable(false)
      .barMode(BarMode.Fixed)
      .barHeight(56)
      .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')
      .border({ width: { top: 1 }, color: this.isDarkMode ? '#333344' : '#E5E6EB' })
    }
    .navDestination(this.buildNavDestination)
    .mode(NavigationMode.Auto)
    .hideTitleBar(true)
    .hideToolBar(true)
    .navBarWidth('100%')
    .backgroundColor(this.isDarkMode ? '#1A1A2E' : '#F5F7FA')
  }

  // Tabs 自定义 tabBar builder：系统 Symbol 图标 + 文字
  @Builder
  buildTabBar(title: string, index: number, symbol: Resource) {
    Column({ space: 2 }) {
      SymbolGlyph(symbol)
        .fontSize(24)
        .fontColor(this.currentTab === index ? ['#1677FF'] : [this.isDarkMode ? '#A0A0A0' : '#86909C'])
      Text(title)
        .fontSize(20)
        .fontColor(this.currentTab === index ? '#1677FF' : (this.isDarkMode ? '#A0A0A0' : '#86909C'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Clip })
        .width('100%')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // NavDestination 构建器（保留 ProfilePage / SettingPage 兼容）
  @Builder
  buildNavDestination(name: string, param: Record<string, string>) {
    if (name === NAV_PROFILE) {
      ProfilePage({
        username: param['username'] ?? '用户',
        userId: param['userId'] ?? '',
        major: param['major'] ?? '',
        pathStack: this.navPathStack
      })
    } else if (name === NAV_SETTING) {
      SettingPage({ pageType: 'setting', pathStack: this.navPathStack })
    } else if (name === NAV_HELP) {
      SettingPage({ pageType: 'help', pathStack: this.navPathStack })
    }
  }
}

// ============ NavDestination 子页面组件（继承自原实现，P0 微调样式常量） ============

// 个人中心页
@Component
struct ProfilePage {
  @Prop username: string = '用户';
  @Prop userId: string = '';
  @Prop major: string = '';
  pathStack: NavPathStack = new NavPathStack();
  @State isDarkMode: boolean = false;
  @State fontSizeIndex: number = 1;
  @State cacheSize: string = '64.2MB';

  private functionList: FunctionItemData[] = [
    { name: '学籍卡包', icon: '学' },
    { name: '2026春季校历', icon: '历' },
    { name: '我的成绩单', icon: '绩' },
    { name: '隐私与安全', icon: '安' },
    { name: '帮助与反馈', icon: '帮' },
    { name: '通用设置', icon: '设' }
  ];

  build() {
    NavDestination() {
      Column() {
        // 导航栏
        Row() {
          Image($r('app.media.ic_back'))
            .width(24).height(24).fillColor('#1D2129')
            .onClick(() => { this.pathStack.pop(); })
          Blank()
          Text('我的').fontSize(30).fontWeight(600).fontColor('#1D2129')
          Blank()
          Text('设置').fontSize(24).fontColor('#1677FF')
            .onClick(() => {
              this.pathStack.pushPath({ name: NAV_SETTING, param: { type: 'setting' } as PageTypeParam });
            })
        }
        .width('100%').height(56).padding({ left: 20, right: 20 })
        .backgroundColor('#FFFFFF').alignItems(VerticalAlign.Center)

        // 内容区域
        Scroll() {
          Column({ space: 16 }) {
            // 个人信息卡片
            Row({ space: 16 }) {
              Stack() {
                Circle().width(60).height(60).fill('#E8F3FF')
                Text(this.username.charAt(0)).fontSize(24).fontColor('#1677FF')
              }
              Column({ space: 4 }) {
                Text(this.username)
                  .fontSize(28)
                  .fontWeight(700)
                  .fontColor('#1D2129')
                Text(`${this.major} - 2024级`)
                  .fontSize(24)
                  .fontColor('#86909C')
                Row() {
                  Text('学号: ')
                    .fontSize(24)
                    .fontColor('#86909C')
                  Text(this.userId)
                    .fontSize(24)
                    .fontColor('#1677FF')
                }
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding(20)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)

            // 功能列表
            Column() {
              ForEach(this.functionList, (item: FunctionItemData) => {
                Row() {
                  Text(item.icon)
                    .fontSize(24)
                    .fontColor('#86909C')
                    .width(32)
                    .textAlign(TextAlign.Center)

                  Text(item.name)
                    .fontSize(26)
                    .fontColor('#1D2129')
                    .margin({ left: 12 })
                    .layoutWeight(1)

                  Text('>')
                    .fontSize(24)
                    .fontColor('#86909C')
                }
                .width('100%')
                .height(48)
                .padding({ left: 16, right: 16 })
                .alignItems(VerticalAlign.Center)
                .onClick(() => {
                  if (item.name === '帮助与反馈') {
                    this.pathStack.pushPath({ name: NAV_HELP, param: { type: 'help' } as PageTypeParam });
                  }
                })
              })
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(8)

            // 版本信息
            Text('高校校园助手 V1.0.0')
              .fontSize(22)
              .fontColor('#86909C')
              .margin({ top: 16, bottom: 30 })
          }
          .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
      .width('100%').height('100%').backgroundColor(AppStorage.Get('isDarkMode') as boolean ? '#1A1A2E' : '#F5F7FA')
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
}

// 设置/帮助页
@Component
struct SettingPage {
  @Prop pageType: string = 'setting';
  pathStack: NavPathStack = new NavPathStack();
  @StorageLink('isDarkMode') isDarkMode: boolean = false;
  @State fontSize: number = DEFAULT_FONT_SIZE;
  private context: Context = getContext(this) as Context;

  async aboutToAppear() {
    if (this.pageType === 'setting') {
      this.fontSize = await KVStoreUtil.getFontSize(this.context);
      AppStorage.Set('fontScale', this.fontSize / DEFAULT_FONT_SIZE);
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 导航栏（响应深色模式）
        Row() {
          Image($r('app.media.ic_back'))
            .width(24).height(24).fillColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
            .onClick(() => { this.pathStack.pop(); })
          Blank()
          Text(this.pageType === 'setting' ? '设置' : '帮助中心')
            .fontSize(30).fontWeight(600).fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
          Blank()
          Row().width(24)
        }
        .width('100%').height(56).padding({ left: 20, right: 20 })
        .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF').alignItems(VerticalAlign.Center)

        Column({ space: 16 }) {
          if (this.pageType === 'setting') {
            this.buildSettingContent();
          } else {
            this.buildHelpContent();
          }
        }
        .padding(16)
        .layoutWeight(1)
      }
      .width('100%').height('100%').backgroundColor(this.isDarkMode ? '#1A1A2E' : '#F5F7FA')
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }

  @Builder
  buildSettingContent() {
    Column({ space: 16 }) {
      Text('通用设置')
        .fontSize(32).fontWeight(700).fontColor($r('app.color.primary'))

      Column({ space: 16 }) {
        // 主题模式选择
        Column({ space: 12 }) {
          Text('主题模式').fontSize(26).fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
          Row({ space: 12 }) {
            Button('浅色')
              .layoutWeight(1)
              .height(40)
              .fontColor(!this.isDarkMode ? '#FFFFFF' : '#1677FF')
              .backgroundColor(!this.isDarkMode ? '#1677FF' : '#3A3A5C')
              .borderRadius(20)
              .onClick(() => {
                AppStorage.Set('isDarkMode', false);
                KVStoreUtil.setThemeMode(this.context, 'light');
              })
            Button('深色')
              .layoutWeight(1)
              .height(40)
              .fontColor(this.isDarkMode ? '#FFFFFF' : '#1677FF')
              .backgroundColor(this.isDarkMode ? '#1677FF' : '#3A3A5C')
              .borderRadius(20)
              .onClick(() => {
                AppStorage.Set('isDarkMode', true);
                KVStoreUtil.setThemeMode(this.context, 'dark');
              })
          }
          .width('100%')
        }

        Divider().color(this.isDarkMode ? '#3A3A5C' : '#E5E6EB')

        // 字体大小
        Column({ space: 12 }) {
          Text('字体大小：' + this.fontSize.toString()).fontSize(26).fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
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
              this.fontSize = Math.round(value);
              KVStoreUtil.setFontSize(this.context, this.fontSize);
              AppStorage.Set('fontScale', this.fontSize / DEFAULT_FONT_SIZE);
            })
        }

        Divider().color(this.isDarkMode ? '#3A3A5C' : '#E5E6EB')

        // 关于我们
        Row() {
          Text('关于我们').fontSize(26).fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129').layoutWeight(1)
          Text('>').fontSize(24).fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
        }
        .width('100%').height(48).padding({ left: 16, right: 16 })
        .alignItems(VerticalAlign.Center)
      }
      .width('100%').padding(16).backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF').borderRadius(8)
    }
    .width('100%')
  }

  @Builder
  buildHelpContent() {
    Column({ space: 16 }) {
      Text('帮助中心').fontSize(32).fontWeight(700).fontColor($r('app.color.primary'))
      this.buildHelpItem('1. 如何查看课程表？', '点击「学习助手」Tab → 课程表标签，支持左右切换周次查看。')
      this.buildHelpItem('2. 怎么发布失物招领？', '点击「生活服务」Tab → 失物招领 → 右上发布信息按钮。')
      this.buildHelpItem('3. 如何切换深色模式？', '我的 → 设置 → 主题模式，可选择浅色/深色。')
      this.buildHelpItem('4. 数据会丢失吗？', '所有数据存储在本地，卸载APP会清除数据，请提前备份。')
    }
    .width('100%')
  }

  @Builder
  buildHelpItem(question: string, answer: string) {
    Column({ space: 8 }) {
      Text(question).fontSize(26).fontWeight(600).fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
      Text(answer).fontSize(24).fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C').lineHeight(22)
    }
    .width('100%').padding(16).backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF').borderRadius(8)
    .alignItems(HorizontalAlign.Start)
  }
}

interface FunctionItemData {
  name: string;
  icon: string;
}

interface PageTypeParam {
  type: string;
}
