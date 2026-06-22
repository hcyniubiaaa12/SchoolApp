// Index.ets - 首页（MainAbility内）
import { common, Want } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import { KVStoreUtil } from '../common/utils/KVStoreUtil';
import {
  DEFAULT_FONT_SIZE,
  DEFAULT_THEME_MODE,
  MAX_FONT_SIZE,
  MIN_FONT_SIZE
} from '../common/constants/StorageKeys';

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
  // 默认加载第三个导航标签（索引2，"消息"页）
  @State currentTab: number = 2;
  @State swiperIndex: number = 0;

  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  // 功能快捷入口数据（2行4列=8个）
  private quickEntries: QuickEntryData[] = [
    { name: '我的课表', icon: '课', color: '#007DFF' },
    { name: '食堂人流', icon: '食', color: '#52C41A' },
    { name: '空教室', icon: '教', color: '#FF7D00' },
    { name: LAB_ENTRY_NAME, icon: '存', color: '#722ED1' },
    { name: '校园卡', icon: '卡', color: '#007DFF' },
    { name: '成绩查询', icon: '成', color: '#F53F3F' },
    { name: '社团相册', icon: '社', color: '#52C41A' },
    { name: BG_TASK_ENTRY_NAME, icon: '后', color: '#13C2C2' }
  ];

  // 底部Tab数据
  private tabs: TabData[] = [
    { name: '首页', icon: '首' },
    { name: '课程', icon: '课' },
    { name: '消息', icon: '消' },
    { name: '工具', icon: '工' },
    { name: '我的', icon: '我' }
  ];

  // 校园公告模拟数据
  private announcements: AnnouncementData[] = [
    { title: '关于2026年春季学期期末考试安排的通知', time: '2026-04-28', content: '各学院、各位同学：2026年春季学期期末考试将于...' },
    { title: '图书馆开放时间调整通知', time: '2026-04-25', content: '因设施维护，图书馆开放时间调整为8:00-22:00...' },
    { title: '校园运动会报名通知', time: '2026-04-22', content: '第十二届校园运动会将于5月15日举行...' }
  ];

  aboutToAppear() {
    // 从AppStorage获取MainAbility传入的参数
    console.log('>>> [Index] aboutToAppear 被调用');
    const storedUserId: string = AppStorage.get('userId') ?? '';
    const storedUsername: string = AppStorage.get('username') ?? '';
    console.log('>>> [Index] 从AppStorage读取 - userId: ' + storedUserId + ', username: ' + storedUsername);
    if (storedUserId) { this.userId = storedUserId; }
    if (storedUsername) { this.username = storedUsername; }
    console.log('>>> [Index] 页面显示 - userId: ' + this.userId + ', username: ' + this.username);
  }

  // 跳转到ProfileAbility（Ability级别跳转）
  private navigateToProfile(): void {
    promptAction.showToast({ message: '正在跳转ProfileAbility...' });
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
        console.log('===== userId: ' + this.userId + ' =====');
      })
      .catch((err: Error) => {
        console.error('===== [Index] startAbility to ProfileAbility 失败: ' + err.message + ' =====');
      });
  }

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

  build() {
    Navigation(this.navPathStack) {
      Column() {
        if (this.currentTab === 0) {
          Scroll() {
            Column({ space: 16 }) {
              this.buildNavBar();
              this.buildSearchBar();
              this.buildSwiperBanner();
              this.buildQuickEntries();
              this.buildTodayCourseCard();
            }
            .padding({ left: 16, right: 16, bottom: 16 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Auto)
        } else if (this.currentTab === 1) {
          this.buildTabPage('课程', '课程表、成绩查询、学习资料');
        } else if (this.currentTab === 2) {
          this.buildTabPage('消息', '校园动态、社团活动、互动社区');
        } else if (this.currentTab === 3) {
          this.buildTabPage('工具', '校园集市、校园工具、生活服务');
        }

        // 底部Tab导航栏
        this.buildTabBar();
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .navDestination(this.buildNavDestination)
    .mode(NavigationMode.Auto)
    .hideTitleBar(true)
    .hideToolBar(true)
    .navBarWidth('100%')
  }

  // NavDestination 构建器
  @Builder
  buildNavDestination(name: string, param: Object) {
    if (name === NAV_PROFILE) {
      ProfilePage({
        username: (param as Record<string, string>)['username'] ?? '用户',
        userId: (param as Record<string, string>)['userId'] ?? '',
        major: (param as Record<string, string>)['major'] ?? '',
        pathStack: this.navPathStack
      })
    } else if (name === NAV_SETTING) {
      SettingPage({ pageType: 'setting', pathStack: this.navPathStack })
    } else if (name === NAV_HELP) {
      SettingPage({ pageType: 'help', pathStack: this.navPathStack })
    }
  }

  // 顶部导航栏 - 个性化问候 + 铃铛图标
  @Builder
  buildNavBar() {
    Row() {
      Column({ space: 4 }) {
        Text(`你好，${this.username}`)
          .fontSize(24)
          .fontWeight(600)
          .fontColor('#333333')
        Text('今天也要加油哦')
          .fontSize(14)
          .fontColor('#999999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 铃铛图标
      Stack() {
        Text('🔔')
          .fontSize(24)
        // 红点
        Circle()
          .width(8)
          .height(8)
          .fill('#FF4D4F')
          .position({ x: 18, y: 0 })
      }
      .width(36)
      .height(36)
      .alignContent(Alignment.Center)
    }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 20 })
    .alignItems(VerticalAlign.Center)
  }

  // 搜索栏 - 灰色圆角背景
  @Builder
  buildSearchBar() {
    Row() {
      Text('🔍')
        .fontSize(16)
        .margin({ right: 8 })
      Text('搜索课程、讲座或校园动态…')
        .fontSize(14)
        .fontColor('#999999')
        .layoutWeight(1)
    }
    .width('100%')
    .height(44)
    .padding({ left: 16, right: 16 })
    .borderRadius(8)
    .backgroundColor('#F5F5F5')
    .alignItems(VerticalAlign.Center)
  }

  // 轮播图
  @Builder
  buildSwiperBanner() {
    Stack() {
      Swiper() {
        // 轮播图1
        Stack() {
          Column()
            .width('100%')
            .height('100%')
            .borderRadius(8)
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [['#4A90E2', 0], ['#6A5ACD', 1]]
            })
          Column({ space: 8 }) {
            Text('2026春季学术周启幕')
              .fontSize(18)
              .fontWeight(700)
              .fontColor('#FFFFFF')
            Text('精彩讲座即将开启')
              .fontSize(12)
              .fontColor('#FFFFFFCC')
          }
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 20 })
        }
        .width('100%')
        .height(120)

        // 轮播图2
        Stack() {
          Column()
            .width('100%')
            .height('100%')
            .borderRadius(8)
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [['#52C41A', 0], ['#00B42A', 1]]
            })
          Column({ space: 8 }) {
            Text('校园马拉松报名')
              .fontSize(18)
              .fontWeight(700)
              .fontColor('#FFFFFF')
            Text('4月15日开跑')
              .fontSize(12)
              .fontColor('#FFFFFFCC')
          }
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 20 })
        }
        .width('100%')
        .height(120)
      }
      .autoPlay(true)
      .interval(3000)
      .loop(true)
      .indicator(false)
      .onChange((index: number) => {
        this.swiperIndex = index;
      })

      // 指示器
      Row({ space: 6 }) {
        Circle()
          .width(6)
          .height(6)
          .fill(this.swiperIndex === 0 ? '#FFFFFF' : '#FFFFFF66')
        Circle()
          .width(6)
          .height(6)
          .fill(this.swiperIndex === 1 ? '#FFFFFF' : '#FFFFFF66')
      }
      .position({ x: '50%', y: 100 })
      .translate({ x: '-50%' })
    }
    .width('100%')
    .height(130)
  }

  // 功能快捷入口（2行4列）
  @Builder
  buildQuickEntries() {
    Column() {
      ForEach([0, 1], (rowIndex: number) => {
        Row() {
          ForEach([0, 1, 2, 3], (colIndex: number) => {
            Column({ space: 8 }) {
              Stack() {
                Circle().width(48).height(48)
                  .fill(this.quickEntries[rowIndex * 4 + colIndex].color + '1A')
                Text(this.quickEntries[rowIndex * 4 + colIndex].icon)
                  .fontSize(20)
                  .fontColor(this.quickEntries[rowIndex * 4 + colIndex].color)
              }
              Text(this.quickEntries[rowIndex * 4 + colIndex].name)
                .fontSize(14)
                .fontColor('#333333')
                .maxLines(1)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .padding({ top: 8, bottom: 8 })
            .onClick(() => {
              const entry = this.quickEntries[rowIndex * 4 + colIndex];
              if (entry.name === LAB_ENTRY_NAME) {
                this.navigateToDataStorageLab();
              } else if (entry.name === BG_TASK_ENTRY_NAME) {
                this.navigateToBackgroundTaskLab();
              }
            })
          })
        }
        .width('100%')
      })
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  // 今日课程卡片
  @Builder
  buildTodayCourseCard() {
    Column() {
      Row() {
        Text('今日课程（2）')
          .fontSize(18)
          .fontWeight(600)
          .fontColor('#333333')
        Blank()
        Text('完整课程')
          .fontSize(12)
          .fontColor('#007DFF')
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 课程1
      Row() {
        Text('10:00')
          .fontSize(12)
          .fontColor('#666666')
          .width(50)
          .textAlign(TextAlign.Center)

        Column() {
          Circle().width(8).height(8).fill('#007DFF')
          Row().width(2).height(30).backgroundColor('#E5E6EB')
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ left: 8, right: 12 })

        Column({ space: 4 }) {
          Text('高级人工智能')
            .fontSize(16)
            .fontWeight(500)
            .fontColor('#333333')
          Text('信软楼302（数字多媒体教室）')
            .fontSize(12)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('必修')
          .fontSize(12)
          .fontColor('#007DFF')
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(4)
          .backgroundColor('#E6F7FF')
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .padding({ top: 8, bottom: 8 })

      // 课程2
      Row() {
        Text('14:00')
          .fontSize(12)
          .fontColor('#666666')
          .width(50)
          .textAlign(TextAlign.Center)

        Column() {
          Circle().width(8).height(8).fill('#52C41A')
          Row().width(2).height(30).backgroundColor('#E5E6EB')
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ left: 8, right: 12 })

        Column({ space: 4 }) {
          Text('创业管理学')
            .fontSize(16)
            .fontWeight(500)
            .fontColor('#333333')
          Text('公教楼508')
            .fontSize(12)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('选修')
          .fontSize(12)
          .fontColor('#00AA00')
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(4)
          .backgroundColor('#E6FFE6')
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .padding({ top: 8, bottom: 8 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  // Tab页面占位内容
  @Builder
  buildTabPage(title: string, desc: string) {
    Column() {
      Row() {
        Text(title).fontSize(18).fontWeight(600).fontColor('#333333')
          .width('100%').textAlign(TextAlign.Center)
      }
      .width('100%').height(56).backgroundColor('#FFFFFF').padding({ left: 16, right: 16 })

      Column({ space: 24 }) {
        Stack() {
          Circle().width(120).height(120).fill('#E8F3FF')
          Text(title.charAt(0)).fontSize(48).fontColor('#007DFF')
        }
        Text(title).fontSize(24).fontWeight(700).fontColor('#007DFF')
        Text(desc).fontSize(14).fontColor('#999999').textAlign(TextAlign.Center)
          .padding({ left: 40, right: 40 })
        Text('功能开发中，敬请期待...').fontSize(14).fontColor('#999999').margin({ top: 16 })
      }
      .layoutWeight(1).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
    }
    .layoutWeight(1).backgroundColor('#F5F5F5')
  }

  // 底部Tab导航栏
  @Builder
  buildTabBar() {
    Row() {
      ForEach(this.tabs, (tab: TabData, index?: number) => {
        Column({ space: 4 }) {
          Text(tab.icon)
            .fontSize(16)
            .fontColor(this.currentTab === index ? '#007DFF' : '#999999')
          Text(tab.name)
            .fontSize(12)
            .fontColor(this.currentTab === index ? '#007DFF' : '#999999')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .padding({ top: 6, bottom: 6 })
        .onClick(() => {
          if (index !== undefined) {
            if (index === 4) {
              // 点击"我的"Tab，跳转到ProfileAbility（Ability级别跳转）
              this.navigateToProfile();
            } else {
              this.currentTab = index;
            }
          }
        })
      })
    }
    .width('100%')
    .height(56)
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 1 }, color: '#E0E0E0' })
    .alignItems(VerticalAlign.Center)
  }
}

// ============ NavDestination 子页面组件 ============

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
            .width(24).height(24).fillColor('#333333')
            .onClick(() => { this.pathStack.pop(); })
          Blank()
          Text('我的').fontSize(18).fontWeight(600).fontColor('#333333')
          Blank()
          Text('设置').fontSize(14).fontColor('#007DFF')
            .onClick(() => {
              this.pathStack.pushPath({ name: NAV_SETTING, param: { type: 'setting' } as PageTypeParam });
            })
        }
        .width('100%').height(56).padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF').alignItems(VerticalAlign.Center)

        // 内容区域
        Scroll() {
          Column({ space: 12 }) {
            // 个人信息卡片
            Row({ space: 16 }) {
              // 头像
              Stack() {
                Circle().width(60).height(60).fill('#E8F3FF')
                Text(this.username.charAt(0)).fontSize(24).fontColor('#007DFF')
              }

              Column({ space: 4 }) {
                Text(this.username)
                  .fontSize(18)
                  .fontWeight(700)
                  .fontColor('#333333')
                Text(`${this.major} - 2024级`)
                  .fontSize(14)
                  .fontColor('#666666')
                Row() {
                  Text('学号: ')
                    .fontSize(14)
                    .fontColor('#666666')
                  Text(this.userId)
                    .fontSize(14)
                    .fontColor('#007DFF')
                }
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding(20)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .alignItems(VerticalAlign.Center)

            // 数据统计行
            Row() {
              Column({ space: 4 }) {
                Text('12')
                  .fontSize(20)
                  .fontWeight(700)
                  .fontColor('#333333')
                Text('我的发布')
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)

              Column({ space: 4 }) {
                Text('45')
                  .fontSize(20)
                  .fontWeight(700)
                  .fontColor('#333333')
                Text('我的收藏')
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)

              Column({ space: 4 }) {
                Text('128')
                  .fontSize(20)
                  .fontWeight(700)
                  .fontColor('#333333')
                Text('积分')
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')
            .padding({ top: 16, bottom: 16 })
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .justifyContent(FlexAlign.SpaceAround)

            // 功能列表
            Column() {
              ForEach(this.functionList, (item: FunctionItemData) => {
                Row() {
                  Text(item.icon)
                    .fontSize(16)
                    .fontColor('#999999')
                    .width(24)
                    .textAlign(TextAlign.Center)

                  Text(item.name)
                    .fontSize(16)
                    .fontColor('#333333')
                    .margin({ left: 12 })
                    .layoutWeight(1)

                  Text('>')
                    .fontSize(14)
                    .fontColor('#999999')
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
            .borderRadius(12)

            // 版本信息
            Text('校通Plus Version 4.2.0 (Build 20260401)')
              .fontSize(10)
              .fontColor('#CCCCCC')
              .margin({ top: 16, bottom: 30 })
          }
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
      .width('100%').height('100%').backgroundColor('#F5F5F5')
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
  @State themeMode: string = DEFAULT_THEME_MODE;
  @State fontSize: number = DEFAULT_FONT_SIZE;
  private context: Context = getContext(this) as Context;

  async aboutToAppear() {
    if (this.pageType === 'setting') {
      this.themeMode = await KVStoreUtil.getThemeMode(this.context);
      this.fontSize = await KVStoreUtil.getFontSize(this.context);
    }
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Image($r('app.media.ic_back'))
            .width(24).height(24).fillColor('#333333')
            .onClick(() => { this.pathStack.pop(); })
          Blank()
          Text(this.pageType === 'setting' ? '设置' : '帮助中心')
            .fontSize(18).fontWeight(600).fontColor('#333333')
          Blank()
          Row().width(24)
        }
        .width('100%').height(56).padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF').alignItems(VerticalAlign.Center)

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
      .width('100%').height('100%').backgroundColor('#F5F5F5')
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
        .fontSize(20).fontWeight(700).fontColor('#007DFF')

      Column({ space: 16 }) {
        Column({ space: 12 }) {
          Text('主题模式').fontSize(16).fontColor('#333333')
          Row({ space: 12 }) {
            Button('浅色')
              .layoutWeight(1)
              .height(40)
              .fontColor(this.themeMode === 'light' ? '#FFFFFF' : '#007DFF')
              .backgroundColor(this.themeMode === 'light' ? '#007DFF' : '#EAF3FF')
              .borderRadius(20)
              .onClick(() => {
                this.themeMode = 'light';
                KVStoreUtil.setThemeMode(this.context, 'light');
              })
            Button('深色')
              .layoutWeight(1)
              .height(40)
              .fontColor(this.themeMode === 'dark' ? '#FFFFFF' : '#007DFF')
              .backgroundColor(this.themeMode === 'dark' ? '#007DFF' : '#EAF3FF')
              .borderRadius(20)
              .onClick(() => {
                this.themeMode = 'dark';
                KVStoreUtil.setThemeMode(this.context, 'dark');
              })
          }
          .width('100%')
        }

        Divider().color('#E5E6EB')

        Column({ space: 12 }) {
          Text(`字体大小：${this.fontSize}`).fontSize(16).fontColor('#333333')
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
            })
        }

        Divider().color('#E5E6EB')

        Row() {
          Text('关于我们').fontSize(16).fontColor('#333333').layoutWeight(1)
          Text('>').fontSize(14).fontColor('#999999')
        }
        .width('100%').height(48).alignItems(VerticalAlign.Center)
      }
      .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(12)
    }
  }

  @Builder
  buildHelpContent() {
    Column({ space: 16 }) {
      Text('帮助中心')
        .fontSize(20).fontWeight(700).fontColor('#007DFF')

      Column({ space: 12 }) {
        this.buildHelpItem('如何修改个人信息？', '进入"我的"页面，点击头像区域即可编辑个人信息。')
        this.buildHelpItem('如何查看课程表？', '在首页点击"课程表"快捷入口，或切换到"学习助手"Tab查看。')
        this.buildHelpItem('忘记密码怎么办？', '在登录页点击"忘记密码"，通过手机验证码重置密码。')
        this.buildHelpItem('如何联系客服？', '您可以通过"意见反馈"功能提交问题，我们会尽快回复。')
      }
    }
  }

  @Builder
  buildHelpItem(question: string, answer: string) {
    Column({ space: 8 }) {
      Text(question).fontSize(16).fontWeight(600).fontColor('#333333')
      Text(answer).fontSize(14).fontColor('#999999').lineHeight(22)
    }
    .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }
}

// ============ 数据类型定义 ============

interface QuickEntryData {
  name: string;
  icon: string;
  color: string;
}

interface TabData {
  name: string;
  icon: string;
}

interface AnnouncementData {
  title: string;
  time: string;
  content: string;
}

interface FunctionItemData {
  name: string;
  icon: string;
}

interface ProfileParam {
  username: string;
  userId: string;
  major: string;
  avatar: string;
}

interface PageTypeParam {
  type: string;
}
