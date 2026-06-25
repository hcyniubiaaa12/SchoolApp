/**
 * LifeServiceTab.ets - 生活服务 Tab
 * 2×2 功能入口(失物招领/校园美食/音乐播放/校园工具)
 * 默认显示失物招领内容，点击入口切换
 */
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import { JsonStoreUtil } from '../../common/utils/JsonStoreUtil';
import { LostFoundDao, LostFoundRow } from '../../common/database/LostFoundDao';
import { FoodDao, FoodRow } from '../../common/database/FoodDao';

interface LifeEntryItem {
  name: string;
  symbol: Resource;
  color: Resource;
}

interface SongItem {
  id: string;
  title: string;
  artist: string;
  album: string;
  duration: number;
  filePath: string;
  coverPath: string;
}

@Component
export struct LifeServiceTab {
  @Prop isDarkMode: boolean = false;
  @Prop uiContext?: Context;
  @State currentEntry: number = 0;
  @State lostFoundList: LostFoundRow[] = [];
  @State lfFilterIndex: number = 0;
  @State foodList: FoodRow[] = [];
  @State songList: SongItem[] = [];
  @State currentSongIndex: number = 0;
  @State isPlaying: boolean = false;
  @State progressValue: number = 0;

  private entries: LifeEntryItem[] = [
    { name: '失物招领', symbol: $r('sys.symbol.magnifyingglass'), color: $r('app.color.warm_orange') },
    { name: '校园美食', symbol: $r('sys.symbol.star'), color: $r('app.color.warm_orange') },
    { name: '音乐播放', symbol: $r('sys.symbol.play_fill'), color: $r('app.color.primary') },
    { name: '校园工具', symbol: $r('sys.symbol.calculator'), color: $r('app.color.fresh_green') }
  ];

  private lfFilters: string[] = ['全部', '失物', '拾物', '校园卡', '电子产品'];

  aboutToAppear(): void {
    this.loadLostFound();
    this.loadFood();
    this.loadSongs();
  }

  private loadLostFound(): void {
    if (!this.uiContext) {
      return;
    }
    LostFoundDao.queryAll(this.uiContext).then((data: LostFoundRow[] | null) => {
      if (data) {
        this.lostFoundList = data;
      }
    });
  }

  private loadFood(): void {
    if (!this.uiContext) {
      return;
    }
    FoodDao.queryAll(this.uiContext).then((data: FoodRow[] | null) => {
      if (data) {
        this.foodList = data;
      }
    });
  }

  private loadSongs(): void {
    JsonStoreUtil.read<SongItem[]>('music.json').then((data: SongItem[] | null) => {
      if (data) {
        this.songList = data;
      }
    });
  }

  // —— 失物招领筛选 ——
  private getFilteredLostFound(): LostFoundRow[] {
    if (this.lfFilterIndex === 0) {
      return this.lostFoundList;
    }
    const filterText: string = this.lfFilters[this.lfFilterIndex];
    const result: LostFoundRow[] = [];
    for (let i = 0; i < this.lostFoundList.length; i++) {
      const item: LostFoundRow = this.lostFoundList[i];
      if (filterText === '失物' && item.type === 'lost') {
        result.push(item);
      } else if (filterText === '拾物' && item.type === 'found') {
        result.push(item);
      } else if (item.category === filterText) {
        result.push(item);
      }
    }
    return result;
  }

  // —— 美食 ——
  @Builder
  buildStarRow(rating: number) {
    Row({ space: 2 }) {
      ForEach([0, 1, 2, 3, 4] as number[], (i: number) => {
        if (i < rating) {
          Image($r('app.media.ic_star'))
            .width(18)
            .height(18)
        } else {
          SymbolGlyph($r('sys.symbol.star'))
            .fontSize(18)
            .fontColor([$r('app.color.text_secondary')])
        }
      }, (i: number) => i.toString())
    }
  }

  private toggleFoodFavorite(foodId: string): void {
    if (!this.uiContext) {
      return;
    }
    FoodDao.toggleFavorite(this.uiContext, foodId).then(() => {
      this.loadFood();
    });
  }

  // —— 音乐播放 ——
  private getCurrentSong(): SongItem {
    if (this.songList.length === 0) {
      return { id: '', title: '无歌曲', artist: '', album: '', duration: 0, filePath: '', coverPath: '' };
    }
    return this.songList[this.currentSongIndex];
  }

  private formatDuration(seconds: number): string {
    const min: number = Math.floor(seconds / 60);
    const sec: number = seconds % 60;
    return min.toString().padStart(2, '0') + ':' + sec.toString().padStart(2, '0');
  }

  private togglePlay(): void {
    this.isPlaying = !this.isPlaying;
  }

  private prevSong(): void {
    if (this.songList.length === 0) {
      return;
    }
    this.currentSongIndex = (this.currentSongIndex - 1 + this.songList.length) % this.songList.length;
    this.isPlaying = true;
    this.progressValue = 0;
  }

  private nextSong(): void {
    if (this.songList.length === 0) {
      return;
    }
    this.currentSongIndex = (this.currentSongIndex + 1) % this.songList.length;
    this.isPlaying = true;
    this.progressValue = 0;
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('生活服务')
          .fontSize(30)
          .fontWeight(600)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .backgroundColor($r('app.color.card_white'))
      Scroll() {
        Column({ space: 16 }) {
          // 2×2 功能入口
          Row({ space: 12 }) {
            ForEach(this.entries.slice(0, 2), (entry: LifeEntryItem) => {
              this.buildEntryCard(entry)
            }, (entry: LifeEntryItem) => entry.name)
          }
          .width('100%')
          .padding({ left: 20, right: 20 })

          Row({ space: 12 }) {
            ForEach(this.entries.slice(2, 4), (entry: LifeEntryItem) => {
              this.buildEntryCard(entry)
            }, (entry: LifeEntryItem) => entry.name)
          }
          .width('100%')
          .padding({ left: 20, right: 20 })

          // 内容区分隔线
          Row() {
            Text('▼ ' + this.entries[this.currentEntry].name)
              .fontSize(24)
              .fontColor($r('app.color.primary'))
              .fontWeight(600)
          }
          .width('100%')
          .padding({ left: 20 })

          // 内容区
          if (this.currentEntry === 0) {
            this.buildLostFoundContent()
          } else if (this.currentEntry === 1) {
            this.buildFoodContent()
          } else if (this.currentEntry === 2) {
            this.buildMusicContent()
          } else {
            this.buildToolsContent()
          }
        }
        .width('100%')
        .padding({ bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }

  @Builder
  buildEntryCard(entry: LifeEntryItem) {
    Column({ space: 8 }) {
      Stack() {
        Circle()
          .width(56)
          .height(56)
          .fill(entry.color)
          .opacity(0.1)
        SymbolGlyph(entry.symbol)
          .fontSize(28)
      }
      Text(entry.name)
        .fontSize(22)
        .fontColor(this.currentEntry === this.getEntryIndex(entry.name) ? $r('app.color.primary') : $r('app.color.text_primary'))
        .fontWeight(this.currentEntry === this.getEntryIndex(entry.name) ? 600 : 400)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 16, bottom: 16 })
    .backgroundColor(this.currentEntry === this.getEntryIndex(entry.name) ? $r('app.color.primary_light') : $r('app.color.card_white'))
    .borderRadius(8)
    .onClick(() => {
      this.currentEntry = this.getEntryIndex(entry.name);
    })
  }

  private getEntryIndex(name: string): number {
    for (let i = 0; i < this.entries.length; i++) {
      if (this.entries[i].name === name) {
        return i;
      }
    }
    return 0;
  }

  // ===== 失物招领 =====
  @Builder
  buildLostFoundContent() {
    Column({ space: 12 }) {
      // 发布信息按钮
      Button('发布信息')
        .width('100%')
        .height(48)
        .fontSize(26)
        .fontColor('#FFFFFF')
        .backgroundColor($r('app.color.warm_orange'))
        .borderRadius(8)
        .onClick(() => {
          router.pushUrl({ url: 'pages/life/LostFoundPublishPage' })
            .catch((err: Error) => {
              console.error('[LifeService] 跳转发布页失败: ' + err.message);
            });
        })

      // 筛选标签
      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.lfFilters, (filter: string, index: number) => {
            Text(filter)
              .fontSize(22)
              .fontColor(this.lfFilterIndex === index ? '#FFFFFF' : $r('app.color.text_primary'))
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
              .backgroundColor(this.lfFilterIndex === index ? $r('app.color.warm_orange') : $r('app.color.card_white'))
              .borderRadius(20)
              .onClick(() => {
                this.lfFilterIndex = index;
              })
          }, (filter: string, index: number) => filter + index.toString())
        }
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)

      // 列表
      if (this.getFilteredLostFound().length === 0) {
        Row() {
          Text('暂无信息')
            .fontSize(24)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .height(100)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      } else {
        ForEach(this.getFilteredLostFound(), (item: LostFoundRow) => {
          Row() {
            // 缩略图 64x64
            Stack() {
              Circle()
                .width(64)
                .height(64)
                .fill(item.type === 'lost' ? $r('app.color.warm_orange') : $r('app.color.primary_light'))
                .opacity(item.type === 'lost' ? 0.1 : 1)
              if (item.type === 'lost') {
                SymbolGlyph($r('sys.symbol.magnifyingglass'))
                  .fontSize(28)
              } else {
                SymbolGlyph($r('sys.symbol.pin'))
                  .fontSize(28)
              }
            }

            Column({ space: 4 }) {
              Row({ space: 8 }) {
                Text(item.itemName)
                  .fontSize(26)
                  .fontWeight(600)
                  .fontColor($r('app.color.text_primary'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text(item.type === 'lost' ? '失物' : '拾物')
                  .fontSize(20)
                  .fontColor(item.type === 'lost' ? $r('app.color.warm_orange') : $r('app.color.fresh_green'))
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .backgroundColor(item.type === 'lost' ? '#FFF3E0' : '#E8F8E0')
                  .borderRadius(4)
              }
              .width('100%')

              Text(item.location + ' · ' + item.time)
                .fontSize(22)
                .fontColor($r('app.color.text_secondary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 12 })
          }
          .width('100%')
          .padding(12)
          .backgroundColor($r('app.color.card_white'))
          .borderRadius(8)
          .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 1 })
          .alignItems(VerticalAlign.Center)
        }, (item: LostFoundRow) => item.id)
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20 })
  }

  // ===== 校园美食 =====
  @Builder
  buildFoodContent() {
    Column({ space: 12 }) {
      if (this.foodList.length === 0) {
        Row() {
          Text('暂无美食信息')
            .fontSize(24)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .height(100)
        .justifyContent(FlexAlign.Center)
      } else {
        ForEach(this.foodList, (food: FoodRow) => {
          Row() {
            // 美食图占位
            Stack() {
              Circle()
                .width(64)
                .height(64)
                .fill($r('app.color.warm_orange'))
                .opacity(0.1)
              Text('🍽️')
                .fontSize(28)
            }

            Column({ space: 4 }) {
              Row() {
                Text(food.name)
                  .fontSize(26)
                  .fontWeight(600)
                  .fontColor($r('app.color.text_primary'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .layoutWeight(1)

                if (food.isFavorited) {
                  SymbolGlyph($r('sys.symbol.heart_fill'))
                    .fontSize(22)
                    .fontColor([$r('app.color.primary')])
                    .onClick(() => {
                      this.toggleFoodFavorite(food.id);
                    })
                } else {
                  SymbolGlyph($r('sys.symbol.heart'))
                    .fontSize(22)
                    .fontColor([$r('app.color.text_secondary')])
                    .onClick(() => {
                      this.toggleFoodFavorite(food.id);
                    })
                }
              }
              .width('100%')

              Text(food.canteen)
                .fontSize(22)
                .fontColor($r('app.color.text_secondary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Row({ space: 8 }) {
                this.buildStarRow(food.rating)

                Text(food.signatureDish)
                  .fontSize(22)
                  .fontColor($r('app.color.text_secondary'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 12 })
          }
          .width('100%')
          .padding(12)
          .backgroundColor($r('app.color.card_white'))
          .borderRadius(8)
          .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 1 })
          .alignItems(VerticalAlign.Center)
        }, (food: FoodRow) => food.id)
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20 })
  }

  // ===== 音乐播放 =====
  @Builder
  buildMusicContent() {
    Column({ space: 16 }) {
      if (this.songList.length === 0) {
        Row() {
          Text('暂无音乐，请添加本地音频文件')
            .fontSize(24)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      } else {
        // 专辑封面（圆形，播放时旋转动画模拟）
        Stack() {
          Circle()
            .width(180)
            .height(180)
            .fill($r('app.color.primary_light'))
          Text('🎵')
            .fontSize(72)
            .fontColor($r('app.color.text_primary'))
        }
        .width('100%')
        .padding({ top: 24 })

        // 歌名 + 歌手
        Text(this.getCurrentSong().title)
          .fontSize(28)
          .fontWeight(700)
          .fontColor($r('app.color.text_primary'))
          .width('100%')
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.getCurrentSong().artist)
          .fontSize(24)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .textAlign(TextAlign.Center)
          .maxLines(1)

        // 进度条
        Row({ space: 8 }) {
          Text(this.formatDuration(this.progressValue))
            .fontSize(22)
            .fontColor($r('app.color.text_secondary'))

          Slider({
            value: this.progressValue,
            min: 0,
            max: this.getCurrentSong().duration,
            step: 1,
            style: SliderStyle.OutSet
          })
            .layoutWeight(1)
            .trackColor($r('app.color.border'))
            .selectedColor($r('app.color.primary'))
            .blockColor($r('app.color.primary'))
            .onChange((value: number) => {
              this.progressValue = value;
            })

          Text(this.formatDuration(this.getCurrentSong().duration))
            .fontSize(22)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .padding({ left: 20, right: 20 })

        // 控制按钮
        Row({ space: 32 }) {
          // 上一曲
          Button() {
            Text('⏪')
              .fontSize(32)
          }
          .width(48)
          .height(48)
          .backgroundColor($r('app.color.card_white'))
          .onClick(() => {
            this.prevSong();
          })

          // 播放/暂停
          Button() {
            if (this.isPlaying) {
              SymbolGlyph($r('sys.symbol.pause_fill'))
                .fontSize(40)
            } else {
              SymbolGlyph($r('sys.symbol.play_fill'))
                .fontSize(40)
            }
          }
          .width(64)
          .height(64)
          .backgroundColor($r('app.color.primary_light'))
          .borderRadius(32)
          .onClick(() => {
            this.togglePlay();
          })

          // 下一曲
          Button() {
            Text('⏩')
              .fontSize(32)
          }
          .width(48)
          .height(48)
          .backgroundColor($r('app.color.card_white'))
          .onClick(() => {
            this.nextSong();
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: 8 })

        // 本地音乐按钮
        Button('本地音乐')
          .width('60%')
          .height(44)
          .fontSize(24)
          .fontColor($r('app.color.primary'))
          .backgroundColor($r('app.color.primary_light'))
          .borderRadius(22)
          .margin({ top: 8 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/life/MusicListPage' }).catch((err: Error) => { console.error('[LifeService] 跳转音乐列表失败: ' + err.message); });
          })
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20, bottom: 32 })
    .backgroundColor($r('app.color.card_white'))
    .borderRadius(8)
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .alignItems(HorizontalAlign.Center)
  }

  // ===== 校园工具导航 =====
  private navigateToTool(name: string): void {
    let targetUrl: string = '';
    if (name === '计算器') {
      targetUrl = 'pages/life/CalculatorPage';
    } else if (name === '倒计时') {
      targetUrl = 'pages/life/CountdownPage';
    } else if (name === '快递查询') {
      targetUrl = 'pages/life/ExpressQueryPage';
    }
    if (targetUrl !== '') {
      router.pushUrl({ url: targetUrl })
        .catch((err: Error) => {
          console.error('[LifeService] 跳转工具页失败: ' + err.message);
        });
    } else {
      promptAction.showToast({ message: name + '功能即将开放' });
    }
  }

  // ===== 校园工具 =====
  @Builder
  buildToolsContent() {
    Column({ space: 16 }) {
      Row({ space: 12 }) {
        this.buildToolCard('🧮', '计算器', 0)
        this.buildToolCard('⏱️', '倒计时', 1)
      }
      .width('100%')
      .padding({ left: 20, right: 20 })

      Row({ space: 12 }) {
        this.buildToolCard('📦', '快递查询', 2)
        this.buildToolCard('🔧', '更多工具', 3)
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 24 })
    }
  }

  @Builder
  buildToolCard(icon: string, name: string, _index: number) {
    Column({ space: 12 }) {
      Text(icon)
        .fontSize(40)
      Text(name)
        .fontSize(26)
        .fontColor($r('app.color.text_primary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 32, bottom: 32 })
    .backgroundColor($r('app.color.card_white'))
    .borderRadius(8)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 1 })
    .onClick(() => {
      this.navigateToTool(name);
    })
  }
}
