// Regist.ets - 注册页（StartAbility内）
import { common, Want } from '@kit.AbilityKit';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct Regist {
  // 表单状态
  @State account: string = '';
  @State password: string = '';
  @State code: string = '';
  @State isAgree: boolean = false;
  @State showPassword: boolean = false;
  @State codeBtnText: string = '获取验证码';
  @State isCodeSending: boolean = false;
  @State countdown: number = 60;

  private timer: number = -1;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  aboutToDisappear() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
  }

  private isRegisterActive(): boolean {
    return this.account.length > 0 && this.password.length > 0 &&
      this.code.length > 0 && this.isAgree;
  }

  private sendCode(): void {
    if (!this.account) {
      promptAction.showToast({ message: '请先输入手机号/邮箱' });
      return;
    }
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
    promptAction.showToast({ message: '验证码已发送' });
  }

  // 注册成功后跳转到MainAbility（Ability级别跳转）
  private doRegister(): void {
    if (!this.account) {
      promptAction.showToast({ message: '请输入手机号/邮箱' });
      return;
    }
    if (!this.code || this.code.length !== 6) {
      promptAction.showToast({ message: '请输入6位验证码' });
      return;
    }
    if (!this.password) {
      promptAction.showToast({ message: '请设置密码' });
      return;
    }
    if (!this.isAgree) {
      promptAction.showToast({ message: '请同意用户注册协议' });
      return;
    }

    // 标记登录状态
    this.context.eventHub.emit('markLoginStatus', true);

    // 使用startAbilityForResult跳转到MainAbility，携带注册信息（为结果启动）
    const want: Want = {
      bundleName: 'com.example.schoolapp',
      abilityName: 'MainAbility',
      parameters: {
        userId: this.account,
        username: this.account.substring(0, 3) + '****' + this.account.substring(this.account.length - 4)
      }
    };

    this.context.startAbilityForResult(want)
      .then((result) => {
        promptAction.showToast({ message: '注册成功，MainAbility返回: ' + JSON.stringify(result) });
        console.log('===== [Regist] startAbilityForResult 成功，返回: ' + JSON.stringify(result) + ' =====');
        // 注册成功后关闭StartAbility
        this.context.terminateSelf();
      })
      .catch((err: Error) => {
        promptAction.showToast({ message: '跳转失败: ' + err.message });
        console.error('Start MainAbility failed: ' + JSON.stringify(err));
      });
  }

  // 返回登录页（Ability内页面跳转）
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
          .fillColor('#333333')
          .onClick(() => {
            this.navigateBackToLogin();
          })
      }
      .width('100%')
      .padding({ left: 20, top: 40 })

      // 标题区域：注册新账号 + 橙色星标 + 副标题
      Column({ space: 8 }) {
        Row() {
          Text('注册新账号')
            .fontSize(24)
            .fontWeight(700)
            .fontColor('#333333')
          Text('★')
            .fontSize(16)
            .fontColor('#FF9500')
            .margin({ left: 8 })
        }

        Text('加入校通Plus，开启智慧校园新篇章')
          .fontSize(14)
          .fontColor('#666666')
      }
      .width('100%')
      .padding({ top: 24, left: 20, right: 20 })
      .alignItems(HorizontalAlign.Start)

      // 表单区域
      Column({ space: 16 }) {
        // 手机号码/邮箱输入框 - 带标签
        Column({ space: 6 }) {
          Text('手机号码 / 邮箱')
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
          TextInput({ placeholder: '输入手机号或教育邮箱' })
            .fontSize(14)
            .fontColor('#333333')
            .height(48)
            .padding({ left: 16, right: 16 })
            .borderRadius(8)
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#DDDDDD', radius: 8 })
            .onChange((value: string) => { this.account = value; })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // 验证码输入框 + 获取验证码按钮 - 带标签
        Column({ space: 6 }) {
          Text('验证码')
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
          Row() {
            TextInput({ placeholder: '输入6位验证码' })
              .fontSize(14)
              .fontColor('#333333')
              .height(48)
              .padding({ left: 16, right: 16 })
              .borderRadius(8)
              .backgroundColor('#FFFFFF')
              .border({ width: 1, color: '#DDDDDD', radius: 8 })
              .layoutWeight(1)
              .maxLength(6)
              .onChange((value: string) => { this.code = value; })

            // 获取验证码按钮 - 蓝色文字无边框
            Button(this.codeBtnText)
              .height(48)
              .fontSize(14)
              .fontColor(this.isCodeSending ? '#999999' : '#007DFF')
              .backgroundColor(Color.Transparent)
              .borderRadius(8)
              .margin({ left: 8 })
              .enabled(!this.isCodeSending)
              .onClick(() => { this.sendCode(); })
          }
          .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // 设置密码输入框 - 带标签+眼睛图标
        Column({ space: 6 }) {
          Text('设置密码')
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
          Row() {
            Image($r('app.media.ic_lock'))
              .width(20)
              .height(20)
              .fillColor('#999999')
              .margin({ right: 8 })

            TextInput({ placeholder: '请输入6-20位密码' })
              .fontSize(14)
              .fontColor('#333333')
              .backgroundColor(Color.Transparent)
              .border({ width: 0 })
              .layoutWeight(1)
              .type(this.showPassword ? InputType.Normal : InputType.Password)
              .onChange((value: string) => { this.password = value; })

            // 眼睛图标
            Image($r('app.media.ic_code'))
              .width(20)
              .height(20)
              .fillColor(this.showPassword ? '#007DFF' : '#999999')
              .onClick(() => { this.showPassword = !this.showPassword; })
          }
          .height(48)
          .padding({ left: 16, right: 16 })
          .borderRadius(8)
          .backgroundColor('#FFFFFF')
          .border({ width: 1, color: '#DDDDDD', radius: 8 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ top: 32, left: 20, right: 20 })
      .alignItems(HorizontalAlign.Center)

      // 注册协议
      Row({ space: 4 }) {
        Checkbox()
          .width(18)
          .height(18)
          .selectedColor('#007DFF')
          .select(this.isAgree)
          .onChange((value: boolean) => { this.isAgree = value; })

        Text('我已阅读并同意')
          .fontSize(12)
          .fontColor('#666666')

        Text('《用户协议》')
          .fontSize(12)
          .fontColor('#007DFF')
          .decoration({ type: TextDecorationType.Underline })

        Text('和')
          .fontSize(12)
          .fontColor('#666666')

        Text('《隐私政策》')
          .fontSize(12)
          .fontColor('#007DFF')
          .decoration({ type: TextDecorationType.Underline })
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
      .margin({ top: 20 })

      // 注册按钮 - 蓝色圆角
      Button('注册')
        .width('90%')
        .height(50)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isRegisterActive() ? '#FFFFFF' : '#999999')
        .backgroundColor(this.isRegisterActive() ? '#007DFF' : '#CCCCCC')
        .borderRadius(8)
        .margin({ top: 24 })
        .onClick(() => { this.doRegister(); })

      // 底部登录入口
      Row() {
        Text('已经有账号？')
          .fontSize(14)
          .fontColor('#333333')
        Text('直接登录')
          .fontSize(14)
          .fontColor('#007DFF')
          .margin({ left: 4 })
          .onClick(() => { this.navigateBackToLogin(); })
      }
      .margin({ top: 24, bottom: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Center)
  }
}
