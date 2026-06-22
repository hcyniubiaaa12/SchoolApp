// CampusInfoTab.ets - 校园信息 Tab（P1 将填充公告/资讯/社团/讲座/地图）
// P0 框架优化：标签预览 + 美观空状态占位

interface CampusTagItem {
  name: string;
}

@Component
export struct CampusInfoTab {
  private tags: CampusTagItem[] = [
    { name: '校园公告' },
    { name: '校园资讯' },
    { name: '社团活动' },
    { name: '学术讲座' },
    { name: '校园地图' }
  ];

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('校园信息')
          .fontSize(30)
          .fontWeight(600)
          .fontColor('#1D2129')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')

      Scroll() {
        Column({ space: 16 }) {
          // 分类标签预览（横向滚动，视觉占位）
          Row({ space: 12 }) {
            ForEach(this.tags, (tag: CampusTagItem, index: number) => {
              Text(tag.name)
                .fontSize(22)
                .fontColor(index === 0 ? '#FFFFFF' : '#1D2129')
                .padding({ left: 16, right: 16, top: 6, bottom: 6 })
                .backgroundColor(index === 0 ? '#1677FF' : '#F5F7FA')
                .borderRadius(20)
            }, (tag: CampusTagItem, index: number) => tag.name + index.toString())
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 12, bottom: 12 })
          .backgroundColor('#FFFFFF')

          // 空状态占位
          Column({ space: 24 }) {
            Stack() {
              Circle()
                .width(140)
                .height(140)
                .fill('#E8F3FF')
              Text('🏫')
                .fontSize(64)
            }

            Column({ space: 8 }) {
              Text('校园信息')
                .fontSize(28)
                .fontWeight(700)
                .fontColor('#1677FF')
                .maxLines(1)
              Text('校园公告、资讯、社团活动、学术讲座、校园地图')
                .fontSize(24)
                .fontColor('#86909C')
                .textAlign(TextAlign.Center)
                .padding({ left: 32, right: 32 })
                .maxLines(2)
              Text('功能开发中，敬请期待...')
                .fontSize(24)
                .fontColor('#86909C')
                .margin({ top: 8 })
                .maxLines(1)
            }
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .padding({ top: 60, bottom: 60 })
        }
        .width('100%')
        .padding({ bottom: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
