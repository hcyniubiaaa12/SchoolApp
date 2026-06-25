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
          .width(24).height(24).fillColor('#1D2129')
          .onClick(() => { router.back(); })
        Blank()
        Text('资讯详情')
          .fontSize(30).fontWeight(600).fontColor('#1D2129')
        Blank()
        Row().width(24)
      }
      .width('100%').height(56).padding({ left: 16, right: 20 })
      .backgroundColor('#FFFFFF').alignItems(VerticalAlign.Center)

      if (this.isLoading) {
        Column() {
          Text('加载中...').fontSize(26).fontColor('#86909C')
        }
        .layoutWeight(1).justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (!this.news) {
        Column({ space: 16 }) {
          Text('📰').fontSize(64)
          Text('未找到资讯内容').fontSize(26).fontColor('#86909C')
        }
        .layoutWeight(1).justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            // 标题区
            Column({ space: 12 }) {
              Text(this.news.title)
                .fontSize(28).fontWeight(700).fontColor('#1D2129')

              Row({ space: 16 }) {
                Text(this.news.source)
                  .fontSize(22).fontColor('#1677FF')

                Text(this.news.publishTime)
                  .fontSize(22).fontColor('#86909C')

                Blank()

                Text(this.isFavorited ? '❤️' : '🤍')
                  .fontSize(22)
                  .onClick(() => {
                    this.isFavorited = !this.isFavorited;
                    promptAction.showToast({ message: this.isFavorited ? '已收藏' : '已取消收藏' });
                  })
              }
              .width('100%')
            }
            .width('100%').padding(16)
            .backgroundColor('#FFFFFF').borderRadius(8)

            // 封面占位
            Stack() {
              Column()
                .width('100%').height(160)
                .backgroundColor('#E8F3FF')
                .borderRadius(8)
              Text('📰').fontSize(48)
            }

            // 正文
            Column({ space: 8 }) {
              ForEach(this.getContentLines(), (line: string, index: number) => {
                if (line.trim() === '') {
                  Blank().height(8)
                } else {
                  Text(line)
                    .fontSize(24).fontColor('#1D2129')
                    .lineHeight(36).width('100%')
                }
              }, (line: string, index: number) => line.substring(0, 20) + index.toString())
            }
            .width('100%').padding(16)
            .backgroundColor('#FFFFFF').borderRadius(8)
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 32 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
    }
    .width('100%').height('100%')
    .backgroundColor('#F5F7FA')
  }
}
