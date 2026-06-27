// Guide.ets - 引导页（StartAbility内，首次打开APP显示）
// 三页主题：校园信息 | 学习助手 | 生活服务
// 功能：左右滑动切换、指示器点击跳转、第3页"立即进入"→登录、第1页侧滑返回启动页
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct Guide {
  @State currentIndex: number = 0;
  private readonly totalPages: number = 3;
  private swiperController: SwiperController = new SwiperController();
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  // 三页主题内容（按规范 - 每页不同图标和配色）
  private guidePages: GuidePageItemData[] = [
    {
      icon: $r('sys.symbol.bell'),
      circleColor: $r('app.color.primary_light'),
      iconColor: [$r('app.color.primary')],
      title: '校园信息，实时掌握',
      desc: '校园公告、资讯、地图，一手了解校园动态。'
    },
    {
      icon: $r('sys.symbol.book'),
      circleColor: '#FFF3E0',
      iconColor: [$r('app.color.warm_orange')],
      title: '学习助手，高效备考',
      desc: '课程表、成绩查询、图书馆检索，学业好帮手。'
    },
    {
      icon: $r('sys.symbol.heart_fill'),
      circleColor: '#E6FFE6',
      iconColor: [$r('app.color.fresh_green')],
      title: '生活服务，贴心相伴',
      desc: '失物招领、校园美食、音乐播放，丰富校园生活。'
    }
  ];

  // 第1页侧滑返回启动页（系统返回键/手势）
  onBackPress(): boolean {
    if (this.currentIndex === 0) {
      this.navigateToStart();
      return true; // 消费返回事件
    }
    return false; // 非第1页交给系统处理
  }

  // 跳转到启动页
  private navigateToStart(): void {
    this.context.eventHub.emit('navigateToStart');
  }

  // 跳转到登录页（Ability内页面跳转）
  private navigateToLogin(): void {
    this.context.eventHub.emit('navigateToLogin');
  }

  build() {
    Column() {
      // Swiper 滑动区域（淡入淡出过渡动画）
      Swiper(this.swiperController) {
        ForEach(this.guidePages, (page: GuidePageItemData, index?: number) => {
          this.buildGuidePageItem(page);
        }, (page: GuidePageItemData, index?: number) => page.title + (index ?? 0).toString())
      }
      .index(this.currentIndex)
      .loop(false)
      .indicator(false)
      .curve(Curve.EaseInOut)  // 平滑过渡曲线
      .duration(350)           // 过渡时长350ms
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .width('100%')
      .layoutWeight(1)

      // 页码指示器（可点击快速跳转）
      Row({ space: 8 }) {
        ForEach([0, 1, 2] as number[], (item: number) => {
          Circle()
            .width(8)
            .height(8)
            .fill(this.currentIndex === item ? $r('app.color.primary') : $r('app.color.border'))
            .onClick(() => {
              this.currentIndex = item;
            })
        }, (item: number) => item.toString())
      }
      .margin({ top: 16, bottom: 16 })

      // 按钮区域：第3页显示"立即进入"，其他页显示"下一步"和"跳过"
      if (this.currentIndex === this.totalPages - 1) {
        Column({ space: 16 }) {
          Button('立即进入')
            .width('80%')
            .height(48)
            .fontSize(26)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.card_white'))
            .backgroundColor($r('app.color.primary'))
            .borderRadius(8) // 规范：圆角8px
            .onClick(() => {
              this.navigateToLogin();
            })
        }
        .margin({ bottom: 40 })
        .alignItems(HorizontalAlign.Center)
      } else {
        Column({ space: 16 }) {
          Button('下一步 →')
            .width('80%')
            .height(48)
            .fontSize(26)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.card_white'))
            .backgroundColor($r('app.color.primary'))
            .borderRadius(8) // 规范：圆角8px
            .onClick(() => {
              this.currentIndex += 1;
              this.swiperController.showNext();
            })

          Text('跳过介绍')
            .fontSize(22)
            .fontColor($r('app.color.text_secondary'))
            .onClick(() => {
              this.navigateToLogin();
            })
        }
        .margin({ bottom: 40 })
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }

  // 构建单页引导页Item（彩色圆形背板 + SymbolGlyph 图标 + 标题 + 描述）
  @Builder
  buildGuidePageItem(page: GuidePageItemData) {
    Column() {
      // 引导图（彩色圆形背景 + 每页不同的系统符号图标）
      Stack() {
        Circle()
          .width(220)
          .height(220)
          .fill(page.circleColor ?? $r('app.color.primary_light'))

        SymbolGlyph(page.icon)
          .fontSize(100)
          .fontColor(page.iconColor ?? [$r('app.color.primary')])
      }
      .margin({ top: 120 })

      // 标题 - 32sp 鸿蒙蓝 700
      Text(page.title)
        .fontSize(32)
        .fontWeight(700)
        .fontColor($r('app.color.primary'))
        .textAlign(TextAlign.Center)
        .margin({ top: 48 })

      // 描述 - 26sp 主色，行高1.5倍(39)
      Text(page.desc)
        .fontSize(26)
        .fontColor($r('app.color.text_primary'))
        .textAlign(TextAlign.Center)
        .lineHeight(39)
        .maxLines(2)
        .margin({ top: 16 })
        .padding({ left: 40, right: 40 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}

// 引导页数据类型
interface GuidePageItemData {
  icon: Resource;
  circleColor?: ResourceColor;
  iconColor?: ResourceColor[];
  title: string;
  desc: string;
}
