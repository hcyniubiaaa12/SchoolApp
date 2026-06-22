// CampusInfoTab.ets - 校园信息 Tab 占位页（P1 将填充公告/资讯/地图）
@Component
export struct CampusInfoTab {
  build() {
    Column() {
      Row() {
        Text('校园信息')
          .fontSize(30)
          .fontWeight(600)
          .fontColor('#1D2129')
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')

      // 占位内容（P1 替换为真实功能: 5 分类标签 + 列表 + 地图）
      Column({ space: 24 }) {
        Circle()
          .width(120)
          .height(120)
          .fill('#E8F3FF')
        Text('🗺️')
          .fontSize(48)

        Text('校园信息')
          .fontSize(28)
          .fontWeight(700)
          .fontColor('#1677FF')

        Text('校园公告、资讯、社团活动、学术讲座、校园地图')
          .fontSize(24)
          .fontColor('#86909C')
          .textAlign(TextAlign.Center)
          .padding({ left: 40, right: 40 })

        Text('功能开发中，敬请期待...')
          .fontSize(24)
          .fontColor('#86909C')
          .margin({ top: 16 })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
