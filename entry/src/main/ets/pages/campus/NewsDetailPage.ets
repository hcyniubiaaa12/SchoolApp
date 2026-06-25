/**
 * NewsDetailPage.ets - 资讯详情页
 * 展示资讯全文（图文混排、来源、时间）
 */
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import { JsonStoreUtil } from '../../common/utils/JsonStoreUtil';

interface NewsDetailItem {
  id: string;
  title: string;
  summary: string;
  content: string;
  source: string;
  publishTime: string;
  coverImage: string;
  isFavorited: boolean;
}

@Entry
@Component
struct NewsDetailPage {
  @State news: NewsDetailItem | null = null;
  @State isLoading: boolean = true;
  @State isFavorited: boolean = false;

  aboutToAppear(): void {
    const params: Record<string, string> = router.getParams() as Record<string, string>;
    const newsId: string = params['newsId'];
    if (!newsId) {
      promptAction.showToast({ message: '缺少资讯参数' });
      router.back();
      return;
    }
    this.loadNews(newsId);
  }

  private async loadNews(newsId: string): Promise<void> {
    try {
      const allNews: NewsDetailItem[] | null = await JsonStoreUtil.readFromRaw<NewsDetailItem[]>('news.json');
      if (allNews) {
        for (let i = 0; i < allNews.length; i++) {
          if (allNews[i].id === newsId) {
            this.news = allNews[i];
            this.isFavorited = allNews[i].isFavorited;
            break;
          }
        }
      }
    } catch (err) {
      console.error('[NewsDetail] 加载资讯失败: ' + JSON.stringify(err));
    }
    this.isLoading = false;
    if (!this.news) {
      promptAction.showToast({ message: '未找到资讯内容' });
    }
  }

  /** 将纯文本中的 \n 分行显示 */
  private getContentLines(): string[] {
    if (!this.news) {
      return [];
    }
    return this.news.content.split('\n');
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24).fillColor($r('app.color.text_primary'))
          .onClick(() => { router.back(); })
        Blank()
        Text('资讯详情')
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
      } else if (!this.news) {
        Column({ space: 16 }) {
          SymbolGlyph($r('sys.symbol.doc_text')).fontSize(64)
          Text('未找到资讯内容').fontSize(26).fontColor($r('app.color.text_secondary'))
        }
        .layoutWeight(1).justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            // 标题区
            Column({ space: 12 }) {
              Text(this.news.title)
                .fontSize(28).fontWeight(700).fontColor($r('app.color.text_primary'))

              Row({ space: 16 }) {
                Text(this.news.source)
                  .fontSize(22).fontColor($r('app.color.primary'))

                Text(this.news.publishTime)
                  .fontSize(22).fontColor($r('app.color.text_secondary'))

                Blank()

                if (this.isFavorited) {
                  SymbolGlyph($r('sys.symbol.heart_fill')).fontSize(22)
                    .onClick(() => {
                      this.isFavorited = false;
                      promptAction.showToast({ message: '已取消收藏' });
                    })
                } else {
                  SymbolGlyph($r('sys.symbol.heart')).fontSize(22)
                    .onClick(() => {
                      this.isFavorited = true;
                      promptAction.showToast({ message: '已收藏' });
                    })
                }
              }
              .width('100%')
            }
            .width('100%').padding(16)
            .backgroundColor($r('app.color.card_white')).borderRadius(8)

            // 封面占位
            Stack() {
              Column()
                .width('100%').height(160)
                .backgroundColor($r('app.color.primary_light'))
                .borderRadius(8)
              SymbolGlyph($r('sys.symbol.doc_text')).fontSize(48)
            }

            // 正文
            Column({ space: 8 }) {
              ForEach(this.getContentLines(), (line: string, index: number) => {
                if (line.trim() === '') {
                  Blank().height(8)
                } else {
                  Text(line)
                    .fontSize(24).fontColor($r('app.color.text_primary'))
                    .lineHeight(36).width('100%')
                }
              }, (line: string, index: number) => line.substring(0, 20) + index.toString())
            }
            .width('100%').padding(16)
            .backgroundColor($r('app.color.card_white')).borderRadius(8)
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
