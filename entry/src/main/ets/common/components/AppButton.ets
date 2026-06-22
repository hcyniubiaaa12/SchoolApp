// AppButton.ets - 规范按钮组件（P0 通用组件）
// 默认高度 48px，小按钮 36px；圆角 8px
// 激活态: bg #1677FF 白字；未激活态: bg #C6E2FF 文字 #86909C

@Component
export struct AppButton {
  @Prop label: string = '按钮';
  @Prop active: boolean = true;
  @Prop type: 'normal' | 'small' = 'normal';
  @Prop width: string = '100%';
  onClick?: () => void;

  build() {
    Button(this.label)
      .width(this.width)
      .height(this.type === 'small' ? 36 : 48)
      .fontSize(26)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.active ? Color.White : '#86909C')
      .backgroundColor(this.active ? '#1677FF' : '#C6E2FF')
      .borderRadius(8)
      .onClick(() => {
        if (this.onClick && this.active) {
          this.onClick();
        }
      })
  }
}
