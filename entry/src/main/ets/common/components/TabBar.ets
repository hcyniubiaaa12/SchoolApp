// TabBar.ets - 底部 5 Tab 导航栏组件（P0 通用组件）
// 规范: 图标 28px + 文字 22sp，选中鸿蒙蓝，白底无阴影，高 56px

export interface TabItemData {
  name: string;       // Tab 文字
  icon: Resource;     // Tab 图标(选中态)
  iconUnselected: Resource;  // Tab 图标(未选中态)
}

@Component
export struct TabBar {
  @Prop tabs: TabItemData[] = [];
  @Link currentTab: number;
  onTabChange?: (index: number) => void;

  build() {
    Row() {
      ForEach(this.tabs, (tab: TabItemData, index: number) => {
        Column({ space: 2 }) {
          // Tab 图标 — 28px
          Image(index === this.currentTab ? tab.icon : tab.iconUnselected)
            .width(28)
            .height(28)
            .objectFit(ImageFit.Contain)
            .fillColor(index === this.currentTab ? '#1677FF' : '#86909C')

          // Tab 文字 — 22sp
          Text(tab.name)
            .fontSize(22)
            .fontColor(index === this.currentTab ? '#1677FF' : '#86909C')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .padding({ top: 4, bottom: 6 })
        .onClick(() => {
          this.currentTab = index;
          if (this.onTabChange) {
            this.onTabChange(index);
          }
        })
      }, (tab: TabItemData, index: number) => tab.name + index.toString())
    }
    .width('100%')
    .height(56)
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 1 }, color: '#E5E6EB' })
  }
}
