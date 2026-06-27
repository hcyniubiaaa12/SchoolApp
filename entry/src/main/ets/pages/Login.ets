// Login.ets - 登录页（StartAbility内）
import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import { UserDao } from '../common/database/UserDao';

@Entry
@Component
struct Login {
  // 登录表单状态
  @State studentId: string = '';
  @State password: string = '';
  @State showPassword: boolean = false;
  @State isIdFocused: boolean = false;
  @State isPwdFocused: boolean = false;

  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  private nameMap: Record<string, string> = {
    '202410290123': '张同学',
    '202410290124': '李同学',
    '202410290125': '王同学',
    '202410290126': '赵同学',
    '202410290127': '刘同学'
  };

  private getNameById(id: string): string {
    return this.nameMap[id] ?? id;
  }

  private isLoginActive(): boolean {
    return this.studentId.length > 0 && this.password.length > 0;
  }

  private async doLogin(): Promise<void> {
    if (!this.studentId) {
      promptAction.showToast({ message: '请输入学号' });
      return;
    }
    if (!this.password) {
      promptAction.showToast({ message: '请输入密码' });
      return;
    }

    // 1. 先查是否是预置演示账号（nameMap 中有，免密码校验）
    let username = this.getNameById(this.studentId);
    let isDemoAccount = this.nameMap[this.studentId] !== undefined;
    let isValid = false;

    if (!isDemoAccount) {
      // 2. 非演示账号：通过 UserDao 校验
      const ok = await UserDao.login(this.context, this.studentId, this.password);
      if (!ok) {
        // 尝试查用户是否存在
        const user = UserDao.findByIdSync(this.context, this.studentId);
        if (user.userId !== this.studentId) {
          promptAction.showToast({ message: '该账号未注册，请先注册' });
          return;
        }
        promptAction.showToast({ message: '密码错误，请重试' });
        return;
      }
      isValid = true;
      username = UserDao.findByIdSync(this.context, this.studentId).username;
    } else {
      // 演示账号：直接通过
      isValid = true;
    }

    if (!isValid) {
      return;
    }

    // 保存登录态和 AppStorage
    await UserDao.setLoggedIn(this.context, true);
    await UserDao.setCurrentUserId(this.context, this.studentId);
    AppStorage.setOrCreate('userId', this.studentId);
    AppStorage.setOrCreate('username', username);

    // 标记登录状态（兼容 StartAbility eventHub）
    this.context.eventHub.emit('markLoginStatus', true);

    // 直接跳转首页（清空路由栈，避免 Navigation 嵌套冲突）
    try {
      router.clear();
      router.pushUrl({ url: 'pages/Index' });
      promptAction.showToast({ message: '登录成功' });
    } catch (err) {
      console.error('>>> [Login] 跳转首页失败: ' + JSON.stringify(err));
      promptAction.showToast({ message: '跳转失败，请重试' });
    }
  }

  // 跳转到注册页（Ability内页面跳转）
  private navigateToRegist(): void {
    this.context.eventHub.emit('navigateToRegist');
  }

  build() {
    Column() {
      // 标题区域
      Column({ space: 12 }) {
        Row() {
          Text('欢迎回来')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          // 黄色鸭子表情
          Text('🦆')
            .fontSize(20)
            .margin({ left: 8 })
        }

        Text('请登录您的高校校园助手账号')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')
      .padding({ top: 60, left: 24, right: 24 })
      .alignItems(HorizontalAlign.Start)

      // 表单区域
      Column({ space: 20 }) {
        // 手机号/学号输入框 - 带标签（聚焦边框变蓝）
        Column({ space: 8 }) {
          Text('手机号 / 学号')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .width('100%')

          Row() {
            Image($r('app.media.ic_account'))
              .width(20)
              .height(20)
              .fillColor(this.isIdFocused ? $r('app.color.primary') : $r('app.color.text_secondary'))
              .margin({ right: 10 })

            TextInput({ placeholder: '请输入您的账号' })
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor(Color.Transparent)
              .border({ width: 0 })
              .layoutWeight(1)
              .onChange((value: string) => { this.studentId = value; })
              .onFocus(() => { this.isIdFocused = true; })
              .onBlur(() => { this.isIdFocused = false; })
          }
          .height(48)
          .padding({ left: 16, right: 16 })
          .borderRadius(8)
          .backgroundColor($r('app.color.card_white'))
          .border({ width: 1, color: this.isIdFocused ? $r('app.color.primary') : $r('app.color.border'), radius: 8 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // 密码输入框 - 带标签（聚焦边框变蓝）
        Column({ space: 8 }) {
          Row() {
            Text('密码')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))

            Blank()

            Text('忘记密码？')
              .fontSize(14)
              .fontColor($r('app.color.primary'))
              .onClick(() => {
                promptAction.showToast({ message: '忘记密码功能开发中' });
              })
          }
          .width('100%')

          Row() {
            Image($r('app.media.ic_lock'))
              .width(20)
              .height(20)
              .fillColor(this.isPwdFocused ? $r('app.color.primary') : $r('app.color.text_secondary'))
              .margin({ right: 10 })

            TextInput({ placeholder: '请输入您的密码' })
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor(Color.Transparent)
              .border({ width: 0 })
              .layoutWeight(1)
              .type(this.showPassword ? InputType.Normal : InputType.Password)
              // 关闭系统自带密码眼睛，避免与右侧手写 SymbolGlyph 眼睛重复显示
              .showPasswordIcon(false)
              .onChange((value: string) => { this.password = value; })
              .onFocus(() => { this.isPwdFocused = true; })
              .onBlur(() => { this.isPwdFocused = false; })

            // 显示/隐藏密码
            SymbolGlyph(this.showPassword ? $r('sys.symbol.eye') : $r('sys.symbol.eye_slash'))
              .fontSize(20)
              .fontColor([this.showPassword ? $r('app.color.primary') : $r('app.color.text_secondary')])
              .onClick(() => { this.showPassword = !this.showPassword; })
          }
          .height(48)
          .padding({ left: 16, right: 16 })
          .borderRadius(8)
          .backgroundColor($r('app.color.card_white'))
          .border({ width: 1, color: this.isPwdFocused ? $r('app.color.primary') : $r('app.color.border'), radius: 8 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // 登录按钮
        Button('登录')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isLoginActive() ? Color.White : $r('app.color.text_secondary'))
          .backgroundColor(this.isLoginActive() ? $r('app.color.primary') : $r('app.color.button_inactive_bg'))
          .borderRadius(8)
          .margin({ top: 8 })
          .onClick(() => { this.doLogin(); })
      }
      .width('100%')
      .padding({ left: 24, right: 24 })
      .margin({ top: 32 })

      Blank()

      // 第三方登录区域
      Column({ space: 12 }) {
        Text('第三方登录')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))

        Row({ space: 20 }) {
          // 微信图标
          Stack() {
            Circle()
              .width(40)
              .height(40)
              .fill('#07C160')
            Text('微')
              .fontSize(14)
              .fontColor($r('app.color.card_white'))
          }

          // QQ图标
          Stack() {
            Circle()
              .width(40)
              .height(40)
              .fill('#12B7F5')
            Text('Q')
              .fontSize(14)
              .fontColor($r('app.color.card_white'))
          }
        }
      }
      .margin({ bottom: 20 })

      // 底部注册入口
      Row() {
        Text('还没有账号？')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
        Text('立即注册')
          .fontSize(14)
          .fontColor($r('app.color.primary'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.navigateToRegist();
          })
      }
      .margin({ bottom: 30 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
    .alignItems(HorizontalAlign.Center)
  }
}
