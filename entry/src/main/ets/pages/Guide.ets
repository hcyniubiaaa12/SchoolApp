// Guide.ets - 引导页（StartAbility内，首次打开APP显示）
import { common, Want } from '@kit.AbilityKit';

@Entry
@Component
struct Guide {
  @State currentIndex: number = 0;
  private readonly totalPages: number = 3;
  private swiperController: SwiperController = new SwiperController();
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  // 三页主题内容
  private guidePages: GuidePageItemData[] = [
    {
      icon: $r('app.media.ic_book'),
      title: '学在云端',
      desc: '课表管理、成绩查询、空教室预约，你的学习生活助手。'
    },
    {
      icon: $r('app.media.ic_book'),
      title: '校园信息，实时掌握',
      desc: '校园公告、资讯、地图，一手了解校园动态。'
    },
    {
      icon: $r('app.media.ic_book'),
      title: '生活服务，贴心相伴',
      desc: '失物招领、校园美食、音乐播放，丰富校园生活。'
    }
  ];

  aboutToAppear() {
  }

  // 跳转到登录页（Ability内页面跳转）
  private navigateToLogin(): void {
    // 引导页到登录页属于同一个StartAbility内的页面跳转
    // 使用AbilityContext的eventHub通知Ability进行页面加载
    this.context.eventHub.emit('navigateToLogin');
  }

  build() {
    Column() {
      // Swiper 滑动区域
      Swiper(this.swiperController) {
        ForEach(this.guidePages, (page: GuidePageItemData, index?: number) => {
          this.buildGuidePageItem(page);
        })
      }
      .index(this.currentIndex)
      .loop(false)
      .indicator(false)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .width('100%')
      .layoutWeight(1)

      // 页码指示器
      Row({ space: 8 }) {
        ForEach([0, 1, 2], (item: number) => {
          Circle()
            .width(8)
            .height(8)
            .fill(this.currentIndex === item ? '#1677FF' : '#E5E6EB')
        })
      }
      .margin({ top: 16, bottom: 16 })

      // 按钮区域：第3页显示"立即进入"，其他显示"下一步"
      if (this.currentIndex === this.totalPages - 1) {
        Column({ space: 16 }) {
          Button('立即进入')
            .width('80%')
            .height(48)
            .fontSize(26)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(24)
            .onClick(() => {
              this.navigateToLogin();
            })
        }
        .margin({ bottom: 40 })
        .alignItems(HorizontalAlign.Center)
      } else {
        Column({ space: 16 }) {
          // "下一步"按钮
          Button('下一步 →')
            .width('80%')
            .height(48)
            .fontSize(26)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(24)
            .onClick(() => {
              this.currentIndex += 1;
              this.swiperController.showNext();
            })

          // "跳过介绍"在按钮正下方居中
          Text('跳过介绍')
            .fontSize(22)
            .fontColor('#86909C')
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
    .backgroundColor('#FFFFFF')
  }

  // 构建单页引导页Item
  @Builder
  buildGuidePageItem(page: GuidePageItemData) {
    Column() {
      // 引导图（浅蓝色圆形背景+书本图标）
      Stack() {
        Circle()
          .width(220)
          .height(220)
          .fill('#E8F3FF')

        Image(page.icon)
          .width(100)
          .height(100)
          .objectFit(ImageFit.Contain)
          .fillColor('#1677FF')
      }
      .margin({ top: 120 })

      // 标题 - 深黑粗体
      Text(page.title)
        .fontSize(32)
        .fontWeight(700)
        .fontColor('#1D2129')
        .textAlign(TextAlign.Center)
        .margin({ top: 48 })

      // 描述 - 浅灰色
      Text(page.desc)
        .fontSize(24)
        .fontColor('#86909C')
        .textAlign(TextAlign.Center)
        .lineHeight(36)
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
  title: string;
  desc: string;
}
