/**
 * BookDetailPage.ets - 图书详情页
 * 展示图书完整信息（馆藏/简介/收藏）
 */
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import { BookDao, BookRow } from '../../common/database/BookDao';

@Entry
@Component
struct BookDetailPage {
  @State book: BookRow | null = null;
  @State isLoading: boolean = true;
  @State isFavorited: boolean = false;

  aboutToAppear(): void {
    const params: Record<string, string> = router.getParams() as Record<string, string>;
    const bookId: string = params['bookId'];
    if (!bookId) {
      promptAction.showToast({ message: '缺少图书参数' });
      router.back();
      return;
    }
    this.loadBook(bookId);
  }

  private async loadBook(bookId: string): Promise<void> {
    try {
      const ctx: Context = getContext(this);
      const result: BookRow | null = await BookDao.queryById(ctx, bookId);
      if (result) {
        this.book = result;
        this.isFavorited = result.isFavorited === 1;
      }
    } catch (err) {
      console.error('[BookDetail] 加载图书失败: ' + JSON.stringify(err));
      promptAction.showToast({ message: '加载图书失败' });
    }
    this.isLoading = false;
  }

  private async toggleFavorite(): Promise<void> {
    if (!this.book) {
      return;
    }
    try {
      const ctx: Context = getContext(this);
      const newVal: boolean = await BookDao.toggleFavorite(ctx, this.book.id);
      this.isFavorited = newVal;
      promptAction.showToast({ message: newVal ? '已收藏' : '已取消收藏' });
    } catch (err) {
      console.error('[BookDetail] 收藏操作失败: ' + JSON.stringify(err));
    }
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24).fillColor($r('app.color.text_primary'))
          .onClick(() => { router.back(); })
        Blank()
        Text('图书详情')
          .fontSize(30).fontWeight(600).fontColor($r('app.color.text_primary'))
        Blank()
        Row().width(24)
      }
      .width('100%').height(56).padding({ left: 16, right: 20 })
      .backgroundColor($r('app.color.card_white')).alignItems(VerticalAlign.Center)

      if (this.isLoading) {
        Column() {
          Text('加载中...').fontSize(26).fontColor($r('app.color.text_secondary'))
        }
        .layoutWeight(1).justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (!this.book) {
        Column() {
          Text('未找到图书信息').fontSize(26).fontColor($r('app.color.text_secondary'))
        }
        .layoutWeight(1).justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            // 基本信息卡片
            Column({ space: 12 }) {
              // 封面占位
              Stack() {
                Circle().width(120).height(120).fill($r('app.color.primary_light'))
                Image($r('app.media.ic_book'))
                  .width(48)
                  .height(48)
              }
              .width('100%').height(140)

              Text(this.book.title)
                .fontSize(28).fontWeight(700).fontColor($r('app.color.text_primary'))
                .width('100%').textAlign(TextAlign.Center)

              Text(this.book.author)
                .fontSize(24).fontColor($r('app.color.text_secondary'))
                .width('100%').textAlign(TextAlign.Center)

              Row({ space: 8 }) {
                Text(this.book.isbn)
                  .fontSize(22).fontColor($r('app.color.text_secondary'))
                Blank()
                Row() {
                  SymbolGlyph(this.isFavorited ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'))
                    .fontSize(22)
                    .fontColor([this.isFavorited ? $r('app.color.warm_orange') : $r('app.color.text_secondary')])
                  Text(this.isFavorited ? '已收藏' : '收藏')
                    .fontSize(22)
                    .fontColor(this.isFavorited ? $r('app.color.warm_orange') : $r('app.color.text_secondary'))
                }
                .onClick(() => { this.toggleFavorite(); })
              }
              .width('100%')
            }
            .width('100%').padding(16)
            .backgroundColor($r('app.color.card_white')).borderRadius(8)

            // 出版信息
            Column({ space: 8 }) {
              Text('出版信息').fontSize(26).fontWeight(600).fontColor($r('app.color.text_primary'))

              InfoRow({ label: '出版社', value: this.book.publisher })
              InfoRow({ label: 'ISBN', value: this.book.isbn })
              InfoRow({ label: '馆藏位置', value: this.book.location })
              InfoRow({ label: '可借数量', value: this.book.availableCount.toString() + ' / ' + this.book.totalCount.toString() })
            }
            .width('100%').padding(16)
            .backgroundColor($r('app.color.card_white')).borderRadius(8)

            // 简介
            if (this.book.summary) {
              Column({ space: 8 }) {
                Text('内容简介').fontSize(26).fontWeight(600).fontColor($r('app.color.text_primary'))
                Text(this.book.summary)
                  .fontSize(24).fontColor($r('app.color.text_primary')).lineHeight(36)
              }
              .width('100%').padding(16)
              .backgroundColor($r('app.color.card_white')).borderRadius(8)
            }
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 32 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
    }
    .width('100%').height('100%')
    .backgroundColor($r('app.color.background'))
  }
}

@Component
struct InfoRow {
  label: string = '';
  value: string = '';

  build() {
    Row() {
      Text(this.label)
        .fontSize(24).fontColor($r('app.color.text_secondary')).width(100)
      Text(this.value)
        .fontSize(24).fontColor($r('app.color.text_primary')).layoutWeight(1)
    }
    .width('100%')
  }
}
