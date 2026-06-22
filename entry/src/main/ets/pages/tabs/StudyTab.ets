// StudyTab.ets - 学习助手 Tab（P1 将填充课程表/成绩/图书馆/学习资料）
// P0 框架优化：标签预览 + 美观空状态占位

interface StudyTagItem {
  name: string;
}

@Component
export struct StudyTab {
  private tags: StudyTagItem[] = [
    { name: '课程表' },
    { name: '成绩查询' },
    { name: '图书馆检索' },
    { name: '学习资料' }
  ];

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('学习助手')
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
            ForEach(this.tags, (tag: StudyTagItem, index: number) => {
              Text(tag.name)
                .fontSize(22)
                .fontColor(index === 0 ? '#FFFFFF' : '#1D2129')
                .padding({ left: 16, right: 16, top: 6, bottom: 6 })
                .backgroundColor(index === 0 ? '#1677FF' : '#F5F7FA')
                .borderRadius(20)
            }, (tag: StudyTagItem, index: number) => tag.name + index.toString())
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
              Text('📚')
                .fontSize(64)
            }

            Column({ space: 8 }) {
              Text('学习助手')
                .fontSize(28)
                .fontWeight(700)
                .fontColor('#1677FF')
                .maxLines(1)
              Text('课程表、成绩查询、图书馆检索、学习资料')
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
