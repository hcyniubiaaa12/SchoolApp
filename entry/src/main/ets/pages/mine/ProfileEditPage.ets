/**
 * ProfileEditPage.ets - 个人信息编辑页
 * 修改昵称/学院/专业/密码，头像更换（本地存储）
 */
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import { UserDao } from '../../common/database/UserDao';

@Entry
@Component
struct ProfileEditPage {
  @StorageLink('isDarkMode') isDarkMode: boolean = false;
  @State nickname: string = '';
  @State college: string = '计算机科学与技术';
  @State major: string = '计算机科学与技术（卓越班）';
  @State oldPassword: string = '';
  @State newPassword: string = '';
  @State confirmPassword: string = '';

  aboutToAppear(): void {
    this.loadUserInfo();
  }

  private loadUserInfo(): void {
    const userId: string = AppStorage.get('userId') as string ?? '';
    if (!userId) { return; }
    try {
      const user = UserDao.findByIdSync(getContext(this), userId);
      this.nickname = user.username;
      this.college = user.college;
      this.major = user.major;
    } catch (err) {
      console.error('[ProfileEditPage] 读取用户信息失败: ' + JSON.stringify(err));
    }
  }

  private saveInfo(): void {
    if (this.nickname.trim() === '') {
      promptAction.showToast({ message: '昵称不能为空' });
      return;
    }
    const userId: string = AppStorage.get('userId') as string ?? '';
    if (!userId) { return; }
    try {
      UserDao.updateProfile(getContext(this), userId, {
        username: this.nickname.trim(),
        college: this.college,
        major: this.major
      });
      AppStorage.setOrCreate('username', this.nickname.trim());
      promptAction.showToast({ message: '保存成功' });
      router.back();
    } catch (err) {
      promptAction.showToast({ message: '保存失败: ' + JSON.stringify(err) });
    }
  }

  private async changePassword(): Promise<void> {
    if (this.oldPassword === '' || this.newPassword === '' || this.confirmPassword === '') {
      promptAction.showToast({ message: '请完整填写密码信息' });
      return;
    }
    if (this.newPassword !== this.confirmPassword) {
      promptAction.showToast({ message: '两次输入的新密码不一致' });
      return;
    }
    const userId: string = AppStorage.get('userId') as string ?? '';
    if (!userId) { return; }
    const result = await UserDao.updatePassword(getContext(this), userId, this.oldPassword, this.newPassword);
    if (result === 'wrong_pwd') {
      promptAction.showToast({ message: '原密码错误' });
    } else if (result === 'not_found') {
      promptAction.showToast({ message: '未设置密码，请直接修改' });
    } else {
      promptAction.showToast({ message: '密码修改成功' });
      this.oldPassword = '';
      this.newPassword = '';
      this.confirmPassword = '';
    }
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24).fillColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
          .onClick(() => {
            router.back();
          })
        Blank()
        Text('个人信息')
          .fontSize(30).fontWeight(600).fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
        Blank()
        Row().width(24)
      }
      .width('100%').height(56).padding({ left: 16, right: 20 })
      .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF').alignItems(VerticalAlign.Center)

      Scroll() {
        Column({ space: 16 }) {
          // 头像区
          Column({ space: 8 }) {
            Stack() {
              Circle()
                .width(80)
                .height(80)
                .fill('#E8F3FF')
              Text(this.nickname.charAt(0) || '用')
                .fontSize(32)
                .fontColor('#1677FF')
            }
            .onClick(() => {
              promptAction.showToast({ message: '头像上传功能将在后续版本开放' });
            })
            Text('点击更换头像')
              .fontSize(22)
              .fontColor('#1677FF')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .padding({ top: 24, bottom: 16 })

          // 基本信息编辑
          Column({ space: 16 }) {
            Text('基本信息')
              .fontSize(28).fontWeight(700).fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')

            this.buildEditField('昵称', this.nickname, (val: string) => { this.nickname = val; })
            this.buildEditField('学院', this.college, () => {})
            this.buildEditField('专业', this.major, () => {})

            Button('保存修改')
              .width('100%').height(48)
              .fontSize(26).fontColor('#FFFFFF')
              .backgroundColor('#1677FF').borderRadius(8)
              .onClick(() => {
                this.saveInfo();
              })
          }
          .width('100%').padding(16)
          .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF').borderRadius(8)

          // 密码修改
          Column({ space: 16 }) {
            Text('修改密码')
              .fontSize(28).fontWeight(700).fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')

            this.buildPasswordField('原密码', this.oldPassword, (val: string) => { this.oldPassword = val; })
            this.buildPasswordField('新密码', this.newPassword, (val: string) => { this.newPassword = val; })
            this.buildPasswordField('确认新密码', this.confirmPassword, (val: string) => { this.confirmPassword = val; })

            Button('修改密码')
              .width('100%').height(48)
              .fontSize(26).fontColor('#FFFFFF')
              .backgroundColor('#FF7D00').borderRadius(8)
              .onClick(() => {
                this.changePassword();
              })
          }
          .width('100%').padding(16)
          .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF').borderRadius(8)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%').height('100%')
    .backgroundColor(this.isDarkMode ? '#1A1A2E' : '#F5F7FA')
  }

  @Builder
  buildEditField(label: string, value: string, onChange: (val: string) => void) {
    Column({ space: 8 }) {
      Text(label).fontSize(24).fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C').width('100%')
      TextInput({ placeholder: '请输入' + label, text: value })
        .height(48).fontSize(26)
        .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
        .placeholderColor('#86909C')
        .backgroundColor(this.isDarkMode ? '#1A1A2E' : '#F5F7FA').borderRadius(8)
        .onChange((val: string) => { onChange(val); })
    }
    .width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildPasswordField(label: string, value: string, onChange: (val: string) => void) {
    Column({ space: 8 }) {
      Text(label).fontSize(24).fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C').width('100%')
      TextInput({ placeholder: '请输入' + label, text: value })
        .height(48).fontSize(26).type(InputType.Password)
        .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
        .placeholderColor('#86909C')
        .backgroundColor(this.isDarkMode ? '#1A1A2E' : '#F5F7FA').borderRadius(8)
        .onChange((val: string) => { onChange(val); })
    }
    .width('100%').alignItems(HorizontalAlign.Start)
  }
}
