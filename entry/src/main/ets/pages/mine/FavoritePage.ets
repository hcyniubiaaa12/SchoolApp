/**
 * FavoritePage.ets - 我的收藏页
 * 统一展示收藏的公告/资讯/图书/美食，支持分类查看和删除
 */
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';

interface FavoriteItem {
  id: string;
  title: string;
  summary: string;
  type: string;
  saveTime: string;
}

@Entry
@Component
struct FavoritePage {
  @State favorites: FavoriteItem[] = [
    { id: 'f1', title: '关于2026年暑期放假安排的通知', summary: '根据学校校历安排...', type: '公告', saveTime: '2026-06-20' },
    { id: 'f2', title: '深入理解计算机系统', summary: 'Randal E. Bryant · 机械工业出版社', type: '图书', saveTime: '2026-06-15' },
    { id: 'f3', title: '麻辣香锅', summary: '一食堂 · 川味窗口', type: '美食', saveTime: '2026-06-10' },
    { id: 'f4', title: '我校在机器人大赛中荣获一等奖', summary: '我校机器人团队在全国赛中...', type: '资讯', saveTime: '2026-06-08' },
  ];
  @State currentFilter: string = '全部';

  private filters: string[] = ['全部', '公告', '资讯', '图书', '美食'];

  private getFilteredItems(): FavoriteItem[] {
    if (this.currentFilter === '全部') {
      return this.favorites;
    }
    const result: FavoriteItem[] = [];
    for (let i = 0; i < this.favorites.length; i++) {
      if (this.favorites[i].type === this.currentFilter) {
        result.push(this.favorites[i]);
      }
    }
    return result;
  }

  private deleteItem(id: string): void {
    const newList: FavoriteItem[] = [];
    for (let i = 0; i < this.favorites.length; i++) {
      if (this.favorites[i].id !== id) {
        newList.push(this.favorites[i]);
      }
    }
    this.favorites = newList;
    promptAction.showToast({ message: '已取消收藏' });
  }

  private getTypeIcon(type: string): string {
    if (type === '公告') return '📢';
    if (type === '资讯') return '📰';
    if (type === '图书') return '📚';
    if (type === '美食') return '🍽️';
    return '❤️';
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24).fillColor('#1D2129')
          .onClick(() => { router.back(); })
        Blank()
        Text('我的收藏')
          .fontSize(30).fontWeight(600).fontColor('#1D2129')
          .layoutWeight(1).textAlign(TextAlign.Center)
        Blank()
        Row().width(24)
      }
      .width('100%').height(56).padding({ left: 16, right: 20 })
      .backgroundColor('#FFFFFF').alignItems(VerticalAlign.Center)

      // 分类筛选
      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.filters, (filter: string, index: number) => {
            Text(filter)
              .fontSize(22)
              .fontColor(this.currentFilter === filter ? '#FFFFFF' : '#1D2129')
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
              .backgroundColor(this.currentFilter === filter ? '#1677FF' : '#F5F7FA')
              .borderRadius(20)
              .onClick(() => {
                this.currentFilter = filter;
              })
          }, (filter: string) => filter)
        }
        .padding({ left: 20, right: 20, top: 12, bottom: 12 })
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)
      .backgroundColor('#FFFFFF')

      // 收藏列表
      Scroll() {
        Column({ space: 12 }) {
          if (this.getFilteredItems().length === 0) {
            Column({ space: 16 }) {
              Text('💔')
                .fontSize(48)
              Text('暂无收藏内容')
                .fontSize(26)
                .fontColor('#86909C')
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          } else {
            ForEach(this.getFilteredItems(), (item: FavoriteItem) => {
              Row() {
                Stack() {
                  Circle()
                    .width(44)
                    .height(44)
                    .fill('#E8F3FF')
                  Text(this.getTypeIcon(item.type))
                    .fontSize(24)
                }

                Column({ space: 4 }) {
                  Row({ space: 8 }) {
                    Text(item.title)
                      .fontSize(26)
                      .fontWeight(600)
                      .fontColor('#1D2129')
                      .layoutWeight(1)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })

                    Text(item.type)
                      .fontSize(20)
                      .fontColor('#1677FF')
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .backgroundColor('#E8F3FF')
                      .borderRadius(4)
                  }
                  .width('100%')

                  Row() {
                    Text(item.summary)
                      .fontSize(22)
                      .fontColor('#86909C')
                      .layoutWeight(1)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })

                Text('🗑️')
                  .fontSize(22)
                  .onClick(() => {
                    this.deleteItem(item.id);
                  })
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 1 })
              .alignItems(VerticalAlign.Center)
            }, (item: FavoriteItem) => item.id)
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 12, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%').height('100%')
    .backgroundColor('#F5F7FA')
  }
}
