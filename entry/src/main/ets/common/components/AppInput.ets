// AppInput.ets - 规范输入框组件（P0 通用组件）
// 高度 48px，圆角 8px，左右内边距 16px
// 聚焦时边框变鸿蒙蓝，默认淡灰边框

@Component
export struct AppInput {
  @Prop placeholder: string = '';
  @Prop leftIcon?: Resource;
  @Prop rightIcon?: Resource;
  @Prop inputType: InputType = InputType.Normal;
  @Prop maxLength: number = -1;
  @Link value: string;
  onRightIconClick?: () => void;

  build() {
    Row() {
      if (this.leftIcon) {
        Image(this.leftIcon)
          .width(20)
          .height(20)
          .fillColor('#999999')
          .margin({ right: 8 })
      }

      TextInput({ placeholder: this.placeholder })
        .fontSize(26)
        .fontColor('#1D2129')
        .backgroundColor(Color.Transparent)
        .border({ width: 0 })
        .layoutWeight(1)
        .type(this.inputType)
        .maxLength(this.maxLength)
        .onChange((value: string) => { this.value = value; })

      if (this.rightIcon) {
        Image(this.rightIcon)
          .width(20)
          .height(20)
          .fillColor('#999999')
          .margin({ left: 8 })
          .onClick(() => {
            if (this.onRightIconClick) {
              this.onRightIconClick();
            }
          })
      }
    }
    .height(48)
    .padding({ left: 16, right: 16 })
    .borderRadius(8)
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: '#E5E6EB', radius: 8 })
  }
}
