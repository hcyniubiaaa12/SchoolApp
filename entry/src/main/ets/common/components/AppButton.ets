// AppButton.ets - 规范按钮组件（P0 通用组件）
// 默认高度 48px，小按钮 36px；圆角 8px
// 激活态: bg primary 白字；未激活态: bg button_inactive_bg 文字 button_inactive_text

@Component
export struct AppButton {
  @Prop label: string = '按钮';
  @Prop active: boolean = true;
  @Prop type: 'normal' | 'small' = 'normal';
  @Prop width: string = '100%';
  @Prop bgColor: string = '';
  onClick?: () => void;

  build() {
    Button(this.label)
      .width(this.width)
      .height(this.type === 'small' ? 36 : 48)
      .fontSize(26)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.active ? Color.White : $r('app.color.button_inactive_text'))
      .backgroundColor(this.bgColor !== '' ? this.bgColor : (this.active ? $r('app.color.primary') : $r('app.color.button_inactive_bg')))
      .borderRadius(8)
      .onClick(() => {
        if (this.onClick && this.active) {
          this.onClick();
        }
      })
  }
}
