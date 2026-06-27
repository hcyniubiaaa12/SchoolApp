// AppInput.ets - 规范输入框组件（P0 通用组件）
// 高度 48px，圆角 8px，左右内边距 16px
// v2: 暗色模式支持

@Component
export struct AppInput {
  @Prop placeholder: string = '';
  @Prop leftIcon?: Resource;
  @Prop rightIcon?: Resource;
  @Prop inputType: InputType = InputType.Normal;
  @Prop maxLength: number = -1;
  @StorageLink('isDarkMode') isDarkMode: boolean = false;
  @Link value: string;
  onRightIconClick?: () => void;

  build() {
    Row() {
      if (this.leftIcon) {
        Image(this.leftIcon)
          .width(20)
          .height(20)
          .fillColor(this.isDarkMode ? '#A0A0A0' : '#999999')
          .margin({ right: 8 })
      }

      TextInput({ placeholder: this.placeholder })
        .fontSize(26)
        .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
        .placeholderColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
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
          .fillColor(this.isDarkMode ? '#A0A0A0' : '#999999')
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
    .backgroundColor(this.isDarkMode ? '#1A1A2E' : '#FFFFFF')
    .border({ width: 1, color: this.isDarkMode ? '#333344' : '#E5E6EB', radius: 8 })
  }
}
