// EmptyState.ets - 空状态占位组件（P0 通用组件）
// 用于无数据时的友好提示，如「今日无课程，好好休息吧～」

@Component
export struct EmptyState {
  @Prop icon?: string;
  @Prop text: string = '暂无数据';
  @Prop fontSize: number = 26;
  @Prop fontColor: string = '#86909C';

  build() {
    Column({ space: 12 }) {
      if (this.icon) {
        Text(this.icon)
          .fontSize(48)
      }
      Text(this.text)
        .fontSize(this.fontSize)
        .fontColor(this.fontColor)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding(32)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}
