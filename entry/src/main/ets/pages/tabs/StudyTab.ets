// StudyTab.ets - 学习助手 Tab
// P1 首发：课程表 MVP（周次切换、周视图、课程详情）
import promptAction from '@ohos.promptAction';

interface StudyTagItem {
  name: string;
}

interface WeekDayItem {
  name: string;
  shortName: string;
  dayIndex: number;
}

interface CourseItem {
  id: string;
  name: string;
  teacher: string;
  location: string;
  dayIndex: number;
  startTime: string;
  endTime: string;
  startWeek: number;
  endWeek: number;
  courseType: string;
  color: string;
  credit: string;
}

@Component
export struct StudyTab {
  @State currentTagIndex: number = 0;
  @State currentWeek: number = 6;
  @State selectedCourseId: string = '';
  @State showCourseDetail: boolean = false;

  private tags: StudyTagItem[] = [
    { name: '课程表' },
    { name: '成绩查询' },
    { name: '图书馆检索' },
    { name: '学习资料' }
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

  // 首发采用页面内静态模拟数据，字段按后续 JSON 迁移预留
  private courses: CourseItem[] = [
    {
      id: 'ai-001',
      name: '高级人工智能',
      teacher: '李明教授',
      location: '信软楼302',
      dayIndex: 1,
      startTime: '10:00',
      endTime: '11:40',
      startWeek: 1,
      endWeek: 16,
      courseType: '必修',
      color: '#1677FF',
      credit: '3.0'
    },
    {
      id: 'math-002',
      name: '高等数学实践',
      teacher: '王芳老师',
      location: '公教楼205',
      dayIndex: 2,
      startTime: '08:00',
      endTime: '09:40',
      startWeek: 1,
      endWeek: 12,
      courseType: '必修',
      color: '#FF7D00',
      credit: '4.0'
    },
    {
      id: 'english-003',
      name: '学术英语写作',
      teacher: '陈晓老师',
      location: '外语楼108',
      dayIndex: 3,
      startTime: '14:00',
      endTime: '15:40',
      startWeek: 3,
      endWeek: 18,
      courseType: '公共课',
      color: '#00B42A',
      credit: '2.0'
    },
    {
      id: 'data-004',
      name: '数据结构课程设计',
      teacher: '赵强老师',
      location: '实验楼404',
      dayIndex: 4,
      startTime: '16:00',
      endTime: '17:40',
      startWeek: 5,
      endWeek: 14,
      courseType: '实践',
      color: '#1677FF',
      credit: '2.5'
    },
    {
      id: 'business-005',
      name: '创业管理学',
      teacher: '刘洋老师',
      location: '公教楼508',
      dayIndex: 5,
      startTime: '14:00',
      endTime: '15:40',
      startWeek: 1,
      endWeek: 10,
      courseType: '选修',
      color: '#00B42A',
      credit: '2.0'
    },
    {
      id: 'sport-006',
      name: '大学体育',
      teacher: '周健老师',
      location: '东区操场',
      dayIndex: 6,
      startTime: '09:00',
      endTime: '10:30',
      startWeek: 2,
      endWeek: 16,
      courseType: '公共课',
      color: '#FF7D00',
      credit: '1.0'
    }
  ];

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

  private getCoursesByDay(dayIndex: number): CourseItem[] {
    return this.courses.filter((course: CourseItem) => {
      return course.dayIndex === dayIndex && this.currentWeek >= course.startWeek && this.currentWeek <= course.endWeek;
    });
  }

  private getDayCourseCount(dayIndex: number): number {
    return this.getCoursesByDay(dayIndex).length;
  }

  private showCourse(course: CourseItem): void {
    this.selectedCourseId = course.id;
    this.showCourseDetail = true;
  }

  private closeCourseDetail(): void {
    this.showCourseDetail = false;
  }

  private getSelectedCourse(): CourseItem {
    for (let index = 0; index < this.courses.length; index++) {
      if (this.courses[index].id === this.selectedCourseId) {
        return this.courses[index];
      }
    }
    return this.courses[0];
  }

  private getSelectedCourseTime(): string {
    return this.getSelectedCourse().startTime + ' - ' + this.getSelectedCourse().endTime;
  }

  private getSelectedCourseWeekRange(): string {
    return '第' + this.getSelectedCourse().startWeek.toString() + '-' + this.getSelectedCourse().endWeek.toString() + '周';
  }

  private getSelectedCourseDayName(): string {
    return this.weekDays[this.getSelectedCourse().dayIndex - 1].name;
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
          ForEach(this.tags, (tag: StudyTagItem, index: number) => {
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
          }, (tag: StudyTagItem, index: number) => tag.name + index.toString())
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .border({ width: { bottom: 1 }, color: '#E5E6EB' })

        if (this.currentTagIndex === 0) {
          this.buildCourseTable()
        } else if (this.currentTagIndex === 1) {
          this.buildPlaceholder('📊', '成绩查询', '成绩列表与绩点统计将在后续版本开放')
        } else if (this.currentTagIndex === 2) {
          this.buildPlaceholder('📚', '图书馆检索', '图书搜索、馆藏位置与收藏功能将在后续版本开放')
        } else {
          this.buildPlaceholder('📁', '学习资料', '课件、真题与本地资料查看将在后续版本开放')
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F7FA')

      if (this.showCourseDetail) {
        this.buildCourseDetailLayer()
      }
    }
    .width('100%')
    .height('100%')
  }

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
              ForEach(this.getCoursesByDay(day.dayIndex), (course: CourseItem) => {
                this.buildCourseCard(course)
              }, (course: CourseItem) => course.id + this.currentWeek.toString())
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

        Button('编辑课程表')
          .width('100%')
          .height(48)
          .fontSize(26)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(8)
          .onClick(() => {
            promptAction.showToast({ message: '课程编辑功能后续开放' });
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 24 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  @Builder
  buildCourseCard(course: CourseItem) {
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

  @Builder
  buildPlaceholder(icon: string, title: string, description: string) {
    Column({ space: 24 }) {
      Stack() {
        Circle()
          .width(140)
          .height(140)
          .fill('#E8F3FF')
        Text(icon)
          .fontSize(64)
      }

      Column({ space: 8 }) {
        Text(title)
          .fontSize(28)
          .fontWeight(700)
          .fontColor('#1677FF')
          .maxLines(1)
        Text(description)
          .fontSize(24)
          .fontColor('#86909C')
          .textAlign(TextAlign.Center)
          .padding({ left: 32, right: 32 })
          .maxLines(2)
      }
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 60, bottom: 60 })
    .backgroundColor('#F5F7FA')
  }

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

        Button('我知道了')
          .width('100%')
          .height(48)
          .fontSize(26)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(8)
          .margin({ top: 8 })
          .onClick(() => {
            this.closeCourseDetail();
          })
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
