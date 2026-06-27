/**
 * FavoritePage.ets - 我的收藏页
 * 从 RDB 加载收藏的图书/美食数据，支持取消收藏
 *
 * 数据源：
 *   - BookDao（is_favorited = 1）
 *   - FoodDao（is_favorited = 1）
 * 公告/资讯收藏暂为内存数据，后续扩展
 */
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import { BookDao, BookRow } from '../../common/database/BookDao';
import { FoodDao, FoodRow } from '../../common/database/FoodDao';
import { TitleBar } from '../../common/components/TitleBar';

interface FavoriteItem {
  id: string;
  title: string;
  summary: string;
  type: string;
  saveTime: string;
  sourceType: string;  // 'book' | 'food'
  sourceId: string;
}

@Entry
@Component
struct FavoritePage {
  @State favorites: FavoriteItem[] = [];
  @State currentFilter: string = '全部';
  @State isLoading: boolean = true;
  @StorageLink('isDarkMode') isDarkMode: boolean = false;

  private filters: string[] = ['全部', '图书', '美食'];

  aboutToAppear(): void {
    this.loadFavorites();
  }

  private async loadFavorites(): Promise<void> {
    this.isLoading = true;
    const ctx: Context = getContext(this);
    const allItems: FavoriteItem[] = [];

    try {
      // 从 RDB 加载收藏的图书
      const books: BookRow[] | null = await BookDao.queryAll(ctx);
      if (books) {
        for (let i = 0; i < books.length; i++) {
          const b: BookRow = books[i];
          if (b.isFavorited === 1) {
            allItems.push({
              id: 'fav_book_' + b.id,
              title: b.title,
              summary: b.author + ' · ' + b.publisher,
              type: '图书',
              saveTime: '',
              sourceType: 'book',
              sourceId: b.id
            });
          }
        }
      }

      // 从 RDB 加载收藏的美食
      const foods: FoodRow[] | null = await FoodDao.queryAll(ctx);
      if (foods) {
        for (let i = 0; i < foods.length; i++) {
          const f: FoodRow = foods[i];
          if (f.isFavorited === 1) {
            allItems.push({
              id: 'fav_food_' + f.id,
              title: f.name,
              summary: f.canteen + ' · ' + f.signatureDish,
              type: '美食',
              saveTime: '',
              sourceType: 'food',
              sourceId: f.id
            });
          }
        }
      }
    } catch (err) {
      console.error('[FavoritePage] 加载收藏失败: ' + JSON.stringify(err));
    }

    this.favorites = allItems;
    this.isLoading = false;
  }

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

  private async deleteItem(item: FavoriteItem): Promise<void> {
    try {
      const ctx: Context = getContext(this);
      if (item.sourceType === 'book') {
        await BookDao.toggleFavorite(ctx, item.sourceId);
      } else if (item.sourceType === 'food') {
        await FoodDao.toggleFavorite(ctx, item.sourceId);
      }
      // 从列表移除
      const newList: FavoriteItem[] = [];
      for (let i = 0; i < this.favorites.length; i++) {
        if (this.favorites[i].id !== item.id) {
          newList.push(this.favorites[i]);
        }
      }
      this.favorites = newList;
      promptAction.showToast({ message: '已取消收藏' });
    } catch (err) {
      console.error('[FavoritePage] 取消收藏失败: ' + JSON.stringify(err));
      promptAction.showToast({ message: '操作失败，请重试' });
    }
  }

  build() {
    Column() {
      // 导航栏
      TitleBar({ title: '我的收藏', showBack: true, onBackClick: () => { router.back(); } })

      // 分类筛选
      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.filters, (filter: string) => {
            Text(filter)
              .fontSize(22)
              .fontColor(this.currentFilter === filter ? Color.White : (this.isDarkMode ? '#E8E8E8' : '#1D2129'))
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
              .backgroundColor(this.currentFilter === filter ? $r('app.color.primary') : (this.isDarkMode ? '#3A3A5C' : $r('app.color.background')))
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
      .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')

      // 收藏列表
      Scroll() {
        if (this.isLoading) {
          Column() {
            Text('加载中...')
              .fontSize(26).fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
          }
          .width('100%').height(200)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          Column({ space: 12 }) {
            if (this.getFilteredItems().length === 0) {
              Column({ space: 16 }) {
                SymbolGlyph($r('sys.symbol.heart'))
                  .fontSize(48)
                  .fontColor([this.isDarkMode ? '#A0A0A0' : '#86909C'])
                Text('暂无收藏内容')
                  .fontSize(26).fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
                Row({ space: 4 }) {
                  Text('在图书馆或美食页点击')
                    .fontSize(22).fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
                  SymbolGlyph($r('sys.symbol.heart_fill'))
                    .fontSize(22)
                    .fontColor([$r('app.color.primary')])
                  Text('收藏吧')
                    .fontSize(22).fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
                }
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
              }
              .width('100%').height(200)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            } else {
              ForEach(this.getFilteredItems(), (item: FavoriteItem) => {
                Row() {
                  Stack() {
                    Circle()
                      .width(44).height(44)
                      .fill($r('app.color.primary_light'))
                    if (item.type === '图书') {
                      Image($r('app.media.ic_book'))
                        .width(24)
                        .height(24)
                    } else {
                      SymbolGlyph($r('sys.symbol.star'))
                        .fontSize(24)
                        .fontColor([$r('app.color.primary')])
                    }
                  }

                  Column({ space: 4 }) {
                    Row({ space: 8 }) {
                      Text(item.title)
                        .fontSize(26).fontWeight(600)
                        .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
                        .layoutWeight(1)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })

                      Text(item.type)
                        .fontSize(20)
                        .fontColor($r('app.color.primary'))
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .backgroundColor($r('app.color.primary_light'))
                        .borderRadius(4)
                    }
                    .width('100%')

                    Row() {
                      Text(item.summary)
                        .fontSize(22)
                        .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
                        .layoutWeight(1)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    .width('100%')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: 12 })

                  SymbolGlyph($r('sys.symbol.trash'))
                    .fontSize(22)
                    .fontColor([this.isDarkMode ? '#A0A0A0' : '#86909C'])
                    .onClick(() => {
                      this.deleteItem(item);
                    })
                }
                .width('100%')
                .padding(12)
                .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')
                .borderRadius(8)
                .shadow({ radius: 4, color: this.isDarkMode ? '#00000033' : '#1A000000', offsetX: 0, offsetY: 1 })
                .alignItems(VerticalAlign.Center)
              }, (item: FavoriteItem) => item.id)
            }
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 12, bottom: 24 })
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%').height('100%')
    .backgroundColor(this.isDarkMode ? '#1A1A2E' : '#F5F7FA')
  }
}
