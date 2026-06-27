/**
 * CountdownPage.ets - 倒计时
 * 输入目标日期，显示剩余天数/小时/分钟/秒
 */
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct CountdownPage {
  @State targetDate: string = '';
  @State targetName: string = '';
  @State remaining: string = '请输入目标日期和名称';
  @State isRunning: boolean = false;
  @StorageLink('isDarkMode') isDarkMode: boolean = false;
  private timerId: number = -1;
  private selectedDate: Date = new Date();

  /** 打开日期选择器 */
  private showDatePicker(): void {
    DatePickerDialog.show({
      start: new Date(2020, 0, 1),
      end: new Date(2030, 11, 31),
      selected: this.selectedDate,
      onAccept: (value: DatePickerResult): void => {
        this.selectedDate = new Date(value.year ?? 2026, value.month ?? 0, value.day ?? 1);
        this.targetDate = this.selectedDate.getFullYear().toString() + '-' +
          (this.selectedDate.getMonth() + 1).toString().padStart(2, '0') + '-' +
          this.selectedDate.getDate().toString().padStart(2, '0');
      }
    });
  }

  aboutToAppear(): void {
    // 默认目标日期：7天后
    const future: Date = new Date();
    future.setDate(future.getDate() + 7);
    this.selectedDate = future;
    this.targetDate = future.getFullYear().toString() + '-' +
      (future.getMonth() + 1).toString().padStart(2, '0') + '-' +
      future.getDate().toString().padStart(2, '0');
    this.targetName = '';
  }

  aboutToDisappear(): void {
    this.stopTimer();
  }

  private startTimer(): void {
    if (this.targetDate === '') {
      promptAction.showToast({ message: '请输入目标日期' });
      return;
    }
    if (this.targetName.trim() === '') {
      this.targetName = '倒计时';
    }
    this.isRunning = true;
    this.updateRemaining();
    this.timerId = setInterval(() => {
      this.updateRemaining();
    }, 1000);
  }

  private stopTimer(): void {
    this.isRunning = false;
    if (this.timerId >= 0) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private resetTimer(): void {
    this.stopTimer();
    this.remaining = '请输入目标日期和名称';
  }

  private updateRemaining(): void {
    try {
      const target: Date = new Date(this.targetDate);
      const now: Date = new Date();
      const diff: number = target.getTime() - now.getTime();

      if (diff <= 0) {
        this.remaining = '时间到！';
        this.stopTimer();
        return;
      }

      const days: number = Math.floor(diff / (1000 * 60 * 60 * 24));
      const hours: number = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
      const minutes: number = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
      const seconds: number = Math.floor((diff % (1000 * 60)) / 1000);

      this.remaining = days.toString() + ' 天 ' +
        hours.toString().padStart(2, '0') + ' 小时 ' +
        minutes.toString().padStart(2, '0') + ' 分 ' +
        seconds.toString().padStart(2, '0') + ' 秒';
    } catch (_e) {
      this.remaining = '日期格式错误';
      this.stopTimer();
    }
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24).fillColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
          .onClick(() => { router.back(); })
        Blank()
        Text('倒计时')
          .fontSize(30).fontWeight(600).fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
        Blank()
        Row().width(24)
      }
      .width('100%').height(56).padding({ left: 16, right: 20 })
      .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF').alignItems(VerticalAlign.Center)

      Scroll() {
        Column({ space: 20 }) {
          // 目标名称
          Column({ space: 8 }) {
            Text('事件名称')
              .fontSize(26).fontWeight(600).fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
            TextInput({ placeholder: '如：期末考试、生日', text: this.targetName })
              .height(48).fontSize(26)
              .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
              .placeholderColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
              .backgroundColor(this.isDarkMode ? '#1A1A2E' : '#F5F7FA').borderRadius(8)
              .onChange((val: string) => { this.targetName = val; })
          }
          .width('100%').padding(16)
          .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF').borderRadius(8)

          // 目标日期（DatePickerDialog 选择）
          Column({ space: 8 }) {
            Text('目标日期')
              .fontSize(26).fontWeight(600).fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
            Row() {
              Text(this.targetDate)
                .fontSize(26).fontColor($r('app.color.primary'))
                .padding({ top: 12, bottom: 12, left: 16, right: 16 })
            }
            .height(48)
            .backgroundColor(this.isDarkMode ? '#1A1A2E' : '#F5F7FA').borderRadius(8)
            .width('100%')
            .onClick(() => { this.showDatePicker(); })
          }
          .width('100%').padding(16)
          .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF').borderRadius(8)

          // 倒计时显示
          Column({ space: 16 }) {
            if (this.targetName.trim() !== '') {
              Text(this.targetName.trim())
                .fontSize(28).fontWeight(700).fontColor($r('app.color.primary'))
            }

            Row({ space: 8 }) {
              if (this.remaining.includes('时间到')) {
                SymbolGlyph($r('sys.symbol.gift')).fontSize(48)
              }
              Text(this.remaining)
                .fontSize(32).fontWeight(700)
                .fontColor(this.remaining.includes('时间到') ? $r('app.color.warm_orange') : (this.isDarkMode ? '#E8E8E8' : '#1D2129'))
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)

            if (this.isRunning) {
              Text('倒计时运行中...')
                .fontSize(22).fontColor($r('app.color.fresh_green'))
            }
          }
          .width('100%').padding(32)
          .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF').borderRadius(8)
          .alignItems(HorizontalAlign.Center)

          // 控制按钮
          Row({ space: 16 }) {
            Button(this.isRunning ? '停止' : '开始倒计时')
              .layoutWeight(1).height(48)
              .fontSize(26).fontColor(Color.White)
              .backgroundColor(this.isRunning ? $r('app.color.warm_orange') : $r('app.color.primary'))
              .borderRadius(8)
              .onClick(() => {
                if (this.isRunning) {
                  this.stopTimer();
                } else {
                  this.startTimer();
                }
              })

            Button('重置')
              .width(100).height(48)
              .fontSize(26).fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
              .backgroundColor(this.isDarkMode ? '#1A1A2E' : '#F5F7FA')
              .borderRadius(8)
              .onClick(() => { this.resetTimer(); })
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 32 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%').height('100%')
    .backgroundColor(this.isDarkMode ? '#1A1A2E' : '#F5F7FA')
  }
}
