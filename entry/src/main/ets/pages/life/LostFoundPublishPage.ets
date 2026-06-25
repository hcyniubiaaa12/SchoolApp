/**
 * LostFoundPublishPage.ets - 失物/拾物发布页
 */
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct LostFoundPublishPage {
  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24).fillColor('#1D2129')
          .onClick(() => { router.back(); })
        Blank()
        Text('发布信息')
          .fontSize(30).fontWeight(600).fontColor('#1D2129')
        Blank()
        Row().width(24)
      }
      .width('100%').height(56).padding({ left: 16, right: 20 })
      .backgroundColor('#FFFFFF').alignItems(VerticalAlign.Center)

      Column() {
        Text('发布功能开发中')
          .fontSize(26).fontColor('#86909C')
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%').height('100%')
    .backgroundColor('#F5F7FA')
  }
}
