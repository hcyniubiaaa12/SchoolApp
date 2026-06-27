// Regist.ets - 注册页（StartAbility内）
// P0 改造：手机号 + 本地验证码(B方案) + 密码 + 确认密码
import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import { UserDao } from '../common/database/UserDao';

@Entry
@Component
struct Regist {
  // 表单状态
  @State phone: string = '';            // 手机号
  @State generatedCode: string = '';    // 本地生成的验证码
  @State inputCode: string = '';        // 用户输入的验证码
  @State password: string = '';
  @State confirmPassword: string = '';
  @State showPassword: boolean = false;
  @State showConfirmPassword: boolean = false;
  @State isAgree: boolean = false;
  @State codeBtnText: string = '获取验证码';
  @State isCodeSending: boolean = false;
  @State countdown: number = 60;
  @State codeVisible: boolean = false;  // 是否显示验证码提示文字
  @State isPhoneFocused: boolean = false;
  @State isCodeFocused: boolean = false;
  @State isPwdFocused: boolean = false;
  @State isConfirmPwdFocused: boolean = false;

  private timer: number = -1;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  aboutToDisappear() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
  }

  // 判断注册按钮是否激活: 必填项全部填写 + 同意协议
  private isRegisterActive(): boolean {
    return this.phone.length > 0 &&
      this.inputCode.length === 6 &&
      this.password.length >= 6 &&
      this.confirmPassword.length >= 6 &&
      this.isAgree;
  }

  // 点击「获取验证码」: 本地生成6位随机码, 页面内显示
  private sendCode(): void {
    if (!this.phone) {
      promptAction.showToast({ message: '请先输入手机号' });
      return;
    }
    if (this.phone.length !== 11) {
      promptAction.showToast({ message: '请输入11位手机号' });
      return;
    }
    // 本地生成6位随机验证码
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    this.generatedCode = code;
    this.codeVisible = true;

    // 倒计时
    this.isCodeSending = true;
    this.countdown = 60;
    this.codeBtnText = `${this.countdown}s`;
    this.timer = setInterval(() => {
      this.countdown--;
      if (this.countdown <= 0) {
        clearInterval(this.timer);
        this.timer = -1;
        this.isCodeSending = false;
        this.codeBtnText = '获取验证码';
      } else {
        this.codeBtnText = `${this.countdown}s`;
      }
    }, 1000);
  }

  // 注册成功后跳转到 MainAbility，保存用户信息
  private async doRegister(): Promise<void> {
    if (!this.phone) {
      promptAction.showToast({ message: '请输入手机号' });
      return;
    }
    if (!this.inputCode || this.inputCode.length !== 6) {
      promptAction.showToast({ message: '请输入6位验证码' });
      return;
    }
    // B方案：本地比对验证码
    if (this.inputCode !== this.generatedCode) {
      promptAction.showToast({ message: '验证码错误，请重新输入' });
      return;
    }
    if (!this.password || this.password.length < 6) {
      promptAction.showToast({ message: '密码至少6位' });
      return;
    }
    if (this.password !== this.confirmPassword) {
      promptAction.showToast({ message: '两次密码输入不一致' });
      return;
    }
    if (!this.isAgree) {
      promptAction.showToast({ message: '请同意用户注册协议' });
      return;
    }

    const username = this.phone.substring(0, 3) + '****' + this.phone.substring(7);

    // 通过 UserDao 保存用户信息
    try {
      await UserDao.save(this.context, {
        userId: this.phone,
        username: username,
        password: this.password,
        phone: this.phone,
        college: '',
        major: '',
        avatar: ''
      });
      console.log('>>> [Regist] 用户信息已保存 - userId: ' + this.phone + ', username: ' + username);
    } catch (err) {
      console.error('>>> [Regist] 保存用户信息失败: ' + JSON.stringify(err));
      promptAction.showToast({ message: '注册失败，请重试' });
      return;
    }

    // 标记登录态 + AppStorage
    await UserDao.setLoggedIn(this.context, true);
    await UserDao.setCurrentUserId(this.context, this.phone);
    this.context.eventHub.emit('markLoginStatus', true);
    AppStorage.setOrCreate('userId', this.phone);
    AppStorage.setOrCreate('username', username);

    // 跳转首页
    try {
      router.clear();
      router.pushUrl({ url: 'pages/Index' });
      promptAction.showToast({ message: '注册成功' });
    } catch (err) {
      console.error('>>> [Regist] 跳转首页失败: ' + JSON.stringify(err));
      promptAction.showToast({ message: '跳转失败，请重试' });
    }
  }

  // 返回登录页
  private navigateBackToLogin(): void {
    this.context.eventHub.emit('navigateToLogin');
  }

  build() {
    Column() {
      // 顶部返回按钮
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor($r('app.color.text_primary'))
          .onClick(() => {
            this.navigateBackToLogin();
          })
      }
      .width('100%')
      .padding({ left: 20, top: 40 })

      // 标题区域
      Column({ space: 8 }) {
        Text('注册新账号')
          .fontSize($r('app.float.font_size_large'))
          .fontWeight(700)
          .fontColor($r('app.color.text_primary'))
        Text('加入高校校园助手，开启智慧校园新篇章')
          .fontSize($r('app.float.font_size_small'))
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')
      .padding({ top: 24, left: 20, right: 20 })
      .alignItems(HorizontalAlign.Start)

      // 表单区域
      Column({ space: 16 }) {
        // 手机号输入框（聚焦边框变蓝）
        Row() {
          Image($r('app.media.ic_account'))
            .width(20)
            .height(20)
            .fillColor(this.isPhoneFocused ? $r('app.color.primary') : $r('app.color.text_secondary'))
            .margin({ right: 8 })
          TextInput({ placeholder: '请输入手机号' })
            .fontSize(26)
            .fontColor($r('app.color.text_primary'))
            .backgroundColor(Color.Transparent)
            .border({ width: 0 })
            .layoutWeight(1)
            .type(InputType.Number)
            .maxLength(11)
            .onChange((value: string) => { this.phone = value; })
            .onFocus(() => { this.isPhoneFocused = true; })
            .onBlur(() => { this.isPhoneFocused = false; })
        }
        .height(48)
        .padding({ left: 16, right: 16 })
        .borderRadius(8)
        .backgroundColor($r('app.color.card_white'))
        .border({ width: 1, color: this.isPhoneFocused ? $r('app.color.primary') : $r('app.color.border'), radius: 8 })

        // 验证码输入框 + 获取验证码按钮（聚焦边框变蓝）
        Row() {
          SymbolGlyph($r('sys.symbol.message'))
            .fontColor([this.isCodeFocused ? $r('app.color.primary') : $r('app.color.text_secondary')])
            .fontSize(20)
            .margin({ right: 8 })
          TextInput({ placeholder: '输入6位验证码' })
            .fontSize(26)
            .fontColor($r('app.color.text_primary'))
            .backgroundColor(Color.Transparent)
            .border({ width: 0 })
            .layoutWeight(1)
            .type(InputType.Number)
            .maxLength(6)
            .onChange((value: string) => { this.inputCode = value; })
            .onFocus(() => { this.isCodeFocused = true; })
            .onBlur(() => { this.isCodeFocused = false; })

          // 获取验证码按钮
          Button(this.codeBtnText)
            .height(36)
            .fontSize(24)
            .fontColor(this.isCodeSending ? $r('app.color.text_secondary') : $r('app.color.warm_orange'))
            .backgroundColor(Color.Transparent)
            .borderRadius(8)
            .margin({ left: 8 })
            .enabled(!this.isCodeSending)
            .onClick(() => { this.sendCode(); })
        }
        .height(48)
        .padding({ left: 16, right: 8 })
        .borderRadius(8)
        .backgroundColor($r('app.color.card_white'))
        .border({ width: 1, color: this.isCodeFocused ? $r('app.color.primary') : $r('app.color.border'), radius: 8 })

        // B方案：显示本地生成的验证码
        if (this.codeVisible) {
          Text(`您的验证码是：${this.generatedCode}`)
            .fontSize(24)
            .fontColor($r('app.color.warm_orange'))
            .fontWeight(600)
        }

        // 密码输入框（聚焦边框变蓝）
        Row() {
          Image($r('app.media.ic_lock'))
            .width(20)
            .height(20)
            .fillColor(this.isPwdFocused ? $r('app.color.primary') : $r('app.color.text_secondary'))
            .margin({ right: 8 })
          TextInput({ placeholder: '请输入6-20位密码' })
            .fontSize(26)
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

          // 密码显隐按钮
          if (this.showPassword) {
            SymbolGlyph($r('sys.symbol.eye'))
              .fontColor([$r('app.color.primary')])
              .fontSize(20)
              .onClick(() => { this.showPassword = !this.showPassword; })
          } else {
            SymbolGlyph($r('sys.symbol.eye_slash'))
              .fontColor([$r('app.color.text_secondary')])
              .fontSize(20)
              .onClick(() => { this.showPassword = !this.showPassword; })
          }
        }
        .height(48)
        .padding({ left: 16, right: 16 })
        .borderRadius(8)
        .backgroundColor($r('app.color.card_white'))
        .border({ width: 1, color: this.isPwdFocused ? $r('app.color.primary') : $r('app.color.border'), radius: 8 })

        // 确认密码输入框（聚焦边框变蓝）
        Row() {
          Image($r('app.media.ic_lock'))
            .width(20)
            .height(20)
            .fillColor(this.isConfirmPwdFocused ? $r('app.color.primary') : $r('app.color.text_secondary'))
            .margin({ right: 8 })
          TextInput({ placeholder: '请再次输入密码' })
            .fontSize(26)
            .fontColor($r('app.color.text_primary'))
            .backgroundColor(Color.Transparent)
            .border({ width: 0 })
            .layoutWeight(1)
            .type(this.showConfirmPassword ? InputType.Normal : InputType.Password)
            // 关闭系统自带密码眼睛，避免与右侧手写 SymbolGlyph 眼睛重复显示
            .showPasswordIcon(false)
            .onChange((value: string) => { this.confirmPassword = value; })
            .onFocus(() => { this.isConfirmPwdFocused = true; })
            .onBlur(() => { this.isConfirmPwdFocused = false; })

          if (this.showConfirmPassword) {
            SymbolGlyph($r('sys.symbol.eye'))
              .fontColor([$r('app.color.primary')])
              .fontSize(20)
              .onClick(() => { this.showConfirmPassword = !this.showConfirmPassword; })
          } else {
            SymbolGlyph($r('sys.symbol.eye_slash'))
              .fontColor([$r('app.color.text_secondary')])
              .fontSize(20)
              .onClick(() => { this.showConfirmPassword = !this.showConfirmPassword; })
          }
        }
        .height(48)
        .padding({ left: 16, right: 16 })
        .borderRadius(8)
        .backgroundColor($r('app.color.card_white'))
        .border({ width: 1, color: this.isConfirmPwdFocused ? $r('app.color.primary') : $r('app.color.border'), radius: 8 })
      }
      .width('100%')
      .padding({ top: 32, left: 20, right: 20 })
      .alignItems(HorizontalAlign.Center)

      // 注册协议
      Row({ space: 4 }) {
        Checkbox()
          .width(18)
          .height(18)
          .selectedColor($r('app.color.primary'))
          .select(this.isAgree)
          .onChange((value: boolean) => { this.isAgree = value; })

        Text('我已阅读并同意')
          .fontSize(24)
          .fontColor($r('app.color.text_secondary'))

        Text('《用户注册协议》')
          .fontSize(24)
          .fontColor($r('app.color.primary'))
          .decoration({ type: TextDecorationType.Underline })
          .onClick(() => {
            promptAction.showToast({ message: '用户注册协议内容' });
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
      .margin({ top: 20 })

      // 注册按钮（激活/未激活态）
      Button('注册')
        .width('90%')
        .height(48)
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isRegisterActive() ? Color.White : $r('app.color.button_inactive_text'))
        .backgroundColor(this.isRegisterActive() ? $r('app.color.primary') : $r('app.color.button_inactive_bg'))
        .borderRadius(8)
        .margin({ top: 24 })
        .onClick(() => { this.doRegister(); })

      // 底部登录入口
      Row() {
        Text('已有账号？')
          .fontSize(24)
          .fontColor($r('app.color.text_primary'))
        Text('立即登录')
          .fontSize(24)
          .fontColor($r('app.color.primary'))
          .margin({ left: 4 })
          .onClick(() => { this.navigateBackToLogin(); })
      }
      .margin({ top: 24, bottom: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
    .alignItems(HorizontalAlign.Center)
  }
}
