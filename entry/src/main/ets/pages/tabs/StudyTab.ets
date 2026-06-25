/**
 * StudyTab.ets - 学习助手 Tab
 * 4 个标签：课程表 / 成绩查询 / 图书馆检索 / 学习资料
 *
 * 数据来源：
 *   - 课程表/成绩/图书 → RelationalStore (CourseDao/ScoreDao/BookDao)
 *   - 学习资料 → rawfile JSON (JsonStoreUtil)
 */
import promptAction from '@ohos.promptAction';
import { router } from '@kit.ArkUI';
import { JsonStoreUtil } from '../../common/utils/JsonStoreUtil';
import { CourseDao, CourseRow } from '../../common/database/CourseDao';
import { ScoreDao, ScoreRow } from '../../common/database/ScoreDao';
import { BookDao, BookRow } from '../../common/database/BookDao';

interface TagItem {
  name: string;
}

interface WeekDayItem {
  name: string;
  shortName: string;
  dayIndex: number;
}

interface MaterialFolder {
  id: string;
  folderName: string;
  icon: string;
  items: MaterialItem[];
}

interface MaterialItem {
  name: string;
  type: string;
}

@Component
export struct StudyTab {
  @Prop uiContext?: Context;
  @State currentTagIndex: number = 0;
  @State currentWeek: number = 6;
  @State selectedCourseId: string = '';
  @State showCourseDetail: boolean = false;
  @State courses: CourseRow[] = [];
  @State scores: ScoreRow[] = [];
  @State books: BookRow[] = [];
  @State filteredBooks: BookRow[] = [];
  @State materials: MaterialFolder[] = [];
  @State bookSearchText: string = '';
  @State expandedMaterialId: string = '';
  @State showCourseEdit: boolean = false;

  private tags: TagItem[] = [
    { name: '课程表' }, { name: '成绩查询' }, { name: '图书馆检索' }, { name: '学习资料' }
  ];

  private weekDays: WeekDayItem[] = [
    { name: '周一', shortName: '一', dayIndex: 1 },
    { name: '周二', shortName: '二', dayIndex: 2 },
    { name: '周三', shortName: '三', dayIndex: 3 },
    { name: '周四', shortName: '四', dayIndex: 4 },
    { name: '周五', shortName: '五', dayIndex: 5 },
    { name: '周六', shortName: '六', dayIndex: 6 },
    { name: '周日', shortName: '日', dayIndex: 7 }
  ];

  aboutToAppear(): void {
    this.loadCourses();
    this.loadScores();
    this.loadBooks();
    this.loadMaterials();
  }

  private loadCourses(): void {
    if (!this.uiContext) {
      return;
    }
    CourseDao.queryAll(this.uiContext).then((data: CourseRow[]) => {
      this.courses = data;
    });
  }

  private loadScores(): void {
    if (!this.uiContext) {
      return;
    }
    ScoreDao.queryAll(this.uiContext).then((data: ScoreRow[]) => {
      this.scores = data;
    });
  }

  private loadBooks(): void {
    if (!this.uiContext) {
      return;
    }
    BookDao.queryAll(this.uiContext).then((data: BookRow[]) => {
      this.books = data;
      this.filteredBooks = data;
    });
  }

  private loadMaterials(): void {
    JsonStoreUtil.read<MaterialFolder[]>('study_materials.json').then((data: MaterialFolder[] | null) => {
      if (data) {
        this.materials = data;
      }
    });
  }

  private previousWeek(): void {
    if (this.currentWeek > 1) {
      this.currentWeek--;
    } else {
      promptAction.showToast({ message: '已经是第1周' });
    }
  }

  private nextWeek(): void {
    if (this.currentWeek < 20) {
      this.currentWeek++;
    } else {
      promptAction.showToast({ message: '已经是第20周' });
    }
  }

  private getCoursesByDay(dayIndex: number): CourseRow[] {
    const result: CourseRow[] = [];
    for (let i = 0; i < this.courses.length; i++) {
      const c: CourseRow = this.courses[i];
      if (c.dayIndex === dayIndex && this.currentWeek >= c.startWeek && this.currentWeek <= c.endWeek) {
        result.push(c);
      }
    }
    return result;
  }

  private getDayCourseCount(dayIndex: number): number {
    return this.getCoursesByDay(dayIndex).length;
  }

  private showCourse(course: CourseRow): void {
    this.selectedCourseId = course.id;
    this.showCourseDetail = true;
  }

  private closeCourseDetail(): void {
    this.showCourseDetail = false;
  }

  private getSelectedCourse(): CourseRow {
    for (let i = 0; i < this.courses.length; i++) {
      if (this.courses[i].id === this.selectedCourseId) {
        return this.courses[i];
      }
    }
    return this.courses.length > 0 ? this.courses[0] : {
      id: '', name: '', teacher: '', location: '', dayIndex: 1,
      startTime: '', endTime: '', startWeek: 0, endWeek: 0,
      courseType: '', color: '', credit: '', remark: ''
    };
  }

  private getSelectedCourseTime(): string {
    const c: CourseRow = this.getSelectedCourse();
    return c.startTime + ' - ' + c.endTime;
  }

  private getSelectedCourseWeekRange(): string {
    const c: CourseRow = this.getSelectedCourse();
    return '第' + c.startWeek.toString() + '-' + c.endWeek.toString() + '周';
  }

  private getSelectedCourseDayName(): string {
    const c: CourseRow = this.getSelectedCourse();
    for (let i = 0; i < this.weekDays.length; i++) {
      if (this.weekDays[i].dayIndex === c.dayIndex) {
        return this.weekDays[i].name;
      }
    }
    return '';
  }

  // —— 成绩查询 ——

  private getSortedScores(): ScoreRow[] {
    return this.scores.sort((a: ScoreRow, b: ScoreRow) => b.gpa - a.gpa);
  }

  private getAverageGpa(): string {
    if (this.scores.length === 0) {
      return '0.00';
    }
    let sum: number = 0;
    for (let i = 0; i < this.scores.length; i++) {
      sum += this.scores[i].gpa;
    }
    return (sum / this.scores.length).toFixed(2);
  }

  // —— 图书馆检索 ——

  private doBookSearch(): void {
    if (this.bookSearchText.trim() === '') {
      this.filteredBooks = this.books;
      return;
    }
    const keyword: string = this.bookSearchText.trim().toLowerCase();
    const result: BookRow[] = [];
    for (let i = 0; i < this.books.length; i++) {
      const b: BookRow = this.books[i];
      if (b.title.toLowerCase().includes(keyword) ||
          b.author.toLowerCase().includes(keyword) ||
          b.publisher.toLowerCase().includes(keyword) ||
          b.isbn.toLowerCase().includes(keyword)) {
        result.push(b);
      }
    }
    this.filteredBooks = result;
  }

  private toggleBookFavorite(bookId: string): void {
    if (!this.uiContext) {
      return;
    }
    BookDao.toggleFavorite(this.uiContext, bookId).then(() => {
      this.loadBooks();
    });
  }

  private isBookFavorited(bookId: string): boolean {
    for (let i = 0; i < this.books.length; i++) {
      if (this.books[i].id === bookId) {
        return this.books[i].isFavorited === 1;
      }
    }
    return false;
  }

  // —— 学习资料 ——

  private toggleMaterialExpand(id: string): void {
    if (this.expandedMaterialId === id) {
      this.expandedMaterialId = '';
    } else {
      this.expandedMaterialId = id;
    }
  }

  private getMaterialItems(id: string): MaterialItem[] {
    for (let i = 0; i < this.materials.length; i++) {
      if (this.materials[i].id === id) {
        return this.materials[i].items;
      }
    }
    return [];
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航栏
        Row() {
          Text('学习助手')
            .fontSize(30)
            .fontWeight(600)
            .fontColor('#1D2129')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .height(56)
        .padding({ left: 20, right: 20 })
        .backgroundColor('#FFFFFF')

        // 功能标签栏
        Row() {
          ForEach(this.tags, (tag: TagItem, index: number) => {
            Column({ space: 6 }) {
              Text(tag.name)
                .fontSize(22)
                .fontColor(this.currentTagIndex === index ? '#1677FF' : '#86909C')
                .fontWeight(this.currentTagIndex === index ? 600 : 400)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Row()
                .width(34)
                .height(2)
                .backgroundColor(this.currentTagIndex === index ? '#1677FF' : '#00FFFFFF')
                .borderRadius(1)
            }
            .layoutWeight(1)
            .height(48)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              this.currentTagIndex = index;
            })
          }, (tag: TagItem, index: number) => tag.name + index.toString())
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .border({ width: { bottom: 1 }, color: '#E5E6EB' })

        // 标签内容区
        if (this.currentTagIndex === 0) {
          this.buildCourseTable()
        } else if (this.currentTagIndex === 1) {
          this.buildScoreQuery()
        } else if (this.currentTagIndex === 2) {
          this.buildLibrarySearch()
        } else {
          this.buildStudyMaterials()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F7FA')

      // 课程详情弹窗
      if (this.showCourseDetail) {
        this.buildCourseDetailLayer()
      }
    }
    .width('100%')
    .height('100%')
  }

  // ===== 课程表 =====
  @Builder
  buildCourseTable() {
    Scroll() {
      Column({ space: 16 }) {
        // 周次切换
        Row() {
          Text('上一周')
            .fontSize(24)
            .fontColor(this.currentWeek === 1 ? '#86909C' : '#1677FF')
            .width(80)
            .textAlign(TextAlign.Start)
            .onClick(() => {
              this.previousWeek();
            })

          Blank()

          Column({ space: 4 }) {
            Text('2026 年第 ' + this.currentWeek.toString() + ' 周')
              .fontSize(26)
              .fontWeight(600)
              .fontColor('#1D2129')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .alignItems(HorizontalAlign.Center)

          Blank()

          Text('下一周')
            .fontSize(24)
            .fontColor(this.currentWeek === 20 ? '#86909C' : '#1677FF')
            .width(80)
            .textAlign(TextAlign.End)
            .onClick(() => {
              this.nextWeek();
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
        .alignItems(VerticalAlign.Center)

        // 周一至周日纵向课程视图
        ForEach(this.weekDays, (day: WeekDayItem) => {
          Column({ space: 12 }) {
            Row() {
              Stack() {
                Circle()
                  .width(36)
                  .height(36)
                  .fill('#E8F3FF')
                Text(day.shortName)
                  .fontSize(22)
                  .fontWeight(600)
                  .fontColor('#1677FF')
              }
              .margin({ right: 12 })

              Text(day.name)
                .fontSize(28)
                .fontWeight(600)
                .fontColor('#1D2129')
                .layoutWeight(1)

              Text(this.getDayCourseCount(day.dayIndex).toString() + ' 门课')
                .fontSize(24)
                .fontColor('#86909C')
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)

            if (this.getDayCourseCount(day.dayIndex) > 0) {
              ForEach(this.getCoursesByDay(day.dayIndex), (course: CourseRow) => {
                this.buildCourseCard(course)
              }, (course: CourseRow) => course.id + this.currentWeek.toString())
            } else {
              Row() {
                Text('今日无课程，好好休息吧～')
                  .fontSize(24)
                  .fontColor('#86909C')
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center)
              }
              .width('100%')
              .height(56)
              .backgroundColor('#F5F7FA')
              .borderRadius(8)
              .alignItems(VerticalAlign.Center)
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
        }, (day: WeekDayItem) => day.name + day.dayIndex.toString())

        // 编辑课程表按钮
        Button('编辑课程表')
          .width('100%')
          .height(48)
          .fontSize(26)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(8)
          .onClick(() => {
            router.pushUrl({ url: 'pages/study/ScheduleEditPage' })
              .catch(() => {
                promptAction.showToast({ message: '打开编辑页失败' });
              });
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 24 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  @Builder
  buildCourseCard(course: CourseRow) {
    Row({ space: 12 }) {
      Column({ space: 4 }) {
        Text(course.startTime)
          .fontSize(24)
          .fontWeight(600)
          .fontColor('#1D2129')
        Text(course.endTime)
          .fontSize(22)
          .fontColor('#86909C')
      }
      .width(68)
      .alignItems(HorizontalAlign.Center)

      Row()
        .width(4)
        .height(72)
        .backgroundColor(course.color)
        .borderRadius(2)

      Column({ space: 6 }) {
        Row() {
          Text(course.name)
            .fontSize(26)
            .fontWeight(600)
            .fontColor('#1D2129')
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(course.courseType)
            .fontSize(22)
            .fontColor(course.color)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor('#1A' + course.color.substring(1))
            .borderRadius(4)
        }
        .width('100%')

        Text(course.location)
          .fontSize(24)
          .fontColor('#86909C')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(course.teacher + ' · ' + course.credit + ' 学分')
          .fontSize(22)
          .fontColor('#86909C')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F5F7FA')
    .borderRadius(8)
    .onClick(() => {
      this.showCourse(course);
    })
  }

  // ===== 成绩查询 =====
  @Builder
  buildScoreQuery() {
    Scroll() {
      Column({ space: 16 }) {
        // 学号/姓名 + 平均绩点概览
        Row() {
          Column({ space: 4 }) {
            Text('计算机科学与技术 · 张三')
              .fontSize(26)
              .fontWeight(600)
              .fontColor('#1D2129')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text('平均绩点: ' + this.getAverageGpa())
              .fontSize(24)
              .fontColor('#1677FF')
              .maxLines(1)
          }
          .layoutWeight(1)

          Text('刷新成绩')
            .fontSize(24)
            .fontColor('#FFFFFF')
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor('#1677FF')
            .borderRadius(8)
            .onClick(() => {
              this.loadScores();
              promptAction.showToast({ message: '成绩已刷新' });
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
        .alignItems(VerticalAlign.Center)

        // 成绩列表（按绩点排序）
        ForEach(this.getSortedScores(), (score: ScoreRow) => {
          Row() {
            Column({ space: 4 }) {
              Text(score.courseName)
                .fontSize(26)
                .fontWeight(600)
                .fontColor('#1D2129')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Row({ space: 8 }) {
                Text(score.semester)
                  .fontSize(22)
                  .fontColor('#86909C')
                Text(score.examTime)
                  .fontSize(22)
                  .fontColor('#86909C')
              }
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Column({ space: 2 }) {
              Text(score.score.toString())
                .fontSize(28)
                .fontWeight(700)
                .fontColor(score.score >= 90 ? '#00B42A' : score.score >= 80 ? '#1677FF' : '#FF7D00')
              Text('绩点 ' + score.gpa.toFixed(1))
                .fontSize(22)
                .fontColor('#86909C')
            }
            .alignItems(HorizontalAlign.Center)
            .width(80)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
        }, (score: ScoreRow) => score.id)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 24 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  // ===== 图书馆检索 =====
  @Builder
  buildLibrarySearch() {
    Column() {
      // 搜索栏固定在顶部
      Row() {
        TextInput({ placeholder: '请输入图书名称/作者/ISBN', text: this.bookSearchText })
          .height(44)
          .fontSize(24)
          .placeholderColor('#86909C')
          .borderRadius(8)
          .backgroundColor('#F5F7FA')
          .layoutWeight(1)
          .onChange((value: string) => {
            this.bookSearchText = value;
          })

        Button('搜索')
          .height(44)
          .fontSize(24)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(8)
          .margin({ left: 12 })
          .onClick(() => {
            this.doBookSearch();
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')

      // 搜索结果列表
      Scroll() {
        Column({ space: 12 }) {
          if (this.filteredBooks.length === 0) {
            Row() {
              Text('未找到匹配的图书')
                .fontSize(26)
                .fontColor('#86909C')
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          } else {
            ForEach(this.filteredBooks, (book: BookRow) => {
              this.buildBookCard(book)
            }, (book: BookRow) => book.id)
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 12, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .layoutWeight(1)
  }

  @Builder
  buildBookCard(book: BookRow) {
    Row({ space: 12 }) {
      // 封面占位
      Stack() {
        Circle()
          .width(72)
          .height(72)
          .fill('#E8F3FF')
        Text('📖')
          .fontSize(32)
      }

      Column({ space: 4 }) {
        Text(book.title)
          .fontSize(26)
          .fontWeight(600)
          .fontColor('#1D2129')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(book.author + ' | ' + book.publisher)
          .fontSize(22)
          .fontColor('#86909C')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: 8 }) {
          Text(book.location)
            .fontSize(22)
            .fontColor('#1677FF')
            .maxLines(1)

          Blank()

          if (book.availableCount > 0) {
            Text('可借 ' + book.availableCount.toString() + '/' + book.totalCount.toString())
              .fontSize(22)
              .fontColor('#00B42A')
          } else {
            Text('已借完')
              .fontSize(22)
              .fontColor('#FF7D00')
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 收藏按钮
      Text(this.isBookFavorited(book.id) ? '❤️' : '🤍')
        .fontSize(24)
        .onClick(() => {
          this.toggleBookFavorite(book.id);
        })
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      promptAction.showToast({ message: '图书详情页将在后续版本开放' });
    })
  }

  // ===== 学习资料 =====
  @Builder
  buildStudyMaterials() {
    Scroll() {
      Column({ space: 16 }) {
        if (this.materials.length === 0) {
          Column({ space: 24 }) {
            Stack() {
              Circle()
                .width(140)
                .height(140)
                .fill('#E8F3FF')
              Text('📁')
                .fontSize(64)
            }
            Column({ space: 8 }) {
              Text('暂无学习资料')
                .fontSize(28)
                .fontWeight(700)
                .fontColor('#1677FF')
              Text('学习资料功能将在后续版本开放')
                .fontSize(24)
                .fontColor('#86909C')
                .textAlign(TextAlign.Center)
                .maxLines(2)
            }
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .padding({ top: 60, bottom: 60 })
        } else {
          ForEach(this.materials, (folder: MaterialFolder) => {
            this.buildMaterialFolder(folder)
          }, (folder: MaterialFolder) => folder.id)
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 24 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  @Builder
  buildMaterialFolder(folder: MaterialFolder) {
    Column() {
      // 文件夹标题
      Row() {
        Text('📁')
          .fontSize(28)
          .margin({ right: 12 })

        Text(folder.folderName)
          .fontSize(26)
          .fontWeight(600)
          .fontColor('#1D2129')
          .layoutWeight(1)

        Text(this.expandedMaterialId === folder.id ? '收起' : '展开')
          .fontSize(24)
          .fontColor('#1677FF')
      }
      .width('100%')
      .padding(16)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.toggleMaterialExpand(folder.id);
      })

      // 展开后的文件列表
      if (this.expandedMaterialId === folder.id) {
        Column() {
          ForEach(this.getMaterialItems(folder.id), (item: MaterialItem) => {
            Row() {
              Text(item.type === 'pdf' ? '📄' : '📎')
                .fontSize(24)
                .margin({ right: 12 })

              Text(item.name)
                .fontSize(24)
                .fontColor('#1D2129')
                .layoutWeight(1)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text('下载')
                .fontSize(22)
                .fontColor('#1677FF')
            }
            .width('100%')
            .height(44)
            .padding({ left: 52, right: 16 })
            .onClick(() => {
              promptAction.showToast({ message: '资料查看功能将在后续版本开放' });
            })
          }, (item: MaterialItem, index: number) => item.name + index.toString())
        }
        .width('100%')
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  // ===== 课程详情弹窗 =====
  @Builder
  buildCourseDetailLayer() {
    Column() {
      Blank()

      Column({ space: 16 }) {
        Row() {
          Text('课程详情')
            .fontSize(28)
            .fontWeight(700)
            .fontColor('#1D2129')
            .layoutWeight(1)
          Text('关闭')
            .fontSize(24)
            .fontColor('#1677FF')
            .onClick(() => {
              this.closeCourseDetail();
            })
        }
        .width('100%')

        Divider().color('#E5E6EB')

        Text(this.getSelectedCourse().name)
          .fontSize(32)
          .fontWeight(700)
          .fontColor('#1677FF')
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        this.buildDetailRow('教师', this.getSelectedCourse().teacher)
        this.buildDetailRow('时间', this.getSelectedCourseDayName() + ' ' + this.getSelectedCourseTime())
        this.buildDetailRow('地点', this.getSelectedCourse().location)
        this.buildDetailRow('周次', this.getSelectedCourseWeekRange())
        this.buildDetailRow('类型', this.getSelectedCourse().courseType)
        this.buildDetailRow('学分', this.getSelectedCourse().credit)

        Row({ space: 12 }) {
          Button('编辑课程')
            .layoutWeight(1)
            .height(48)
            .fontSize(26)
            .fontColor('#1677FF')
            .backgroundColor('#E8F3FF')
            .borderRadius(8)
            .onClick(() => {
              this.closeCourseDetail();
              router.pushUrl({
                url: 'pages/study/ScheduleEditPage',
                params: { courseId: this.selectedCourseId }
              }).catch(() => {
                promptAction.showToast({ message: '打开编辑页失败' });
              });
            })

          Button('我知道了')
            .layoutWeight(1)
            .height(48)
            .fontSize(26)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(8)
            .onClick(() => {
              this.closeCourseDetail();
            })
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius({ topLeft: 16, topRight: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#66000000')
  }

  @Builder
  buildDetailRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(24)
        .fontColor('#86909C')
        .width(56)
      Text(value)
        .fontSize(26)
        .fontColor('#1D2129')
        .layoutWeight(1)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}
