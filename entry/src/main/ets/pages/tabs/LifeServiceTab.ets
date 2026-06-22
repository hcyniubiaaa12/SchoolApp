// LifeServiceTab.ets - 生活服务 Tab 占位页（P1 将填充失物招领/美食/音乐/校园工具）
@Component
export struct LifeServiceTab {
  build() {
    Column() {
      Row() {
        Text('生活服务')
          .fontSize(30)
          .fontWeight(600)
          .fontColor('#1D2129')
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')

      // 占位内容（P1 替换为真实功能: 失物招领/校园美食/音乐播放/校园工具）
      Column({ space: 24 }) {
        Circle()
          .width(120)
          .height(120)
          .fill('#FFF3E0')
        Text('🎵')
          .fontSize(48)

        Text('生活服务')
          .fontSize(28)
          .fontWeight(700)
          .fontColor('#FF7D00')

        Text('失物招领、校园美食、音乐播放、校园工具')
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
