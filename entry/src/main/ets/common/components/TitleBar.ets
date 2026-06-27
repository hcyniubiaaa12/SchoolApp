// TitleBar.ets - 通用导航栏组件（P0 通用组件）
// 左返回箭头 + 中标题 + 右图标(可选)
// 支持沉浸式渐变(滚动时透明→白色)
// v2: 暗色模式 + 字体缩放支持

@Component
export struct TitleBar {
  @Prop title: string = '';
  @Prop showBack: boolean = false;
  @Prop rightIcon?: Resource;
  @Prop rightSymbol?: Resource;
  @Prop showRedDot: boolean = false;
  @Prop titleFontSize: number = 30;
  @StorageLink('isDarkMode') isDarkMode: boolean = false;
  onBackClick?: () => void;
  onRightClick?: () => void;

  build() {
    Row() {
      // 左侧返回箭头
      if (this.showBack) {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
          .margin({ right: 8 })
          .onClick(() => {
            if (this.onBackClick) {
              this.onBackClick();
            }
          })
      } else {
        Row().width(24).height(24).margin({ right: 8 })
      }

      // 标题
      Text(this.title)
        .fontSize(this.titleFontSize)
        .fontWeight(600)
        .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
        .layoutWeight(1)
        .textAlign(this.showBack ? TextAlign.Center : TextAlign.Start)
        .margin(this.showBack ? {} : { left: 20 })

      // 右侧图标
      if (this.rightSymbol) {
        Stack() {
          SymbolGlyph(this.rightSymbol)
            .fontSize(24)

          // 未读红点
          if (this.showRedDot) {
            Circle()
              .width(8)
              .height(8)
              .fill($r('app.color.red_dot'))
              .position({ x: 18, y: -2 })
          }
        }
        .width(28)
        .height(28)
        .onClick(() => {
          if (this.onRightClick) {
            this.onRightClick();
          }
        })
      } else if (this.rightIcon) {
        Stack() {
          Image(this.rightIcon)
            .width(24)
            .height(24)
            .objectFit(ImageFit.Contain)

          if (this.showRedDot) {
            Circle()
              .width(8)
              .height(8)
              .fill($r('app.color.red_dot'))
              .position({ x: 20, y: -2 })
          }
        }
        .width(28)
        .height(28)
        .onClick(() => {
          if (this.onRightClick) {
            this.onRightClick();
          }
        })
      } else {
        Row().width(24)
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 20 })
    .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')
    .alignItems(VerticalAlign.Center)
  }
}
