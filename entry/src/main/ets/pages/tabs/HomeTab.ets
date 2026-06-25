// HomeTab.ets - 首页 Tab 内容（P0 首页重做）
// 搜索栏 + 九宫格 9 入口 + 公告卡片 + 今日课程卡片 + 天气卡片

// 快捷入口数据
export interface QuickEntryItem {
  name: string;
  icon: string;
  image?: Resource;
  color: string;
  targetPage?: string;
}

// 公告数据类型（命名接口，替代对象字面量类型）
interface AnnouncementItem {
  title: string;
  time: string;
  content: string;
}

@Component
export struct HomeTab {
  @Prop @Watch('onDarkChange') isDarkMode: boolean = false;
  @State darkPrimary: string = '#1D2129';
  @State darkSecondary: string = '#86909C';

  private onDarkChange(): void {
    this.darkPrimary = this.isDarkMode ? '#E8E8E8' : '#1D2129';
    this.darkSecondary = this.isDarkMode ? '#A0A0A0' : '#86909C';
  }
  @Prop username: string = '用户';
  @Prop swiperIndex: number = 0;
  onSearchClick?: () => void;
  onMessageClick?: () => void;
  onWeatherClick?: () => void;
  onQuickEntryClick?: (entry: QuickEntryItem) => void;
  onTabChange?: (index: number) => void;

  // 九宫格 9 入口（3×3）
  private quickEntries: QuickEntryItem[] = [
    { name: '校园公告', icon: '📢', color: '#1677FF' },
    { name: '课程表', icon: '📅', color: '#FF7D00' },
    { name: '成绩查询', icon: '📊', color: '#00B42A' },
    { name: '失物招领', icon: '🔍', color: '#FF7D00' },
    { name: '校园地图', icon: '🗺️', color: '#1677FF' },
    { name: '图书馆', icon: '', image: $r('app.media.ic_book'), color: '#00B42A' },
    { name: '校园美食', icon: '🍽️', color: '#FF7D00' },
    { name: '音乐播放', icon: '🎵', color: '#1677FF' },
    { name: '待办提醒', icon: '📝', color: '#00B42A' }
  ];

  // 模拟公告数据（使用命名接口）

  private announcements: AnnouncementItem[] = [
    { title: '关于2026年春季学期期末考试安排的通知', time: '2026-04-28', content: '各学院、各位同学：2026年春季学期期末考试将于...' },
    { title: '图书馆开放时间调整通知', time: '2026-04-25', content: '因设施维护，图书馆开放时间调整为8:00-22:00...' },
    { title: '校园运动会报名通知', time: '2026-04-22', content: '第十二届校园运动会将于5月15日举行...' }
  ];

  // builder 中有 const 声明不被允许，改为辅助方法获取快捷入口数据
  private getEntryName(index: number): string {
    return this.quickEntries[index].name;
  }

  private getEntryIcon(index: number): string {
    return this.quickEntries[index].icon;
  }

  private getEntryColor(index: number): string {
    return this.quickEntries[index].color;
  }

  private getEntryImage(index: number): Resource | undefined {
    return this.quickEntries[index].image;
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        // 1. 导航栏（规范：标题「校园助手」30sp 鸿蒙蓝 600 + 右侧消息铃铛）
        Row() {
          Text('校园助手')
            .fontSize(30)
            .fontWeight(600)
            .fontColor('#1677FF')
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          // 铃铛图标 + 红点
          Stack() {
            Text('🔔')
              .fontSize(24)
            Circle()
              .width(8)
              .height(8)
              .fill('#FF7D00')
              .position({ x: 18, y: 0 })
          }
          .width(36)
          .height(36)
          .onClick(() => {
            if (this.onMessageClick) {
              this.onMessageClick();
            }
          })
        }
        .width('100%')
        .height(56)
        .padding({ left: 20, right: 20 })
        .alignItems(VerticalAlign.Center)

        // 2. 搜索栏
        Row() {
          Text('🔍')
            .fontSize(24)
            .margin({ right: 8 })
          Text('搜索校园信息/课程/美食')
            .fontSize(24)
            .fontColor(this.darkSecondary)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text('🎤')
            .fontSize(22)
            .margin({ left: 8 })
        }
        .width('100%')
        .height(44)
        .padding({ left: 16, right: 16 })
        .borderRadius(24)
        .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          if (this.onSearchClick) {
            this.onSearchClick();
          }
        })

        // 3. 轮播 Banner
        Stack() {
          Swiper() {
            Stack() {
              Column()
                .width('100%')
                .height('100%')
                .borderRadius(8)
                .linearGradient({
                  direction: GradientDirection.Right,
                  colors: [['#1677FF', 0], ['#4096FF', 1]]
                })
              Column({ space: 8 }) {
                Text('2026春季学术周启幕')
                  .fontSize(28)
                  .fontWeight(700)
                  .fontColor('#FFFFFF')
                Text('精彩讲座即将开启')
                  .fontSize(24)
                  .fontColor('#FFFFFFCC')
              }
              .alignItems(HorizontalAlign.Start)
              .padding({ left: 20 })
            }
            .width('100%')
            .height(120)

            Stack() {
              Column()
                .width('100%')
                .height('100%')
                .borderRadius(8)
                .linearGradient({
                  direction: GradientDirection.Right,
                  colors: [['#FF7D00', 0], ['#FFA940', 1]]
                })
              Column({ space: 8 }) {
                Text('校园运动会报名')
                  .fontSize(28)
                  .fontWeight(700)
                  .fontColor('#FFFFFF')
                Text('5月15日开赛')
                  .fontSize(24)
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
        }
        .width('100%')
        .height(120)

        // 4. 九宫格快捷入口 — 3×3
        // 注：builder 内不能用 const，所以用辅助方法 + 直接数组索引
        Column() {
          ForEach([0, 1, 2] as number[], (rowIdx: number) => {
            Row() {
              ForEach([0, 1, 2] as number[], (colIdx: number) => {
                Column({ space: 8 }) {
                  Stack() {
                    Circle()
                      .width(64)
                      .height(64)
                      .fill(this.getEntryColor(rowIdx * 3 + colIdx) + '1A')
                    if (this.getEntryImage(rowIdx * 3 + colIdx)) {
                      Image(this.getEntryImage(rowIdx * 3 + colIdx)!)
                        .width(32)
                        .height(32)
                    } else {
                      Text(this.getEntryIcon(rowIdx * 3 + colIdx))
                        .fontSize(32)
                    }
                  }
                  Text(this.getEntryName(rowIdx * 3 + colIdx))
                    .fontSize(24)
                    .fontColor(this.darkPrimary)
                    .maxLines(1)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)
                .padding({ top: 8, bottom: 8 })
                .onClick(() => {
                  if (this.onQuickEntryClick) {
                    this.onQuickEntryClick(this.quickEntries[rowIdx * 3 + colIdx]);
                  }
                })
              }, (colIdx: number) => colIdx.toString())
            }
            .width('100%')
          }, (rowIdx: number) => rowIdx.toString())
        }
        .width('100%')
        .padding({ top: 12, bottom: 12 })
        .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')
        .borderRadius(8)
        .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })

        // 5. 校园公告卡片
        Column() {
          Row() {
            Text('校园公告')
              .fontSize(28)
              .fontWeight(600)
              .fontColor('#1677FF')
            Blank()
            Text('更多 >')
              .fontSize(24)
              .fontColor(this.darkSecondary)
          }
          .width('100%')
          .margin({ bottom: 12 })

          // 3 条公告：使用 Explicit interface + key generator
          ForEach(this.announcements, (item: AnnouncementItem, index: number) => {
            Column() {
              Row({ space: 8 }) {
                Row()
                  .width(3)
                  .height('100%')
                  .backgroundColor('#1677FF')
                  .borderRadius(2)

                Column({ space: 4 }) {
                  Text(item.title)
                    .fontSize(26)
                    .fontColor(this.darkPrimary)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(item.time)
                    .fontSize(22)
                    .fontColor(this.darkSecondary)
                  Text(item.content)
                    .fontSize(24)
                    .fontColor(this.darkSecondary)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding({ top: 8, bottom: 8 })

              if (index < 2) {
                Divider().color('#E5E6EB').margin({ left: 11 })
              }
            }
          }, (item: AnnouncementItem, index: number) => item.title + index.toString())
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')
        .borderRadius(8)
        .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })

        // 6. 今日课程卡片
        Column() {
          Row() {
            Text('今日课程')
              .fontSize(28)
              .fontWeight(600)
              .fontColor(this.darkPrimary)
            Text('（2）')
              .fontSize(24)
              .fontColor(this.darkSecondary)
            Blank()
            Text('完整课程 >')
              .fontSize(24)
              .fontColor(this.darkSecondary)
          }
          .width('100%')
          .margin({ bottom: 12 })

          // 课程 1
          Row() {
            Text('10:00')
              .fontSize(24)
              .fontColor(this.darkPrimary)
              .width(60)
              .textAlign(TextAlign.Center)

            Column() {
              Circle().width(8).height(8).fill('#FF7D00')
              Row().width(2).height(30).backgroundColor('#E5E6EB')
            }
            .alignItems(HorizontalAlign.Center)
            .margin({ left: 8, right: 12 })

            Column({ space: 4 }) {
              Text('高级人工智能')
                .fontSize(26)
                .fontWeight(500)
                .fontColor(this.darkPrimary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text('信软楼302（数字多媒体教室）')
                .fontSize(24)
                .fontColor(this.darkSecondary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text('必修')
              .fontSize(22)
              .fontColor('#FF7D00')
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .borderRadius(4)
              .backgroundColor('#FFF3E0')
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })

          Divider().color('#E5E6EB')

          // 课程 2
          Row() {
            Text('14:00')
              .fontSize(24)
              .fontColor(this.darkPrimary)
              .width(60)
              .textAlign(TextAlign.Center)

            Column() {
              Circle().width(8).height(8).fill('#00B42A')
              Row().width(2).height(30).backgroundColor('#E5E6EB')
            }
            .alignItems(HorizontalAlign.Center)
            .margin({ left: 8, right: 12 })

            Column({ space: 4 }) {
              Text('创业管理学')
                .fontSize(26)
                .fontWeight(500)
                .fontColor(this.darkPrimary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text('公教楼508')
                .fontSize(24)
                .fontColor(this.darkSecondary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text('选修')
              .fontSize(22)
              .fontColor('#00B42A')
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .borderRadius(4)
              .backgroundColor('#E6FFE6')
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')
        .borderRadius(8)
        .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })

        // 7. 天气提醒卡片
        Row() {
          Text('☀️')
            .fontSize(48)
            .margin({ right: 12 })

          Column({ space: 4 }) {
            Text('晴 28°C')
              .fontSize(32)
              .fontWeight(600)
              .fontColor(this.darkPrimary)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text('深圳 · 紫外线较强')
              .fontSize(24)
              .fontColor(this.darkSecondary)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text('未来3天 >')
            .fontSize(24)
            .fontColor(this.darkSecondary)
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')
        .borderRadius(8)
        .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          if (this.onWeatherClick) {
            this.onWeatherClick();
          }
        })
      }
      .padding({ left: 20, right: 20, bottom: 16 })
      .alignItems(HorizontalAlign.Start)
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }
}
