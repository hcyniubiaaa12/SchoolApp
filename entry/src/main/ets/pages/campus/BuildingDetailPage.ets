/**
 * BuildingDetailPage.ets - 建筑详情页
 * 展示校园建筑的详细信息（位置、介绍、图片）
 */
import { router } from '@kit.ArkUI';

@Entry
@Component
struct BuildingDetailPage {
  @State buildingName: string = '';
  @State buildingDescription: string = '';

  aboutToAppear(): void {
    const params: Record<string, string> = router.getParams() as Record<string, string>;
    this.buildingName = params['name'] ?? '未知建筑';
    this.buildingDescription = params['description'] ?? '暂无介绍';
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24).fillColor($r('app.color.text_primary'))
          .onClick(() => { router.back(); })
        Blank()
        Text(this.buildingName)
          .fontSize(30).fontWeight(600).fontColor($r('app.color.text_primary'))
          .layoutWeight(1).textAlign(TextAlign.Center)
        Blank()
        Row().width(24)
      }
      .width('100%').height(56).padding({ left: 16, right: 20 })
      .backgroundColor($r('app.color.card_white')).alignItems(VerticalAlign.Center)

      Scroll() {
        Column({ space: 16 }) {
          // 建筑图标占位
          Stack() {
            Column()
              .width('100%').height(200)
              .backgroundColor($r('app.color.primary_light'))
              .borderRadius(8)

            Column({ space: 8 }) {
              SymbolGlyph($r('sys.symbol.building')).fontSize(72)
              Text(this.buildingName)
                .fontSize(28).fontWeight(700).fontColor($r('app.color.primary'))
            }
            .alignItems(HorizontalAlign.Center)
          }

          // 建筑介绍
          Column({ space: 8 }) {
            Text('建筑介绍')
              .fontSize(26).fontWeight(600).fontColor($r('app.color.text_primary'))

            Text(this.buildingDescription)
              .fontSize(24).fontColor($r('app.color.text_primary'))
              .lineHeight(36)
          }
          .width('100%').padding(16)
          .backgroundColor($r('app.color.card_white')).borderRadius(8)

          // 位置信息（模拟）
          Column({ space: 8 }) {
            Text('位置信息')
              .fontSize(26).fontWeight(600).fontColor($r('app.color.text_primary'))

            Row({ space: 12 }) {
              SymbolGlyph($r('sys.symbol.pin')).fontSize(24)
              Text('校园地图中可查看详细位置')
                .fontSize(24).fontColor($r('app.color.text_secondary'))
            }

            Row({ space: 12 }) {
              SymbolGlyph($r('sys.symbol.clock')).fontSize(24)
              Text('开放时间：7:00 - 22:00')
                .fontSize(24).fontColor($r('app.color.text_secondary'))
            }
          }
          .width('100%').padding(16)
          .backgroundColor($r('app.color.card_white')).borderRadius(8)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 32 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%').height('100%')
    .backgroundColor($r('app.color.background'))
  }
}
