/**
 * SearchPage.ets - 搜索结果页
 * 首页搜索栏点击进入，展示搜索框 + 分类结果
 */
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import { JsonStoreUtil } from '../../common/utils/JsonStoreUtil';
import { AnnouncementItem } from '../../common/model/Announcement';
import { NewsItem } from '../../common/model/News';
import { SongItem } from '../../common/model/Music';
import { LostFoundItem } from '../../common/model/LostFound';
import { CourseDao, CourseRow } from '../../common/database/CourseDao';
import { ScoreDao, ScoreRow } from '../../common/database/ScoreDao';
import { BookDao, BookRow } from '../../common/database/BookDao';
import { LostFoundDao, LostFoundRow } from '../../common/database/LostFoundDao';
import { FoodDao, FoodRow } from '../../common/database/FoodDao';
import { WeatherDao, WeatherRow } from '../../common/database/WeatherDao';

interface MaterialItem {
  name: string;
  type: string;
}

interface MaterialFolder {
  id: string;
  folderName: string;
  icon: string;
  items: MaterialItem[];
}

interface SearchResultItem {
  id: string;
  title: string;
  subTitle: string;
  type: string;
  searchableText: string;
  routeUrl: string;
}

@Entry
@Component
struct SearchPage {
  @State searchText: string = '';
  @State results: SearchResultItem[] = [];
  @State hasSearched: boolean = false;
  @State isLoading: boolean = false;
  @State searchScopeText: string = '搜索范围：公告、资讯、课程、成绩、图书、美食、失物招领、学习资料、音乐、天气';
  private allData: SearchResultItem[] = [];

  aboutToAppear(): void {
    this.loadSearchData();
  }

  private async loadSearchData(): Promise<void> {
    this.isLoading = true;
    const ctx: Context = getContext(this);
    const list: SearchResultItem[] = [];
    try {
      await this.appendRdbData(ctx, list);
      await this.appendJsonData(list);
      this.allData = list;
    } catch (e) {
      console.error('[SearchPage] 加载搜索数据失败: ' + JSON.stringify(e));
    }
    this.isLoading = false;
  }

  private async appendRdbData(ctx: Context, list: SearchResultItem[]): Promise<void> {
    const courses: CourseRow[] = await CourseDao.queryAll(ctx);
    for (let i = 0; i < courses.length; i++) {
      const item: CourseRow = courses[i];
      list.push(this.createResult(item.id, item.name,
        item.location + ' · ' + item.teacher + ' · 第' + item.startWeek.toString() + '-' + item.endWeek.toString() + '周',
        '课程', item.name + ' ' + item.teacher + ' ' + item.location + ' ' + item.courseType + ' ' + item.remark, ''));
    }

    const scores: ScoreRow[] = await ScoreDao.queryAll(ctx);
    for (let i = 0; i < scores.length; i++) {
      const item: ScoreRow = scores[i];
      list.push(this.createResult(item.id, item.courseName,
        '成绩 ' + item.score.toString() + ' · 绩点 ' + item.gpa.toString() + ' · ' + item.semester,
        '成绩', item.courseName + ' ' + item.semester + ' ' + item.examTime + ' ' + item.score.toString(), ''));
    }

    const books: BookRow[] = await BookDao.queryAll(ctx);
    for (let i = 0; i < books.length; i++) {
      const item: BookRow = books[i];
      list.push(this.createResult(item.id, item.title,
        item.author + ' · ' + item.location + ' · 可借' + item.availableCount.toString() + '/' + item.totalCount.toString(),
        '图书', item.title + ' ' + item.author + ' ' + item.publisher + ' ' + item.isbn + ' ' + item.location + ' ' + item.summary,
        'pages/study/BookDetailPage'));
    }

    const foods: FoodRow[] = await FoodDao.queryAll(ctx);
    for (let i = 0; i < foods.length; i++) {
      const item: FoodRow = foods[i];
      list.push(this.createResult(item.id, item.name,
        item.canteen + ' · ' + item.signatureDish + ' · ' + item.rating.toString() + '星',
        '美食', item.name + ' ' + item.canteen + ' ' + item.signatureDish + ' ' + item.tags, ''));
    }

    const lostItems: LostFoundRow[] = await LostFoundDao.queryAll(ctx);
    for (let i = 0; i < lostItems.length; i++) {
      const item: LostFoundRow = lostItems[i];
      list.push(this.createResult(item.id, item.itemName,
        this.getLostFoundTypeName(item.type) + ' · ' + item.location + ' · ' + item.time,
        '失物', item.itemName + ' ' + item.category + ' ' + item.location + ' ' + item.description + ' ' + item.type + ' ' + item.status, ''));
    }

    const weatherList: WeatherRow[] = await WeatherDao.queryAll(ctx);
    for (let i = 0; i < weatherList.length; i++) {
      const item: WeatherRow = weatherList[i];
      list.push(this.createResult(item.id, item.dateText + ' ' + item.weather,
        item.weekDay + ' · ' + item.tempLow.toString() + '-' + item.tempHigh.toString() + '℃',
        '天气', item.dateText + ' ' + item.weekDay + ' ' + item.weather, 'pages/common/WeatherDetailPage'));
    }
  }

  private async appendJsonData(list: SearchResultItem[]): Promise<void> {
    const announcements: AnnouncementItem[] | null = await JsonStoreUtil.read<AnnouncementItem[]>('announcements.json');
    if (announcements) {
      for (let i = 0; i < announcements.length; i++) {
        const item: AnnouncementItem = announcements[i];
        list.push(this.createResult(item.id, item.title, item.source + ' · ' + item.publishTime,
          '公告', item.title + ' ' + item.summary + ' ' + item.content + ' ' + item.category + ' ' + item.source, ''));
      }
    }

    const newsList: NewsItem[] | null = await JsonStoreUtil.read<NewsItem[]>('news.json');
    if (newsList) {
      for (let i = 0; i < newsList.length; i++) {
        const item: NewsItem = newsList[i];
        list.push(this.createResult(item.id, item.title, item.source + ' · ' + item.publishTime,
          '资讯', item.title + ' ' + item.summary + ' ' + item.content + ' ' + item.source, 'pages/campus/NewsDetailPage'));
      }
    }

    const materials: MaterialFolder[] | null = await JsonStoreUtil.read<MaterialFolder[]>('study_materials.json');
    if (materials) {
      for (let i = 0; i < materials.length; i++) {
        const folder: MaterialFolder = materials[i];
        list.push(this.createResult(folder.id, folder.folderName, '学习资料文件夹',
          '资料', folder.folderName + ' ' + this.getMaterialText(folder), ''));
        for (let j = 0; j < folder.items.length; j++) {
          const item: MaterialItem = folder.items[j];
          list.push(this.createResult(folder.id + '_' + j.toString(), item.name, folder.folderName + ' · ' + item.type,
            '资料', item.name + ' ' + item.type + ' ' + folder.folderName, ''));
        }
      }
    }

    const songs: SongItem[] | null = await JsonStoreUtil.read<SongItem[]>('music.json');
    if (songs) {
      for (let i = 0; i < songs.length; i++) {
        const item: SongItem = songs[i];
        list.push(this.createResult(item.id, item.title, item.artist + ' · ' + item.album,
          '音乐', item.title + ' ' + item.artist + ' ' + item.album, 'pages/life/MusicListPage'));
      }
    }

    const rawLostItems: LostFoundItem[] | null = await JsonStoreUtil.read<LostFoundItem[]>('lostfound.json');
    if (rawLostItems) {
      for (let i = 0; i < rawLostItems.length; i++) {
        const item: LostFoundItem = rawLostItems[i];
        list.push(this.createResult(item.id, item.itemName, this.getLostFoundTypeName(item.type) + ' · ' + item.location + ' · ' + item.time,
          '失物', item.itemName + ' ' + item.category + ' ' + item.location + ' ' + item.description + ' ' + item.type + ' ' + item.status, ''));
      }
    }
  }

  private createResult(id: string, title: string, subTitle: string, type: string, searchableText: string, routeUrl: string): SearchResultItem {
    return {
      id: id,
      title: title,
      subTitle: subTitle,
      type: type,
      searchableText: (title + ' ' + subTitle + ' ' + searchableText).toLowerCase(),
      routeUrl: routeUrl
    };
  }

  private getMaterialText(folder: MaterialFolder): string {
    let text: string = '';
    for (let i = 0; i < folder.items.length; i++) {
      const item: MaterialItem = folder.items[i];
      text += ' ' + item.name + ' ' + item.type;
    }
    return text;
  }

  private getLostFoundTypeName(type: string): string {
    if (type === 'found') {
      return '拾物';
    }
    return '失物';
  }

  private doSearch(): void {
    const keyword: string = this.searchText.trim().toLowerCase();
    if (keyword === '') {
      promptAction.showToast({ message: '请输入搜索内容' });
      return;
    }
    if (this.isLoading) {
      promptAction.showToast({ message: '搜索数据加载中，请稍后再试' });
      return;
    }
    const matched: SearchResultItem[] = [];
    for (let i = 0; i < this.allData.length; i++) {
      const item: SearchResultItem = this.allData[i];
      if (item.searchableText.includes(keyword)) {
        matched.push(item);
      }
    }
    this.results = matched;
    this.hasSearched = true;
  }

  private openResult(item: SearchResultItem): void {
    if (item.routeUrl === 'pages/study/BookDetailPage') {
      router.pushUrl({ url: item.routeUrl, params: { bookId: item.id } });
      return;
    }
    if (item.routeUrl === 'pages/campus/NewsDetailPage') {
      router.pushUrl({ url: item.routeUrl, params: { newsId: item.id } });
      return;
    }
    if (item.routeUrl !== '') {
      router.pushUrl({ url: item.routeUrl });
      return;
    }
    promptAction.showToast({ message: item.type + '结果暂不支持跳转详情' });
  }

  build() {
    Column() {
      // 导航栏 + 搜索框
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24).fillColor($r('app.color.text_primary'))
          .margin({ right: 12 })
          .onClick(() => {
            router.back();
          })

        TextInput({ placeholder: '搜索校园信息/课程/美食', text: this.searchText })
          .height(44)
          .fontSize(24)
          .placeholderColor($r('app.color.text_secondary'))
          .borderRadius(24)
          .backgroundColor($r('app.color.background'))
          .layoutWeight(1)
          .onChange((value: string) => {
            this.searchText = value;
          })
          .onSubmit(() => {
            this.doSearch();
          })

        Text('搜索')
          .fontSize(24)
          .fontColor($r('app.color.primary'))
          .margin({ left: 12 })
          .onClick(() => {
            this.doSearch();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 20 })
      .backgroundColor($r('app.color.card_white'))
      .alignItems(VerticalAlign.Center)

      if (!this.hasSearched) {
        // 搜索前：热门搜索推荐，整体贴近搜索栏展示
        Column({ space: 12 }) {
          Text('热门搜索')
            .fontSize(28)
            .fontWeight(700)
            .fontColor($r('app.color.text_primary'))
            .width('100%')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Scroll() {
            Row({ space: 12 }) {
              this.buildHotTag('期末考试')
              this.buildHotTag('课程表')
              this.buildHotTag('图书馆')
            }
          }
          .width('100%')
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)

          Scroll() {
            Row({ space: 12 }) {
              this.buildHotTag('校园美食')
              this.buildHotTag('失物招领')
              this.buildHotTag('成绩查询')
            }
          }
          .width('100%')
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)

          Text(this.searchScopeText)
            .fontSize(22)
            .fontColor($r('app.color.text_secondary'))
            .width('100%')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          if (this.isLoading) {
            Text('正在加载本地搜索数据...')
              .fontSize(22)
              .fontColor($r('app.color.primary'))
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 20 })
        .alignItems(HorizontalAlign.Start)
      } else {
        // 搜索结果列表：统计文字与结果卡片连续排列，避免单条结果被剩余区域拉低
        Column({ space: 12 }) {
          Text('找到 ' + this.results.length.toString() + ' 个结果')
            .fontSize(24)
            .fontColor($r('app.color.text_secondary'))
            .width('100%')

          if (this.results.length === 0) {
            Column({ space: 16 }) {
              SymbolGlyph($r('sys.symbol.questionmark_circle'))
                .fontSize(64)
              Text('未找到相关内容')
                .fontSize(26)
                .fontColor($r('app.color.text_secondary'))
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          } else {
            ForEach(this.results, (item: SearchResultItem) => {
              Column({ space: 4 }) {
                Row({ space: 8 }) {
                  Text(item.title)
                    .fontSize(26)
                    .fontWeight(600)
                    .fontColor($r('app.color.text_primary'))
                    .layoutWeight(1)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  Text(item.type)
                    .fontSize(20)
                    .fontColor(this.getTypeColor(item.type))
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .backgroundColor(this.getTypeBgColor(item.type))
                    .borderRadius(4)
                }
                .width('100%')

                Text(item.subTitle)
                  .fontSize(22)
                  .fontColor($r('app.color.text_secondary'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.card_white'))
              .borderRadius(8)
              .border({ width: { top: 3 }, color: this.getTypeColor(item.type) })
              .shadow({ radius: 8, color: $r('app.color.shadow'), offsetX: 0, offsetY: 2 })
              .alignItems(HorizontalAlign.Start)
              .onClick(() => {
                this.openResult(item);
              })
            }, (item: SearchResultItem, index: number) => item.type + item.id + index.toString())
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 24 })
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }

  // 搜索类型对应的分类色
  private getTypeColor(type: string): Resource {
    if (type === '公告' || type === '课程' || type === '图书' || type === '资讯' || type === '资料' || type === '天气') {
      return $r('app.color.primary');
    }
    if (type === '美食' || type === '失物' || type === '音乐') {
      return $r('app.color.warm_orange');
    }
    return $r('app.color.text_secondary');
  }

  private getTypeBgColor(type: string): Resource {
    if (type === '公告' || type === '课程' || type === '图书' || type === '资讯' || type === '资料' || type === '天气') {
      return $r('app.color.card_bg_blue');
    }
    if (type === '美食' || type === '失物' || type === '音乐') {
      return $r('app.color.card_bg_orange');
    }
    return $r('app.color.background');
  }

  @Builder
  buildHotTag(tag: string) {
    Text(tag)
      .fontSize(24)
      .fontColor($r('app.color.text_primary'))
      .padding({ left: 16, right: 16, top: 6, bottom: 6 })
      .backgroundColor($r('app.color.card_white'))
      .borderRadius(20)
      .shadow({ radius: 4, color: $r('app.color.shadow'), offsetX: 0, offsetY: 1 })
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .onClick(() => {
        this.searchText = tag;
        this.doSearch();
      })
  }
}
