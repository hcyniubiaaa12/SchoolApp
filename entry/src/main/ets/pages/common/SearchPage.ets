/**
 * SearchPage.ets - 搜索结果页
 * 首页搜索栏点击进入，展示搜索框 + 分类结果
 */
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';

interface SearchResultItem {
  title: string;
  subTitle: string;
  type: string;
}

@Entry
@Component
struct SearchPage {
  @State searchText: string = '';
  @State results: SearchResultItem[] = [];
  @State hasSearched: boolean = false;

  // 模拟全量数据
  private allData: SearchResultItem[] = [
    { title: '关于2026年春季学期期末考试安排的通知', subTitle: '校长办公室 · 2026-06-20', type: '公告' },
    { title: '高级人工智能', subTitle: '信软楼302 · 李明教授', type: '课程' },
    { title: '高等数学实践', subTitle: '公教楼205 · 王芳老师', type: '课程' },
    { title: '数据结构课程设计', subTitle: '实验楼404 · 赵强老师', type: '课程' },
    { title: '深入理解计算机系统', subTitle: '图书馆三楼A区-301 · 可借3/5', type: '图书' },
    { title: '算法导论', subTitle: '图书馆三楼B区-205 · 可借5/8', type: '图书' },
    { title: '红烧牛肉面', subTitle: '二食堂 · 面食窗口', type: '美食' },
    { title: '麻辣香锅', subTitle: '一食堂 · 川味窗口', type: '美食' },
    { title: '蓝色校园卡遗失', subTitle: '二食堂一楼 · 2026-06-24', type: '失物' },
  ];

  private doSearch(): void {
    const keyword: string = this.searchText.trim().toLowerCase();
    if (keyword === '') {
      promptAction.showToast({ message: '请输入搜索内容' });
      return;
    }
    const matched: SearchResultItem[] = [];
    for (let i = 0; i < this.allData.length; i++) {
      const item: SearchResultItem = this.allData[i];
      if (item.title.toLowerCase().includes(keyword) ||
          item.subTitle.toLowerCase().includes(keyword)) {
        matched.push(item);
      }
    }
    this.results = matched;
    this.hasSearched = true;
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
            }, (item: SearchResultItem, index: number) => item.title + index.toString())
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
    if (type === '公告' || type === '课程' || type === '图书') {
      return $r('app.color.primary');
    }
    if (type === '美食' || type === '失物') {
      return $r('app.color.warm_orange');
    }
    return $r('app.color.text_secondary');
  }

  private getTypeBgColor(type: string): Resource {
    if (type === '公告' || type === '课程' || type === '图书') {
      return $r('app.color.card_bg_blue');
    }
    if (type === '美食' || type === '失物') {
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
