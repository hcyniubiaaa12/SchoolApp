// LifeServiceTab.ets - 生活服务 Tab（P1 将填充失物招领/美食/音乐/校园工具）
// P0 框架优化：入口预览 + 美观空状态占位

interface LifeEntryItem {
  name: string;
  icon: string;
  color: string;
}

@Component
export struct LifeServiceTab {
  private entries: LifeEntryItem[] = [
    { name: '失物招领', icon: '🔍', color: '#FF7D00' },
    { name: '校园美食', icon: '🍽️', color: '#FF7D00' },
    { name: '音乐播放', icon: '🎵', color: '#1677FF' },
    { name: '校园工具', icon: '🛠️', color: '#00B42A' }
  ];

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('生活服务')
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
          // 2×2 功能入口预览（视觉占位）
          Row({ space: 12 }) {
            ForEach(this.entries.slice(0, 2), (entry: LifeEntryItem, index: number) => {
              Column({ space: 8 }) {
                Stack() {
                  Circle()
                    .width(56)
                    .height(56)
                    .fill(entry.color + '1A')
                  Text(entry.icon)
                    .fontSize(28)
                }
                Text(entry.name)
                  .fontSize(22)
                  .fontColor('#1D2129')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
              .padding({ top: 16, bottom: 16 })
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
            }, (entry: LifeEntryItem, index: number) => entry.name + index.toString())
          }
          .width('100%')
          .padding({ left: 20, right: 20 })

          Row({ space: 12 }) {
            ForEach(this.entries.slice(2, 4), (entry: LifeEntryItem, index: number) => {
              Column({ space: 8 }) {
                Stack() {
                  Circle()
                    .width(56)
                    .height(56)
                    .fill(entry.color + '1A')
                  Text(entry.icon)
                    .fontSize(28)
                }
                Text(entry.name)
                  .fontSize(22)
                  .fontColor('#1D2129')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
              .padding({ top: 16, bottom: 16 })
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
            }, (entry: LifeEntryItem, index: number) => entry.name + index.toString())
          }
          .width('100%')
          .padding({ left: 20, right: 20 })

          // 空状态占位
          Column({ space: 24 }) {
            Stack() {
              Circle()
                .width(140)
                .height(140)
                .fill('#FFF3E0')
              Text('🎯')
                .fontSize(64)
            }

            Column({ space: 8 }) {
              Text('生活服务')
                .fontSize(28)
                .fontWeight(700)
                .fontColor('#FF7D00')
                .maxLines(1)
              Text('失物招领、校园美食、音乐播放、校园工具')
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
          .padding({ top: 40, bottom: 60 })
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
