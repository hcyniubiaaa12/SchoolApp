/**
 * ExpressQueryPage.ets - 快递查询
 * 输入快递单号，模拟展示物流状态
 */
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';

interface ExpressStep {
  status: string;
  location: string;
  time: string;
  isCurrent: boolean;
}

@Entry
@Component
struct ExpressQueryPage {
  @State trackingNumber: string = '';
  @State hasSearched: boolean = false;
  @State expressSteps: ExpressStep[] = [];
  @State carrier: string = '';
  @StorageLink('isDarkMode') isDarkMode: boolean = false;

  private searchExpress(): void {
    const num: string = this.trackingNumber.trim();
    if (num === '') {
      promptAction.showToast({ message: '请输入快递单号' });
      return;
    }
    if (num.length < 6) {
      promptAction.showToast({ message: '单号格式不正确' });
      return;
    }

    // 模拟查询结果
    this.carrier = '顺丰速运';
    this.expressSteps = [
      { status: '已签收', location: '学校快递驿站', time: '模拟: 2026-06-25 15:30', isCurrent: false },
      { status: '派送中', location: 'XX市XX区分部', time: '模拟: 2026-06-25 09:00', isCurrent: true },
      { status: '到达派件城市', location: 'XX市分拣中心', time: '模拟: 2026-06-24 23:00', isCurrent: false },
      { status: '运输中', location: 'XX市转运中心', time: '模拟: 2026-06-24 15:00', isCurrent: false },
      { status: '已揽收', location: 'XX市XX区', time: '模拟: 2026-06-23 18:30', isCurrent: false },
    ];
    this.hasSearched = true;
    promptAction.showToast({ message: '查询成功（模拟数据）' });
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24).fillColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
          .onClick(() => { router.back(); })
        Blank()
        Text('快递查询')
          .fontSize(30).fontWeight(600).fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
        Blank()
        Row().width(24)
      }
      .width('100%').height(56).padding({ left: 16, right: 20 })
      .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF').alignItems(VerticalAlign.Center)

      Scroll() {
        Column({ space: 16 }) {
          // 查询区
          Row({ space: 12 }) {
            TextInput({ placeholder: '请输入快递单号', text: this.trackingNumber })
              .layoutWeight(1).height(48).fontSize(26)
              .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
              .placeholderColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
              .backgroundColor(this.isDarkMode ? '#1A1A2E' : '#F5F7FA').borderRadius(8)
              .onChange((val: string) => { this.trackingNumber = val; })

            Button('查询')
              .height(48).width(80)
              .fontSize(24).fontColor(Color.White)
              .backgroundColor($r('app.color.primary')).borderRadius(8)
              .onClick(() => { this.searchExpress(); })
          }
          .width('100%').padding({ left: 20, right: 20 })

          Text('提示：当前为模拟查询，仅演示界面效果')
            .fontSize(22).fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
            .width('100%').padding({ left: 20, right: 20 })

          if (this.hasSearched) {
            // 快递信息卡片
            Column({ space: 12 }) {
              Row({ space: 12 }) {
                Text('📦').fontSize(40)
                Column({ space: 4 }) {
                  Text(this.carrier)
                    .fontSize(26).fontWeight(600).fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
                  Text('单号：' + this.trackingNumber)
                    .fontSize(22).fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }

              if (this.expressSteps.length > 0) {
                Text('最新状态：' + this.expressSteps[0].status)
                  .fontSize(24).fontColor($r('app.color.fresh_green'))
              }
            }
            .width('100%').padding(16)
            .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF').borderRadius(8)
            .shadow({ radius: 4, color: this.isDarkMode ? '#00000033' : '#1A000000', offsetX: 0, offsetY: 1 })

            // 物流详情
            Column({ space: 12 }) {
              Text('物流详情')
                .fontSize(26).fontWeight(600).fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')

              Column({ space: 0 }) {
                ForEach(this.expressSteps, (step: ExpressStep, index: number) => {
                  Row() {
                    // 左侧时间线
                    Column() {
                      if (index === this.expressSteps.length - 1) {
                        // 最后一个，顶部圆底部线
                        Column() {
                          Circle()
                            .width(12).height(12)
                            .fill(step.isCurrent ? $r('app.color.primary') : $r('app.color.fresh_green'))
                        }
                        .height('50%')
                        .justifyContent(FlexAlign.End)
                        .alignItems(HorizontalAlign.Center)
                      } else {
                        // 中间有连线
                        Column() {
                          Circle()
                            .width(12).height(12)
                            .fill(step.isCurrent ? $r('app.color.primary') : $r('app.color.fresh_green'))
                          Column()
                            .width(2).height('100%')
                            .backgroundColor(this.isDarkMode ? '#333344' : '#E5E6EB')
                        }
                        .alignItems(HorizontalAlign.Center)
                      }
                    }

                    // 右侧内容
                    Column({ space: 4 }) {
                      Text(step.status)
                        .fontSize(26)
                        .fontColor(step.isCurrent ? $r('app.color.primary') : (this.isDarkMode ? '#E8E8E8' : '#1D2129'))
                        .fontWeight(step.isCurrent ? 700 : 400)

                      Text(step.location)
                        .fontSize(22).fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')

                      Text(step.time)
                        .fontSize(22).fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
                    }
                    .alignItems(HorizontalAlign.Start)
                    .margin({ left: 12 })
                    .layoutWeight(1)
                    .padding({ top: 4, bottom: 16 })
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Top)
                }, (step: ExpressStep) => step.time + step.status)
              }
            }
            .width('100%').padding(16)
            .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF').borderRadius(8)
            .shadow({ radius: 4, color: this.isDarkMode ? '#00000033' : '#1A000000', offsetX: 0, offsetY: 1 })
          }
        }
        .width('100%')
        .padding({ left: 0, right: 0, top: 16, bottom: 32 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%').height('100%')
    .backgroundColor(this.isDarkMode ? '#1A1A2E' : '#F5F7FA')
  }
}
