// EmptyState.ets - 空状态占位组件（P0 通用组件）
// 用于无数据时的友好提示
// v2: 暗色模式支持

@Component
export struct EmptyState {
  @Prop icon?: string;
  @Prop symbol?: Resource;
  @Prop text: string = '暂无数据';
  @Prop subText: string = '';
  @Prop fontSize: number = 26;
  @StorageLink('isDarkMode') isDarkMode: boolean = false;

  build() {
    Column({ space: 12 }) {
      if (this.symbol) {
        SymbolGlyph(this.symbol)
          .fontSize(48)
          .fontColor([this.isDarkMode ? '#A0A0A0' : '#86909C'])
      } else if (this.icon) {
        Text(this.icon)
          .fontSize(48)
      }
      Text(this.text)
        .fontSize(this.fontSize)
        .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
        .textAlign(TextAlign.Center)
      if (this.subText !== '') {
        Text(this.subText)
          .fontSize(22)
          .fontColor(this.isDarkMode ? '#666680' : '#A0A0A0')
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .padding(32)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}
