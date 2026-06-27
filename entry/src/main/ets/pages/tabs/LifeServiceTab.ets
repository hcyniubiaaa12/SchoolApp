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
  @StorageLink('isDarkMode') isDarkMode: boolean = false;
  @StorageLink('fontScale') @Watch('onFontScaleChange') fontScale: number = 1.0;
  @State fsTitle: number = 32;
  @State fsMid: number = 28;
  @State fsBody: number = 26;
  @State fsSmall: number = 24;
  @State fsTiny: number = 22;
  @Prop uiContext?: Context;
  @Prop @Watch('onRefresh') refreshSignal: number = 0;
  @State currentEntry: number = 0;
  @State lostFoundList: LostFoundRow[] = [];
  @State foodList: FoodRow[] = [];
  @State filteredFoodList: FoodRow[] = [];
  @State foodSearchText: string = '';
  @State songList: SongItem[] = [];
  @State currentSongIndex: number = 0;
  @State isPlaying: boolean = false;
  @State progressValue: number = 0;


  private onFontScaleChange(): void {
    this.fsTitle = Math.round(32 * this.fontScale);
    this.fsMid = Math.round(28 * this.fontScale);
    this.fsBody = Math.round(26 * this.fontScale);
    this.fsSmall = Math.round(24 * this.fontScale);
    this.fsTiny = Math.round(22 * this.fontScale);
  }

  private entries: LifeEntryItem[] = [
    { name: '失物招领', symbol: $r('sys.symbol.magnifyingglass'), color: $r('app.color.warm_orange') },
    { name: '校园美食', symbol: $r('sys.symbol.star'), color: $r('app.color.warm_orange') },
    { name: '音乐播放', symbol: $r('sys.symbol.play_fill'), color: $r('app.color.primary') },
    { name: '校园工具', symbol: $r('sys.symbol.calculator'), color: $r('app.color.fresh_green') }
  ];

  aboutToAppear(): void {
    this.loadLostFound();
    this.loadFood();
    this.loadSongs();
  }

  private onRefresh(): void {
    this.loadLostFound();
    this.loadFood();
    this.foodSearchText = '';
  }

  /** 删除确认 */
  private deleteLostFoundItem(item: LostFoundRow): void {
    promptAction.showDialog({
      title: '确认删除',
      message: '确定要删除「' + item.itemName + '」吗？',
      buttons: [
        { text: '取消', color: '#86909C' },
        { text: '删除', color: '#FF7D00' }
      ]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1 && this.uiContext) {
        LostFoundDao.deleteById(this.uiContext, item.id).then(() => {
          promptAction.showToast({ message: '已删除' });
          this.loadLostFound();
        });
      }
    });
  }

  /** 跳转编辑页 */
  private editLostFoundItem(itemId: string): void {
    router.pushUrl({
      url: 'pages/life/LostFoundPublishPage',
      params: { editId: itemId }
    });
  }

  /** 点击查看详情——弹窗展示完整信息 */
  private viewDetail(item: LostFoundRow): void {
    const typeStr: string = item.type === 'lost' ? '【失物】' : '【拾物】';
    let msg: string = typeStr + item.itemName + '\n\n';
    msg += '分类：' + item.category + '\n';
    msg += '地点：' + item.location + '\n';
    msg += '时间：' + item.time;
    if (item.description.trim() !== '') {
      msg += '\n\n描述：' + item.description;
    }
    if (item.contactPhone.trim() !== '') {
      msg += '\n联系电话：' + item.contactPhone;
    }
    const buttons: promptAction.Button[] = [
      { text: '关闭', color: '#86909C' }
    ];
    promptAction.showDialog({
      title: '详情',
      message: msg,
      buttons: buttons
    });
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
        this.filteredFoodList = data;
      }
    });
  }

  private doFoodSearch(): void {
    if (this.foodSearchText.trim() === '') {
      this.filteredFoodList = this.foodList;
      return;
    }
    const keyword: string = this.foodSearchText.trim().toLowerCase();
    const result: FoodRow[] = [];
    for (let i = 0; i < this.foodList.length; i++) {
      const f: FoodRow = this.foodList[i];
      if (f.name.toLowerCase().includes(keyword) ||
          f.canteen.toLowerCase().includes(keyword) ||
          f.signatureDish.toLowerCase().includes(keyword)) {
        result.push(f);
      }
    }
    this.filteredFoodList = result;
  }

  private loadSongs(): void {
    JsonStoreUtil.read<SongItem[]>('music.json').then((data: SongItem[] | null) => {
      if (data) {
        this.songList = data;
      }
    });
  }

  // —— 失物招领筛选 ——
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
            .fontColor([this.isDarkMode ? '#A0A0A0' : '#86909C'])
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
          .fontSize(this.fsTitle)
          .fontWeight(600)
          .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .backgroundColor(this.isDarkMode ? '#252540' : $r('app.color.card_white'))
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
              .fontSize(this.fsSmall)
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
    .backgroundColor(this.isDarkMode ? '#1A1A2E' : $r('app.color.background'))
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
          .fontSize(this.fsMid)
      }
      Text(entry.name)
        .fontSize(this.fsTiny)
        .fontColor(this.currentEntry === this.getEntryIndex(entry.name) ? $r('app.color.primary') : this.isDarkMode ? '#E8E8E8' : '#1D2129')
        .fontWeight(this.currentEntry === this.getEntryIndex(entry.name) ? 600 : 400)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 16, bottom: 16 })
    .backgroundColor(this.currentEntry === this.getEntryIndex(entry.name) ? $r('app.color.primary_light') : (this.isDarkMode ? '#252540' : $r('app.color.card_white')))
    .borderRadius(8)
    .border({ width: { top: 3 }, color: entry.color })
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
        .fontSize(this.fsBody)
        .fontColor('#FFFFFF')
        .backgroundColor($r('app.color.warm_orange'))
        .borderRadius(8)
        .onClick(() => {
          router.pushUrl({ url: 'pages/life/LostFoundPublishPage' })
            .catch((err: Error) => {
              console.error('[LifeService] 跳转发布页失败: ' + err.message);
            });
        })

      // 列表
      if (this.lostFoundList.length === 0) {
        Row() {
          Text('暂无信息')
            .fontSize(this.fsSmall)
            .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
        }
        .width('100%')
        .height(100)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      } else {
        ForEach(this.lostFoundList, (item: LostFoundRow) => {
          Row() {
            // 缩略图 64x64（失物=橙底，拾物=蓝底）
            Stack() {
              Circle()
                .width(64)
                .height(64)
                .fill(item.type === 'lost' ? $r('app.color.card_bg_orange') : $r('app.color.card_bg_blue'))
              if (item.type === 'lost') {
                SymbolGlyph($r('sys.symbol.magnifyingglass'))
                  .fontSize(this.fsMid)
              } else {
                SymbolGlyph($r('sys.symbol.pin'))
                  .fontSize(this.fsMid)
              }
            }

            Column({ space: 4 }) {
              Row({ space: 8 }) {
                Text(item.itemName)
                  .fontSize(this.fsBody)
                  .fontWeight(600)
                  .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                if (item.category !== '') {
                  Text(item.category)
                    .fontSize(20)
                    .fontColor($r('app.color.warm_orange'))
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .backgroundColor($r('app.color.card_bg_orange'))
                    .borderRadius(4)
                }
              }
              .width('100%')

              Text(item.location + ' · ' + item.time)
                .fontSize(this.fsTiny)
                .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 12 })

            // 删除按钮（仅自己的发布）
            if (item.publisherId === AppStorage.get('userId')) {
              Button('删除')
                .height(32).fontSize(20)
                .fontColor($r('app.color.warm_orange'))
                .backgroundColor(this.isDarkMode ? '#3A3A5C' : $r('app.color.card_white'))
                .border({ width: 1, color: $r('app.color.warm_orange'), radius: 4 })
                .padding({ left: 10, right: 10 })
                .onClick(() => { this.deleteLostFoundItem(item); })
            }
          }
          .width('100%')
          .padding(12)
          .backgroundColor(this.isDarkMode ? '#252540' : $r('app.color.card_white'))
          .borderRadius(8)
          .border({ width: { top: 3 }, color: $r('app.color.warm_orange') })
          .shadow({ radius: 8, color: $r('app.color.shadow'), offsetX: 0, offsetY: 2 })
          .alignItems(VerticalAlign.Center)
          .onClick(() => { this.viewDetail(item); })
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
      // 美食搜索栏
      Row() {
        TextInput({ placeholder: '搜索美食名称/食堂...', text: this.foodSearchText })
          .height(44)
          .fontSize(this.fsSmall)
          .placeholderColor('#86909C')
          .borderRadius(24)
          .backgroundColor(this.isDarkMode ? '#1A1A2E' : '#F5F7FA')
          .layoutWeight(1)
          .onChange((value: string) => {
            this.foodSearchText = value;
          })
        Button('搜索')
          .height(40)
          .fontSize(this.fsSmall)
          .fontColor('#FFFFFF')
          .backgroundColor($r('app.color.primary'))
          .borderRadius(20)
          .margin({ left: 12 })
          .onClick(() => {
            this.doFoodSearch();
          })
      }
      .width('100%')

      if (this.filteredFoodList.length === 0) {
        Row() {
          Text('暂无美食信息')
            .fontSize(this.fsSmall)
            .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
        }
        .width('100%')
        .height(100)
        .justifyContent(FlexAlign.Center)
      } else {
        ForEach(this.filteredFoodList, (food: FoodRow) => {
          Row() {
            // 美食图占位（橙色背景）
            Stack() {
              Circle()
                .width(64)
                .height(64)
                .fill($r('app.color.card_bg_orange'))
              SymbolGlyph($r('sys.symbol.fork_knife'))
                .fontSize(this.fsMid)
            }

            Column({ space: 4 }) {
              Row() {
                Text(food.name)
                  .fontSize(this.fsBody)
                  .fontWeight(600)
                  .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .layoutWeight(1)

                if (food.isFavorited) {
                  SymbolGlyph($r('sys.symbol.heart_fill'))
                    .fontSize(this.fsTiny)
                    .fontColor([$r('app.color.primary')])
                    .onClick(() => {
                      this.toggleFoodFavorite(food.id);
                    })
                } else {
                  SymbolGlyph($r('sys.symbol.heart'))
                    .fontSize(this.fsTiny)
                    .fontColor([this.isDarkMode ? '#A0A0A0' : '#86909C'])
                    .onClick(() => {
                      this.toggleFoodFavorite(food.id);
                    })
                }
              }
              .width('100%')

              Text(food.canteen)
                .fontSize(this.fsTiny)
                .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Row({ space: 8 }) {
                this.buildStarRow(food.rating)

                Text(food.signatureDish)
                  .fontSize(this.fsTiny)
                  .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
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
          .backgroundColor(this.isDarkMode ? '#252540' : $r('app.color.card_white'))
          .borderRadius(8)
          .border({ width: { top: 3 }, color: $r('app.color.warm_orange') })
          .shadow({ radius: 8, color: $r('app.color.shadow'), offsetX: 0, offsetY: 2 })
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
            .fontSize(this.fsSmall)
            .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
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
            .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
        }
        .width('100%')
        .padding({ top: 24 })

        // 歌名 + 歌手
        Text(this.getCurrentSong().title)
          .fontSize(this.fsMid)
          .fontWeight(700)
          .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
          .width('100%')
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.getCurrentSong().artist)
          .fontSize(this.fsSmall)
          .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
          .width('100%')
          .textAlign(TextAlign.Center)
          .maxLines(1)

        // 进度条
        Row({ space: 8 }) {
          Text(this.formatDuration(this.progressValue))
            .fontSize(this.fsTiny)
            .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')

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
            .fontSize(this.fsTiny)
            .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
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
          .backgroundColor(this.isDarkMode ? '#3A3A5C' : $r('app.color.card_white'))
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
          .backgroundColor(this.isDarkMode ? '#3A3A5C' : $r('app.color.card_white'))
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
          .fontSize(this.fsSmall)
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
    .backgroundColor(this.isDarkMode ? '#252540' : $r('app.color.card_white'))
    .borderRadius(8)
    .border({ width: { top: 3 }, color: $r('app.color.primary') })
    .shadow({ radius: 8, color: $r('app.color.shadow'), offsetX: 0, offsetY: 2 })
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
        .fontSize(this.fsBody)
        .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 32, bottom: 32 })
    .backgroundColor(this.isDarkMode ? '#252540' : $r('app.color.card_white'))
    .borderRadius(8)
    .border({ width: { top: 3 }, color: $r('app.color.primary') })
    .shadow({ radius: 8, color: $r('app.color.shadow'), offsetX: 0, offsetY: 2 })
    .onClick(() => {
      this.navigateToTool(name);
    })
  }
}
