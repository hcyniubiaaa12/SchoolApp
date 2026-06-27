// HomeTab.ets - 首页 Tab 内容（P0 首页重做）
// 搜索栏 + 九宫格 9 入口 + 公告卡片 + 今日课程卡片 + 天气卡片

// 快捷入口数据
export interface QuickEntryItem {
  name: string;
  icon: string;
  image?: Resource;
  symbol?: Resource;
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
  @StorageLink('isDarkMode') isDarkMode: boolean = false;
  @StorageLink('fontScale') @Watch('onFontScaleChange') fontScale: number = 1.0;
  @State fsTitle: number = 32;
  @State fsMid: number = 28;
  @State fsBody: number = 26;
  @State fsSmall: number = 24;
  @State fsTiny: number = 22;


  // 字体缩放值变化时更新所有字体大小
  private onFontScaleChange(): void {
    this.fsTitle = Math.round(32 * this.fontScale);
    this.fsMid = Math.round(28 * this.fontScale);
    this.fsBody = Math.round(26 * this.fontScale);
    this.fsSmall = Math.round(24 * this.fontScale);
    this.fsTiny = Math.round(22 * this.fontScale);
  }
  @Prop username: string = '用户';
  @Prop swiperIndex: number = 0;
  onSearchClick?: () => void;
  onMessageClick?: () => void;
  onWeatherClick?: () => void;
  onQuickEntryClick?: (entry: QuickEntryItem) => void;
  onTabChange?: (index: number) => void;
  onMoreAnnouncement?: () => void;

  // 九宫格 9 入口（3×3），color 按分类统一：蓝=学术/工具，橙=生活/娱乐，绿=完成
  private quickEntries: QuickEntryItem[] = [
    { name: '校园公告', icon: '📢', symbol: $r('sys.symbol.bell'), color: '#1677FF' },
    { name: '课程表', icon: '📅', symbol: $r('sys.symbol.calendar'), color: '#1677FF' },
    { name: '成绩查询', icon: '📊', color: '#1677FF' },
    { name: '失物招领', icon: '🔍', symbol: $r('sys.symbol.magnifyingglass'), color: '#FF7D00' },
    { name: '校园地图', icon: '🗺️', symbol: $r('sys.symbol.map'), color: '#1677FF' },
    { name: '图书馆', icon: '', image: $r('app.media.ic_book'), color: '#1677FF' },
    { name: '校园美食', icon: '🍽️', color: '#FF7D00' },
    { name: '音乐播放', icon: '🎵', color: '#FF7D00' },
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

  private getEntrySymbol(index: number): Resource | undefined {
    return this.quickEntries[index].symbol;
  }

  // 根据入口分类返回背景色：蓝=学术，橙=生活，绿=完成
  private getEntryBgColor(index: number): Resource {
    const name = this.quickEntries[index].name;
    if (['校园公告', '课程表', '成绩查询', '校园地图', '图书馆'].indexOf(name) !== -1) {
      return $r('app.color.card_bg_blue');
    }
    if (['失物招领', '校园美食', '音乐播放'].indexOf(name) !== -1) {
      return $r('app.color.card_bg_orange');
    }
    return $r('app.color.card_bg_green');
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        // 1. 导航栏（规范：标题「校园助手」30sp 鸿蒙蓝 600 + 右侧消息铃铛）
        Row() {
          Text('校园助手')
            .fontSize(this.fsTitle)
            .fontWeight(600)
            .fontColor($r('app.color.primary'))
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          // 铃铛图标 + 红点
          Stack() {
            SymbolGlyph($r('sys.symbol.bell'))
              .fontSize(this.fsSmall)
            Circle()
              .width(8)
              .height(8)
              .fill($r('app.color.warm_orange'))
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
          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .fontSize(this.fsSmall)
            .margin({ right: 8 })
          Text('搜索校园信息/课程/美食')
            .fontSize(this.fsSmall)
            .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          SymbolGlyph($r('sys.symbol.mic'))
            .fontSize(this.fsTiny)
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
                  .fontSize(this.fsMid)
                  .fontWeight(700)
                  .fontColor('#FFFFFF')
                Text('精彩讲座即将开启')
                  .fontSize(this.fsSmall)
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
                  .fontSize(this.fsMid)
                  .fontWeight(700)
                  .fontColor('#FFFFFF')
                Text('5月15日开赛')
                  .fontSize(this.fsSmall)
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

        // 4. 九宫格快捷入口 — 3×3 带分类色彩标识
        Column() {
          // 标题：蓝色小圆点 + 快捷入口
          Row() {
            Circle()
              .width(6)
              .height(6)
              .fill($r('app.color.primary'))
            Text('快捷入口')
              .fontSize(this.fsMid)
              .fontWeight(600)
              .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
              .margin({ left: 6 })
          }
          .width('100%')
          .margin({ bottom: 8 })

          ForEach([0, 1, 2] as number[], (rowIdx: number) => {
            Row() {
              ForEach([0, 1, 2] as number[], (colIdx: number) => {
                Column({ space: 8 }) {
                  Stack() {
                    Circle()
                      .width(56)
                      .height(56)
                      .fill(this.getEntryBgColor(rowIdx * 3 + colIdx))
                    if (this.getEntryImage(rowIdx * 3 + colIdx)) {
                      Image(this.getEntryImage(rowIdx * 3 + colIdx)!)
                        .width(28)
                        .height(28)
                    } else if (this.getEntrySymbol(rowIdx * 3 + colIdx)) {
                      SymbolGlyph(this.getEntrySymbol(rowIdx * 3 + colIdx)!)
                        .fontSize(28)
                        .fontColor([this.getEntryColor(rowIdx * 3 + colIdx)])
                    } else {
                      Text(this.getEntryIcon(rowIdx * 3 + colIdx))
                        .fontSize(28)
                    }
                  }
                  Text(this.getEntryName(rowIdx * 3 + colIdx))
                    .fontSize(this.fsSmall)
                    .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
                    .maxLines(1)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)
                .padding({ top: 4, bottom: 4 })
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
        .padding(16)
        .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')
        .borderRadius(8)
        .border({ width: { top: 3 }, color: $r('app.color.primary') })
        .shadow({ radius: 8, color: $r('app.color.shadow'), offsetX: 0, offsetY: 2 })

        // 5. 校园公告卡片（灰色顶部色条 + 灰色圆点标题）
        Column() {
          Row() {
            Circle()
              .width(6)
              .height(6)
              .fill($r('app.color.text_secondary'))
            Text('校园公告')
              .fontSize(this.fsMid)
              .fontWeight(600)
              .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
              .margin({ left: 6 })
            Blank()
            Text('更多 >')
              .fontSize(this.fsSmall)
              .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
              .onClick(() => {
                if (this.onMoreAnnouncement) {
                  this.onMoreAnnouncement();
                }
              })
          }
          .width('100%')
          .margin({ bottom: 12 })

          // 3 条公告：灰色左侧竖条 + 柔和分隔线
          ForEach(this.announcements, (item: AnnouncementItem, index: number) => {
            Column() {
              Row({ space: 8 }) {
                Row()
                  .width(3)
                  .height('100%')
                  .backgroundColor($r('app.color.text_secondary'))
                  .borderRadius(2)

                Column({ space: 4 }) {
                  Text(item.title)
                    .fontSize(this.fsBody)
                    .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(item.time)
                    .fontSize(this.fsTiny)
                    .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
                  Text(item.content)
                    .fontSize(this.fsSmall)
                    .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding({ top: 8, bottom: 8 })

              if (index < 2) {
                Divider().color($r('app.color.divider_light')).margin({ left: 15 })
              }
            }
          }, (item: AnnouncementItem, index: number) => item.title + index.toString())
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')
        .borderRadius(8)
        .border({ width: { top: 3 }, color: $r('app.color.text_secondary') })
        .shadow({ radius: 8, color: $r('app.color.shadow'), offsetX: 0, offsetY: 2 })

        // 6. 天气提醒卡片（蓝色顶部色条 + 蓝色圆点标题）
        Column() {
          Row() {
            Circle()
              .width(6)
              .height(6)
              .fill($r('app.color.primary'))
            Text('天气提醒')
              .fontSize(this.fsMid)
              .fontWeight(600)
              .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
              .margin({ left: 6 })
          }
          .width('100%')
          .margin({ bottom: 8 })

          Row() {
            SymbolGlyph($r('sys.symbol.sun_max'))
              .fontSize(48)
              .margin({ right: 12 })

            Column({ space: 4 }) {
              Text('晴 28°C')
                .fontSize(32)
                .fontWeight(600)
                .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text('深圳 · 紫外线较强')
                .fontSize(this.fsSmall)
                .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text('未来3天 >')
              .fontSize(this.fsSmall)
              .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            if (this.onWeatherClick) {
              this.onWeatherClick();
            }
          })
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')
        .borderRadius(8)
        .border({ width: { top: 3 }, color: $r('app.color.primary') })
        .shadow({ radius: 8, color: $r('app.color.shadow'), offsetX: 0, offsetY: 2 })
      }
      .padding({ left: 20, right: 20, bottom: 16 })
      .alignItems(HorizontalAlign.Start)
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }
}
