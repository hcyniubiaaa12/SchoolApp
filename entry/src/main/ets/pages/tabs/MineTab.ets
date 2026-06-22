// MineTab.ets - 我的 Tab 页（P0 骨架，P1 将补充收藏/待办/设置完整功能）
// 个人信息卡片 + 功能列表 + 设置模块
import { router } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';

interface FunctionItem {
  name: string;
  icon: string;   // emoji 占位
}

@Component
export struct MineTab {
  @Prop username: string = '用户';
  @Prop userId: string = '';
  @Prop major: string = '计算机科学与技术';
  onProfileEditClick?: () => void;
  onSettingClick?: () => void;

  // 功能列表项（按规范）
  private functionList: FunctionItem[] = [
    { name: '我的收藏', icon: '❤️' },
    { name: '我的待办', icon: '📝' },
    { name: '我的课程', icon: '📅' },
    { name: '我的成绩', icon: '📊' },
    { name: '失物发布', icon: '📋' },
    { name: '帮助中心', icon: '❓' },
    { name: '意见反馈', icon: '💬' }
  ];

  // 设置项
  private settingList: FunctionItem[] = [
    { name: '深色模式', icon: '🌙' },
    { name: '字体大小', icon: '🔤' },
    { name: '通知设置', icon: '🔔' },
    { name: '清理缓存', icon: '🗑️' }
  ];

  // 退出登录：清除本地登录态，跳转登录页
  private doLogout(): void {
    try {
      const pref = preferences.getPreferencesSync(getContext(this), { name: 'school_app_prefs' });
      pref.putSync('is_logged_in', false);
      pref.putSync('saved_user_id', '');
      pref.putSync('saved_username', '');
      pref.flushSync();
    } catch (err) {
      console.error('>>> [MineTab] 清除登录态失败: ' + JSON.stringify(err));
    }
    try {
      router.clear();
      router.pushUrl({ url: 'pages/Login' });
    } catch (err) {
      console.error('>>> [MineTab] 跳转登录页失败: ' + JSON.stringify(err));
    }
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Text('我的')
          .fontSize(30)
          .fontWeight(600)
          .fontColor('#1D2129')
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text('⚙️')
          .fontSize(24)
          .onClick(() => {
            if (this.onSettingClick) {
              this.onSettingClick();
            }
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')

      Scroll() {
        Column({ space: 16 }) {
          // 个人信息卡片
          Row({ space: 16 }) {
            // 头像 — 圆形 80px
            Stack() {
              Circle()
                .width(80)
                .height(80)
                .fill('#E8F3FF')
              Text(this.username.charAt(0))
                .fontSize(32)
                .fontColor('#1677FF')
            }
            .onClick(() => {
              if (this.onProfileEditClick) {
                this.onProfileEditClick();
              }
            })

            Column({ space: 4 }) {
              Text(this.username)
                .fontSize(28)
                .fontWeight(700)
                .fontColor('#1D2129')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(`学号: ${this.userId}`)
                .fontSize(24)
                .fontColor('#86909C')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(`${this.major}`)
                .fontSize(22)
                .fontColor('#86909C')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text('>')
              .fontSize(24)
              .fontColor('#86909C')
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })

          // 功能列表
          Column() {
            ForEach(this.functionList, (item: FunctionItem) => {
              Row() {
                Text(item.icon)
                  .fontSize(24)
                  .width(32)
                  .textAlign(TextAlign.Center)

                Text(item.name)
                  .fontSize(26)
                  .fontColor('#1D2129')
                  .margin({ left: 12 })
                  .layoutWeight(1)

                Text('>')
                  .fontSize(24)
                  .fontColor('#86909C')
              }
              .width('100%')
              .height(48)
              .padding({ left: 16, right: 16 })
              .alignItems(VerticalAlign.Center)
            }, (item: FunctionItem) => item.name)
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })

          // 设置模块
          Column() {
            ForEach(this.settingList, (item: FunctionItem) => {
              Row() {
                Text(item.icon)
                  .fontSize(24)
                  .width(32)
                  .textAlign(TextAlign.Center)

                Text(item.name)
                  .fontSize(26)
                  .fontColor('#1D2129')
                  .margin({ left: 12 })
                  .layoutWeight(1)

                if (item.name === '深色模式') {
                  Toggle({ type: ToggleType.Switch, isOn: false })
                    .selectedColor('#1677FF')
                    .width(48)
                } else if (item.name === '清理缓存') {
                  Text('64.2MB')
                    .fontSize(24)
                    .fontColor('#FF7D00')
                    .margin({ right: 8 })
                } else {
                  Text('>')
                    .fontSize(24)
                    .fontColor('#86909C')
                }
              }
              .width('100%')
              .height(48)
              .padding({ left: 16, right: 16 })
              .alignItems(VerticalAlign.Center)
            }, (item: FunctionItem) => item.name)
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })

          // 退出登录按钮
          Button('退出登录')
            .width('100%')
            .height(48)
            .fontSize(26)
            .fontColor('#FF7D00')
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .border({ width: 1, color: '#FF7D00' })
            .onClick(() => {
              this.doLogout();
            })

          // 底部关于区
          Column({ space: 4 }) {
            Text('高校校园助手 V1.0.0')
              .fontSize(24)
              .fontColor('#86909C')
            Text('校园助手开发团队')
              .fontSize(22)
              .fontColor('#86909C')
            Text('© 2026 All Rights Reserved')
              .fontSize(22)
              .fontColor('#86909C')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .margin({ top: 24, bottom: 30 })
        }
        .padding({ left: 20, right: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
