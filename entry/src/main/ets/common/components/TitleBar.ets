// TitleBar.ets - 通用导航栏组件（P0 通用组件）
// 左返回箭头 + 中标题 + 右图标(可选)
// 支持沉浸式渐变(滚动时透明→白色)

@Component
export struct TitleBar {
  @Prop title: string = '';
  @Prop showBack: boolean = false;
  @Prop rightIcon?: Resource;
  @Prop showRedDot: boolean = false;
  @Prop backgroundColor: string = '#FFFFFF';
  onBackClick?: () => void;
  onRightClick?: () => void;

  build() {
    Row() {
      // 左侧返回箭头
      if (this.showBack) {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor('#1D2129')
          .margin({ right: 8 })
          .onClick(() => {
            if (this.onBackClick) {
              this.onBackClick();
            }
          })
      }

      // 标题 — 30sp 主色 600
      Text(this.title)
        .fontSize(30)
        .fontWeight(600)
        .fontColor('#1D2129')
        .layoutWeight(1)
        .textAlign(this.showBack ? TextAlign.Center : TextAlign.Start)
        .margin(this.showBack ? {} : { left: 20 })

      // 右侧图标
      if (this.rightIcon) {
        Stack() {
          Image(this.rightIcon)
            .width(24)
            .height(24)
            .objectFit(ImageFit.Contain)

          // 未读红点
          if (this.showRedDot) {
            Circle()
              .width(8)
              .height(8)
              .fill('#FF7D00')
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
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 20 })
    .backgroundColor(this.backgroundColor)
    .alignItems(VerticalAlign.Center)
  }
}
