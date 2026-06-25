/**
 * WeatherDetailPage.ets - 天气详情页
 * 点击首页天气卡片进入，展示未来3天天气（静态模拟数据）
 */
import { router } from '@kit.ArkUI';
import { WeatherDao, WeatherRow } from '../../common/database/WeatherDao';

@Entry
@Component
struct WeatherDetailPage {
  @State forecast: WeatherRow[] = [];

  aboutToAppear(): void {
    const ctx: Context = getContext(this);
    WeatherDao.queryAll(ctx).then((data: WeatherRow[]) => {
      this.forecast = data;
    });
  }

  private getWeatherIcon(weather: string): string {
    if (weather.includes('晴')) return '☀️';
    if (weather.includes('多云')) return '⛅';
    if (weather.includes('阴')) return '☁️';
    if (weather.includes('雨') || weather.includes('阵雨')) return '🌦️';
    return '🌤️';
  }

  private getWeatherColor(weather: string): string {
    if (weather.includes('晴')) return '#FF7D00';
    if (weather.includes('多云')) return '#1677FF';
    if (weather.includes('阴')) return '#86909C';
    if (weather.includes('雨')) return '#1677FF';
    return '#00B42A';
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24).fillColor('#1D2129')
          .onClick(() => {
            router.back();
          })

        Blank()

        Text('天气详情')
          .fontSize(30)
          .fontWeight(600)
          .fontColor('#1D2129')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank()

        Row().width(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 20 })
      .backgroundColor('#FFFFFF')
      .alignItems(VerticalAlign.Center)

      Scroll() {
        Column({ space: 16 }) {
          // 今日天气大卡片
          if (this.forecast.length > 0) {
            Column({ space: 16 }) {
              Text('今日 · ' + this.forecast[0].weekDay)
                .fontSize(28)
                .fontWeight(600)
                .fontColor('#FFFFFF')

              Text(this.getWeatherIcon(this.forecast[0].weather))
                .fontSize(72)

              Text(this.forecast[0].weather)
                .fontSize(26)
                .fontColor('#FFFFFFCC')

              Row({ space: 24 }) {
                Column({ space: 4 }) {
                  Text(this.forecast[0].tempHigh.toString() + '°C')
                    .fontSize(48)
                    .fontWeight(700)
                    .fontColor('#FFFFFF')
                  Text('最高温')
                    .fontSize(22)
                    .fontColor('#FFFFFFCC')
                }
                .alignItems(HorizontalAlign.Center)

                Column({ space: 4 }) {
                  Text(this.forecast[0].tempLow.toString() + '°C')
                    .fontSize(48)
                    .fontWeight(700)
                    .fontColor('#FFFFFF')
                  Text('最低温')
                    .fontSize(22)
                    .fontColor('#FFFFFFCC')
                }
                .alignItems(HorizontalAlign.Center)
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            }
            .width('100%')
            .padding(24)
            .backgroundColor(this.getWeatherColor(this.forecast[0].weather))
            .borderRadius(16)
            .alignItems(HorizontalAlign.Center)
          }

          // 未来天气预报
          Text('未来天气趋势')
            .fontSize(28)
            .fontWeight(700)
            .fontColor('#1D2129')
            .width('100%')

          ForEach(this.forecast, (day: WeatherRow) => {
            Row() {
              Column({ space: 4 }) {
                Text(day.weekDay)
                  .fontSize(26)
                  .fontWeight(600)
                  .fontColor('#1D2129')
                Text(day.dateText.substring(5))
                  .fontSize(22)
                  .fontColor('#86909C')
              }
              .width(60)

              Text(this.getWeatherIcon(day.weather))
                .fontSize(36)
                .margin({ left: 16, right: 16 })

              Text(day.weather)
                .fontSize(24)
                .fontColor('#1D2129')
                .layoutWeight(1)

              Row({ space: 12 }) {
                Text(day.tempLow.toString() + '°')
                  .fontSize(24)
                  .fontColor('#86909C')
                Text(day.tempHigh.toString() + '°')
                  .fontSize(26)
                  .fontWeight(600)
                  .fontColor('#1D2129')
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 1 })
            .alignItems(VerticalAlign.Center)
          }, (day: WeatherRow) => day.dateText)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
