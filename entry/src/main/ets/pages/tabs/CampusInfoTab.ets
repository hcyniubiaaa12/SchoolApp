/**
 * CampusInfoTab.ets - 校园信息 Tab
 * 5 分类标签横滚（校园公告/校园资讯/社团活动/学术讲座/校园地图）
 * 默认选中校园公告，地图标签走专属布局
 */
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import { JsonStoreUtil } from '../../common/utils/JsonStoreUtil';

interface TagItem {
  name: string;
}

interface AnnouncementItem {
  id: string;
  title: string;
  summary: string;
  content: string;
  category: string;
  source: string;
  publishTime: string;
  coverImage: string;
  isFavorited: boolean;
  isRead: boolean;
}

interface NewsItem {
  id: string;
  title: string;
  summary: string;
  content: string;
  source: string;
  publishTime: string;
  coverImage: string;
  isFavorited: boolean;
}

interface ActivityItem {
  id: string;
  title: string;
  organizer: string;
  time: string;
  location: string;
  summary: string;
  tag: string;
}

interface LectureItem {
  id: string;
  title: string;
  speaker: string;
  time: string;
  location: string;
  summary: string;
}

interface MapBuilding {
  name: string;
  description: string;
  x: number;   // 百分比坐标
  y: number;
}

@Component
export struct CampusInfoTab {
  @StorageLink('isDarkMode') isDarkMode: boolean = false;
  @StorageLink('fontScale') @Watch('onFontScaleChange') fontScale: number = 1.0;
  @State fsTitle: number = 30;
  @State fsMid: number = 28;
  @State fsBody: number = 26;
  @State fsSmall: number = 24;
  @State fsTiny: number = 22;

  private onFontScaleChange(): void {
    this.fsTitle = Math.round(30 * this.fontScale);
    this.fsMid = Math.round(28 * this.fontScale);
    this.fsBody = Math.round(26 * this.fontScale);
    this.fsSmall = Math.round(24 * this.fontScale);
    this.fsTiny = Math.round(22 * this.fontScale);
  }
  @State currentTagIndex: number = 0;
  @State announcements: AnnouncementItem[] = [];
  @State news: NewsItem[] = [];
  @State activities: ActivityItem[] = [];
  @State lectures: LectureItem[] = [];
  @State selectedAnnouncement: AnnouncementItem | null = null;
  @State showAnnouncementDetail: boolean = false;
  @State mapSearchText: string = '';
  @State selectedBuilding: number = -1;

  private tags: TagItem[] = [
    { name: '校园公告' }, { name: '校园资讯' },
    { name: '社团活动' }, { name: '学术讲座' }, { name: '校园地图' }
  ];

  // 预设模拟数据（地图建筑坐标用百分比）
  private buildings: MapBuilding[] = [
    { name: '教学楼', description: '主教学楼，共6层，设有多媒体教室、阶梯教室', x: 30, y: 15 },
    { name: '图书馆', description: '图书馆，藏书丰富，设有自习区、电子阅览室', x: 65, y: 10 },
    { name: '食堂', description: '第一食堂，提供早中晚餐，种类丰富', x: 20, y: 50 },
    { name: '宿舍', description: '学生宿舍区，包括1-8栋宿舍楼', x: 70, y: 55 },
    { name: '体育馆', description: '体育馆，设有篮球场、羽毛球场、游泳池', x: 50, y: 65 },
    { name: '实验楼', description: '实验楼，设有各类专业实验室', x: 15, y: 20 }
  ];

  // 社团活动模拟数据
  private activityData: ActivityItem[] = [
    { id: 'act1', title: '2026年校园歌手大赛海选', organizer: '校学生会文艺部', time: '2026-07-05 14:00', location: '学生活动中心', summary: '一年一度的校园歌手大赛海选即将开始，欢迎全校同学踊跃报名参加！', tag: '文艺' },
    { id: 'act2', title: '计算机协会技术沙龙：Web3.0入门', organizer: '计算机协会', time: '2026-06-28 19:00', location: '信软楼报告厅', summary: '本次沙龙将介绍Web3.0的基础概念、技术栈与发展趋势。', tag: '技术' },
    { id: 'act3', title: '暑期支教志愿者招募', organizer: '青年志愿者协会', time: '2026-06-25 10:00', location: '学生活动中心', summary: '面向全校招募暑期支教志愿者，支教地点为云南山区小学。', tag: '公益' }
  ];

  // 学术讲座模拟数据
  private lectureData: LectureItem[] = [
    { id: 'lec1', title: '人工智能前沿：大模型技术进展', speaker: '张华 教授（中国科学院）', time: '2026-07-02 15:00', location: '信软楼报告厅', summary: '介绍大语言模型的最新技术进展、挑战与未来发展方向。' },
    { id: 'lec2', title: '量子计算基础与应用展望', speaker: '李明 研究员（中国科学技术大学）', time: '2026-06-30 14:00', location: '公教楼学术报告厅', summary: '量子计算的基本原理、当前技术发展水平及未来应用前景。' },
    { id: 'lec3', title: '碳中和背景下的能源转型', speaker: '王芳 教授（清华大学）', time: '2026-06-26 16:00', location: '公教楼508', summary: '探讨碳达峰、碳中和目标下我国能源结构转型的路径与挑战。' }
  ];

  aboutToAppear(): void {
    this.loadAnnouncements();
    this.loadNews();
  }

  private loadAnnouncements(): void {
    JsonStoreUtil.read<AnnouncementItem[]>('announcements.json').then((data: AnnouncementItem[] | null) => {
      if (data) {
        this.announcements = data;
      }
    });
  }

  private loadNews(): void {
    JsonStoreUtil.read<NewsItem[]>('news.json').then((data: NewsItem[] | null) => {
      if (data) {
        this.news = data;
      }
    });
  }

  private showDetail(item: AnnouncementItem): void {
    this.selectedAnnouncement = item;
    this.showAnnouncementDetail = true;
  }

  private closeDetail(): void {
    this.showAnnouncementDetail = false;
    this.selectedAnnouncement = null;
  }

  private formatContent(content: string): string {
    return content.replace(/\n/g, '\n');
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航栏
        Row() {
          Text('校园信息')
            .fontSize(this.fsTitle)
            .fontWeight(600)
            .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .height(56)
        .padding({ left: 20, right: 20 })
        .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')

        // 分类标签栏（横向滚动）
        Scroll() {
          Row({ space: 12 }) {
            ForEach(this.tags, (tag: TagItem, index: number) => {
              Text(tag.name)
                .fontSize(this.fsTiny)
                .fontColor(this.currentTagIndex === index ? '#FFFFFF' : this.isDarkMode ? '#E8E8E8' : '#1D2129')
                .padding({ left: 16, right: 16, top: 6, bottom: 6 })
                .backgroundColor(this.currentTagIndex === index ? $r('app.color.primary') : (this.isDarkMode ? '#3A3A5C' : $r('app.color.background')))
                .borderRadius(20)
                .onClick(() => {
                  this.currentTagIndex = index;
                })
            }, (tag: TagItem, index: number) => tag.name + index.toString())
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 12, bottom: 12 })
        }
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Horizontal)
        .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')

        // 内容区
        if (this.currentTagIndex === 0) {
          this.buildAnnouncementList()
        } else if (this.currentTagIndex === 1) {
          this.buildNewsList()
        } else if (this.currentTagIndex === 2) {
          this.buildActivityList()
        } else if (this.currentTagIndex === 3) {
          this.buildLectureList()
        } else {
          this.buildCampusMap()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.isDarkMode ? '#1A1A2E' : '#F5F7FA')

      // 详情弹窗
      if (this.showAnnouncementDetail && this.selectedAnnouncement) {
        this.buildDetailLayer()
      }
    }
    .width('100%')
    .height('100%')
  }

  // ===== 校园公告列表 =====
  @Builder
  buildAnnouncementList() {
    Scroll() {
      Column({ space: 12 }) {
        if (this.announcements.length === 0) {
          this.buildEmptyPlaceholder('bell', '暂无公告')
        } else {
          ForEach(this.announcements, (item: AnnouncementItem) => {
            Row() {
              // 缩略图 80x80
              Stack() {
                Circle()
                  .width(64)
                  .height(64)
                  .fill($r('app.color.primary_light'))
                SymbolGlyph($r('sys.symbol.bell'))
                  .fontSize(this.fsSmall)
              }

              Column({ space: 4 }) {
                Row() {
                  Text(item.title)
                    .fontSize(this.fsBody)
                    .fontWeight(600)
                    .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .layoutWeight(1)
                  if (!item.isRead) {
                    Circle()
                      .width(8)
                      .height(8)
                      .fill($r('app.color.warm_orange'))
                  }
                }
                .width('100%')

                Text(item.source + ' · ' + item.publishTime)
                  .fontSize(this.fsTiny)
                  .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text(item.summary)
                  .fontSize(this.fsSmall)
                  .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 12 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')
            .borderRadius(8)
            .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 1 })
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              this.showDetail(item);
            })
          }, (item: AnnouncementItem) => item.id)
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 24 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  // ===== 校园资讯列表 =====
  @Builder
  buildNewsList() {
    Scroll() {
      Column({ space: 12 }) {
        if (this.news.length === 0) {
          this.buildEmptyPlaceholder('newspaper', '暂无资讯')
        } else {
          ForEach(this.news, (item: NewsItem) => {
            Row() {
              Stack() {
                Circle()
                  .width(64)
                  .height(64)
                  .fill($r('app.color.primary_light'))
                SymbolGlyph($r('sys.symbol.doc_text'))
                  .fontSize(this.fsSmall)
              }

              Column({ space: 4 }) {
                Text(item.title)
                  .fontSize(this.fsBody)
                  .fontWeight(600)
                  .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text(item.source + ' · ' + item.publishTime)
                  .fontSize(this.fsTiny)
                  .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text(item.summary)
                  .fontSize(this.fsSmall)
                  .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 12 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')
            .borderRadius(8)
            .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 1 })
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              router.pushUrl({ url: 'pages/campus/NewsDetailPage', params: { newsId: item.id } }).catch((err: Error) => { console.error('[CampusInfo] 跳转资讯详情失败: ' + err.message); });
            })
          }, (item: NewsItem) => item.id)
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 24 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  // ===== 社团活动 =====
  @Builder
  buildActivityList() {
    Scroll() {
      Column({ space: 12 }) {
        ForEach(this.activityData, (item: ActivityItem) => {
          Column({ space: 8 }) {
            Row() {
              Text(item.title)
                .fontSize(this.fsBody)
                .fontWeight(600)
                .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
                .layoutWeight(1)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text(item.tag)
                .fontSize(20)
                .fontColor($r('app.color.warm_orange'))
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .backgroundColor('#FFF3E0')
                .borderRadius(4)
            }
            .width('100%')

            Text(item.organizer + ' · ' + item.time)
              .fontSize(this.fsTiny)
              .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Row({ space: 4 }) {
              SymbolGlyph($r('sys.symbol.pin'))
                .fontSize(this.fsSmall)
              Text(item.location)
                .fontSize(this.fsTiny)
                .fontColor($r('app.color.primary'))
                .maxLines(1)
            }

            Text(item.summary)
              .fontSize(this.fsSmall)
              .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')
          .borderRadius(8)
          .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 1 })
          .alignItems(HorizontalAlign.Start)
        }, (item: ActivityItem) => item.id)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 24 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  // ===== 学术讲座 =====
  @Builder
  buildLectureList() {
    Scroll() {
      Column({ space: 12 }) {
        ForEach(this.lectureData, (item: LectureItem) => {
          Column({ space: 8 }) {
            Text(item.title)
              .fontSize(this.fsBody)
              .fontWeight(600)
              .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
              .width('100%')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Row({ space: 8 }) {
              SymbolGlyph($r('sys.symbol.mic'))
                .fontSize(this.fsSmall)
              Text(item.speaker)
                .fontSize(this.fsTiny)
                .fontColor($r('app.color.primary'))
                .layoutWeight(1)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')

            Row({ space: 16 }) {
              Row({ space: 4 }) {
                SymbolGlyph($r('sys.symbol.clock'))
                  .fontSize(this.fsSmall)
                Text(item.time)
                  .fontSize(this.fsTiny)
                  .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
              }
              Row({ space: 4 }) {
                SymbolGlyph($r('sys.symbol.pin'))
                  .fontSize(this.fsSmall)
                Text(item.location)
                  .fontSize(this.fsTiny)
                  .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
              }
            }
            .width('100%')

            Text(item.summary)
              .fontSize(this.fsSmall)
              .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')
          .borderRadius(8)
          .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 1 })
          .alignItems(HorizontalAlign.Start)
        }, (item: LectureItem) => item.id)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 24 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  // ===== 校园地图 =====
  @Builder
  buildCampusMap() {
    Scroll() {
      Column({ space: 16 }) {
        // 校园平面地图（模拟）
        Stack() {
          // 绿色底图
          Column()
            .width('100%')
            .height(240)
            .backgroundColor('#E8F8E0')
            .borderRadius(8)

          // 建筑标注
          ForEach(this.buildings, (b: MapBuilding) => {
            Column({ space: 2 }) {
              Stack() {
                Circle()
                  .width(28)
                  .height(28)
                  .fill(this.selectedBuilding === this.getBuildingIndex(b.name) ? $r('app.color.warm_orange') : $r('app.color.primary'))
                Text(b.name.substring(0, 1))
                  .fontSize(18)
                  .fontColor('#FFFFFF')
              }
              Text(b.name)
                .fontSize(18)
                .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
                .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')
                .padding({ left: 4, right: 4 })
                .borderRadius(2)
            }
            .position({ x: b.x + '%', y: b.y + '%' })
            .onClick(() => {
              this.selectedBuilding = this.getBuildingIndex(b.name);
            })
          }, (b: MapBuilding, index: number) => b.name + index.toString())
        }
        .width('100%')
        .aspectRatio(1.8)
        .padding(12)

        // 选中的建筑详情
        if (this.selectedBuilding >= 0 && this.selectedBuilding < this.buildings.length) {
          Column({ space: 8 }) {
            Text(this.buildings[this.selectedBuilding].name)
              .fontSize(this.fsMid)
              .fontWeight(700)
              .fontColor($r('app.color.primary'))
            Text(this.buildings[this.selectedBuilding].description)
              .fontSize(this.fsSmall)
              .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')
          .borderRadius(8)
          .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 1 })
          .alignItems(HorizontalAlign.Start)
        }

        // 建筑搜索栏
        Row() {
          TextInput({ placeholder: '搜索校园建筑...', text: this.mapSearchText })
            .height(44)
            .fontSize(this.fsSmall)
            .placeholderColor('#86909C')
            .borderRadius(8)
            .backgroundColor(this.isDarkMode ? '#1A1A2E' : '#F5F7FA')
            .layoutWeight(1)
            .onChange((value: string) => {
              this.mapSearchText = value;
            })

          Button('搜索')
            .height(44)
            .fontSize(this.fsSmall)
            .fontColor('#FFFFFF')
            .backgroundColor($r('app.color.primary'))
            .borderRadius(8)
            .margin({ left: 12 })
            .onClick(() => {
              if (this.mapSearchText.trim() !== '') {
                for (let i = 0; i < this.buildings.length; i++) {
                  if (this.buildings[i].name.includes(this.mapSearchText.trim())) {
                    this.selectedBuilding = i;
                    return;
                  }
                }
                promptAction.showToast({ message: '未找到匹配建筑' });
              }
            })
        }
        .width('100%')

        // 核心建筑快捷入口
        Scroll() {
          Row({ space: 12 }) {
            ForEach(this.buildings, (b: MapBuilding, index: number) => {
              Column({ space: 4 }) {
                Stack() {
                  Circle()
                    .width(44)
                    .height(44)
                    .fill(this.selectedBuilding === index ? $r('app.color.primary_light') : $r('app.color.background'))
                  Text(b.name.substring(0, 1))
                    .fontSize(this.fsTiny)
                    .fontColor(this.selectedBuilding === index ? '#1677FF' : this.isDarkMode ? '#A0A0A0' : '#86909C')
                }
                Text(b.name)
                  .fontSize(20)
                  .fontColor(this.selectedBuilding === index ? '#1677FF' : this.isDarkMode ? '#A0A0A0' : '#86909C')
                  .maxLines(1)
              }
              .alignItems(HorizontalAlign.Center)
              .onClick(() => {
                this.selectedBuilding = index;
              })
            }, (b: MapBuilding, index: number) => b.name + index.toString())
          }
        }
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Horizontal)

        // 到建筑详情页
        if (this.selectedBuilding >= 0) {
          Button('查看建筑详情')
            .width('100%')
            .height(48)
            .fontSize(this.fsBody)
            .fontColor('#FFFFFF')
            .backgroundColor($r('app.color.primary'))
            .borderRadius(8)
            .onClick(() => {
              const b = this.buildings[this.selectedBuilding]; router.pushUrl({ url: 'pages/campus/BuildingDetailPage', params: { name: b.name, description: b.description } }).catch((err: Error) => { console.error('[CampusInfo] 跳转建筑详情失败: ' + err.message); });
            })
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 24 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  private getBuildingIndex(name: string): number {
    for (let i = 0; i < this.buildings.length; i++) {
      if (this.buildings[i].name === name) {
        return i;
      }
    }
    return -1;
  }

  @Builder
  buildEmptyPlaceholder(iconType: string, message: string) {
    Column({ space: 24 }) {
      Stack() {
        Circle()
          .width(100)
          .height(100)
          .fill($r('app.color.primary_light'))
        if (iconType === 'bell') {
          SymbolGlyph($r('sys.symbol.bell'))
            .fontSize(48)
        } else if (iconType === 'newspaper') {
          SymbolGlyph($r('sys.symbol.doc_text'))
            .fontSize(48)
        }
      }
      Text(message)
        .fontSize(this.fsMid)
        .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
    }
    .width('100%')
    .height(300)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // ===== 详情弹窗 =====
  @Builder
  buildDetailLayer() {
    Column() {
      Blank()

      Scroll() {
        Column({ space: 16 }) {
          Row() {
            Text('公告详情')
              .fontSize(this.fsMid)
              .fontWeight(700)
              .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
              .layoutWeight(1)
            Text('关闭')
              .fontSize(this.fsSmall)
              .fontColor($r('app.color.primary'))
              .onClick(() => {
                this.closeDetail();
              })
          }
          .width('100%')

          Divider().color($r('app.color.border'))

          Text(this.selectedAnnouncement!.title)
            .fontSize(32)
            .fontWeight(700)
            .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
            .width('100%')
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Row({ space: 8 }) {
            Text(this.selectedAnnouncement!.source)
              .fontSize(this.fsTiny)
              .fontColor($r('app.color.primary'))
            Text(this.selectedAnnouncement!.publishTime)
              .fontSize(this.fsTiny)
              .fontColor(this.isDarkMode ? '#A0A0A0' : '#86909C')
          }
          .width('100%')

          Text(this.selectedAnnouncement!.category)
            .fontSize(this.fsTiny)
            .fontColor($r('app.color.warm_orange'))
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor('#FFF3E0')
            .borderRadius(4)

          Divider().color($r('app.color.border'))

          Text(this.selectedAnnouncement!.content)
            .fontSize(this.fsBody)
            .fontColor(this.isDarkMode ? '#E8E8E8' : '#1D2129')
            .lineHeight(22)
            .width('100%')

          Row({ space: 24 }) {
            if (this.selectedAnnouncement!.isFavorited) {
              Row({ space: 4 }) {
                SymbolGlyph($r('sys.symbol.heart_fill'))
                  .fontSize(this.fsTiny)
                Text('已收藏')
                  .fontSize(this.fsSmall)
                  .fontColor($r('app.color.primary'))
              }
              .onClick(() => {
                if (this.selectedAnnouncement) {
                  this.selectedAnnouncement.isFavorited = !this.selectedAnnouncement.isFavorited;
                }
              })
            } else {
              Row({ space: 4 }) {
                SymbolGlyph($r('sys.symbol.heart'))
                  .fontSize(this.fsTiny)
                Text('收藏')
                  .fontSize(this.fsSmall)
                  .fontColor($r('app.color.primary'))
              }
              .onClick(() => {
                if (this.selectedAnnouncement) {
                  this.selectedAnnouncement.isFavorited = !this.selectedAnnouncement.isFavorited;
                }
              })
            }

            Row({ space: 4 }) {
              SymbolGlyph($r('sys.symbol.share'))
                .fontSize(this.fsTiny)
              Text('分享')
                .fontSize(this.fsSmall)
                .fontColor($r('app.color.primary'))
            }
            .onClick(() => {
              promptAction.showToast({ message: '链接已复制' });
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 16, bottom: 16 })
        }
        .width('100%')
        .padding(20)
        .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')
        .borderRadius({ topLeft: 16, topRight: 16 })
      }
      .width('100%')
      .height('70%')
      .backgroundColor(this.isDarkMode ? '#252540' : '#FFFFFF')
      .borderRadius({ topLeft: 16, topRight: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#66000000')
    .onClick(() => {
      this.closeDetail();
    })
  }
}
