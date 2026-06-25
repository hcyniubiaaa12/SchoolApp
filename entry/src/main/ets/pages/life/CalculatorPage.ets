/**
 * CalculatorPage.ets - 计算器
 * 基础四则运算：+、-、×、÷
 */
import { router } from '@kit.ArkUI';

@Entry
@Component
struct CalculatorPage {
  @State display: string = '0';
  @State previousValue: number = 0;
  @State currentOperator: string = '';
  @State shouldResetDisplay: boolean = false;

  private handleNumber(num: string): void {
    if (this.shouldResetDisplay) {
      this.display = num;
      this.shouldResetDisplay = false;
    } else {
      if (this.display === '0' && num !== '.') {
        this.display = num;
      } else {
        this.display += num;
      }
    }
  }

  private handleOperator(op: string): void {
    const current: number = parseFloat(this.display);
    if (this.currentOperator !== '' && !this.shouldResetDisplay) {
      this.previousValue = this.calculate(this.previousValue, current, this.currentOperator);
      this.display = this.formatNumber(this.previousValue);
    } else {
      this.previousValue = current;
    }
    this.currentOperator = op;
    this.shouldResetDisplay = true;
  }

  private handleEqual(): void {
    if (this.currentOperator === '') {
      return;
    }
    const current: number = parseFloat(this.display);
    this.previousValue = this.calculate(this.previousValue, current, this.currentOperator);
    this.display = this.formatNumber(this.previousValue);
    this.currentOperator = '';
    this.shouldResetDisplay = true;
  }

  private handleClear(): void {
    this.display = '0';
    this.previousValue = 0;
    this.currentOperator = '';
    this.shouldResetDisplay = false;
  }

  private handlePercent(): void {
    const current: number = parseFloat(this.display);
    this.display = this.formatNumber(current / 100);
    this.shouldResetDisplay = true;
  }

  private calculate(a: number, b: number, op: string): number {
    switch (op) {
      case '+': return a + b;
      case '-': return a - b;
      case '×': return a * b;
      case '÷': return b !== 0 ? a / b : 0;
      default: return b;
    }
  }

  private formatNumber(n: number): string {
    if (Number.isInteger(n)) {
      return n.toString();
    }
    return n.toFixed(2);
  }

  private isOperator(c: string): boolean {
    return c === '+' || c === '-' || c === '×' || c === '÷';
  }

  @Builder
  calcButton(text: string, color: string, bgColor: string, action: () => void) {
    Button(text)
      .width(72).height(72)
      .fontSize(28).fontColor(color)
      .backgroundColor(bgColor)
      .borderRadius(36)
      .onClick(() => { action(); })
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24).fillColor('#1D2129')
          .onClick(() => { router.back(); })
        Blank()
        Text('计算器')
          .fontSize(30).fontWeight(600).fontColor('#1D2129')
        Blank()
        Row().width(24)
      }
      .width('100%').height(56).padding({ left: 16, right: 20 })
      .backgroundColor('#FFFFFF').alignItems(VerticalAlign.Center)

      // 显示屏
      Column() {
        Text(this.display)
          .fontSize(48).fontWeight(700)
          .fontColor('#1D2129')
          .width('100%').textAlign(TextAlign.End)
          .padding({ right: 8 })
      }
      .width('100%').padding(20)
      .backgroundColor('#FFFFFF')
      .layoutWeight(1)
      .justifyContent(FlexAlign.End)

      // 按钮区
      Column({ space: 12 }) {
        // 第一行
        Row({ space: 12 }) {
          this.calcButton('C', '#FFFFFF', '#FF7D00', () => { this.handleClear(); })
          this.calcButton('%', '#1D2129', '#F5F7FA', () => { this.handlePercent(); })
          this.calcButton('⌫', '#1D2129', '#F5F7FA', () => {
            if (this.display.length > 1) {
              this.display = this.display.slice(0, -1);
            } else {
              this.display = '0';
            }
          })
          this.calcButton('÷', '#FFFFFF', '#1677FF', () => { this.handleOperator('÷'); })
        }
        .width('100%').justifyContent(FlexAlign.Center)

        // 第二行
        Row({ space: 12 }) {
          this.calcButton('7', '#1D2129', '#F5F7FA', () => { this.handleNumber('7'); })
          this.calcButton('8', '#1D2129', '#F5F7FA', () => { this.handleNumber('8'); })
          this.calcButton('9', '#1D2129', '#F5F7FA', () => { this.handleNumber('9'); })
          this.calcButton('×', '#FFFFFF', '#1677FF', () => { this.handleOperator('×'); })
        }
        .width('100%').justifyContent(FlexAlign.Center)

        // 第三行
        Row({ space: 12 }) {
          this.calcButton('4', '#1D2129', '#F5F7FA', () => { this.handleNumber('4'); })
          this.calcButton('5', '#1D2129', '#F5F7FA', () => { this.handleNumber('5'); })
          this.calcButton('6', '#1D2129', '#F5F7FA', () => { this.handleNumber('6'); })
          this.calcButton('-', '#FFFFFF', '#1677FF', () => { this.handleOperator('-'); })
        }
        .width('100%').justifyContent(FlexAlign.Center)

        // 第四行
        Row({ space: 12 }) {
          this.calcButton('1', '#1D2129', '#F5F7FA', () => { this.handleNumber('1'); })
          this.calcButton('2', '#1D2129', '#F5F7FA', () => { this.handleNumber('2'); })
          this.calcButton('3', '#1D2129', '#F5F7FA', () => { this.handleNumber('3'); })
          this.calcButton('+', '#FFFFFF', '#1677FF', () => { this.handleOperator('+'); })
        }
        .width('100%').justifyContent(FlexAlign.Center)

        // 第五行
        Row({ space: 12 }) {
          Button('0')
            .width(156).height(72)
            .fontSize(28).fontColor('#1D2129')
            .backgroundColor('#F5F7FA').borderRadius(36)
            .onClick(() => { this.handleNumber('0'); })
          this.calcButton('.', '#1D2129', '#F5F7FA', () => { this.handleNumber('.'); })
          this.calcButton('=', '#FFFFFF', '#1677FF', () => { this.handleEqual(); })
        }
        .width('100%').justifyContent(FlexAlign.Center)
      }
      .width('100%').padding(20).margin({ bottom: 24 })
      .backgroundColor('#FFFFFF').borderRadius(8)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%').height('100%')
    .backgroundColor('#F5F7FA')
  }
}
