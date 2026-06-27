// Card.ets - 规范卡片组件（P0 通用组件）
// 宽 100%，圆角 8px，轻微阴影(opacity 0.05)，白底
// v2: 暗色模式支持

@Component
export struct Card {
  @Prop padding: number = 16;
  @StorageLink('isDarkMode') isDarkMode: boolean = false;
  @BuilderParam content?: () => void;

  build() {
    Column() {
      if (this.content) {
        this.content();
      }
    }
    .width('100%')
    .padding(this.padding)
    .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')
    .borderRadius(8)
    .shadow({
      radius: 8,
      color: this.isDarkMode ? '#00000033' : '#1A000000',
      offsetX: 0,
      offsetY: 2
    })
  }
}
