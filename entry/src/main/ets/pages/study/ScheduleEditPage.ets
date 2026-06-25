/**
 * ScheduleEditPage.ets - 课程表编辑页
 * 添加/修改/删除课程，数据通过 CourseDao 持久化到 RDB
 */
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import { CourseDao, CourseRow } from '../../common/database/CourseDao';

interface DayOption {
  label: string;
  value: number;
}

interface TypeOption {
  label: string;
}

const COURSE_COLORS: string[] = ['#1677FF', '#FF7D00', '#00B42A', '#722ED1', '#EB2F96'];

@Entry
@Component
struct ScheduleEditPage {
  @State courseId: string = '';
  @State courseName: string = '';
  @State teacher: string = '';
  @State location: string = '';
  @State dayIndex: number = 1;
  @State startTime: string = '';
  @State endTime: string = '';
  @State startWeek: number = 1;
  @State endWeek: number = 16;
  @State courseType: string = '必修';
  @State credit: string = '';
  @State color: string = COURSE_COLORS[0];
  @State isEditing: boolean = false;

  private dayOptions: DayOption[] = [
    { label: '周一', value: 1 }, { label: '周二', value: 2 },
    { label: '周三', value: 3 }, { label: '周四', value: 4 },
    { label: '周五', value: 5 }, { label: '周六', value: 6 },
    { label: '周日', value: 7 }
  ];

  private typeOptions: TypeOption[] = [
    { label: '必修' }, { label: '选修' }, { label: '公共课' }, { label: '实践' }
  ];

  aboutToAppear(): void {
    const params: Record<string, string> = router.getParams() as Record<string, string>;
    const editId: string = params['courseId'];
    if (editId) {
      this.courseId = editId;
      this.isEditing = true;
      this.loadCourse(editId);
    }
  }

  private loadCourse(id: string): void {
    const ctx: Context = getContext(this);
    CourseDao.queryAll(ctx).then((courses: CourseRow[]) => {
      for (let i = 0; i < courses.length; i++) {
        if (courses[i].id === id) {
          const c: CourseRow = courses[i];
          this.courseName = c.name;
          this.teacher = c.teacher;
          this.location = c.location;
          this.dayIndex = c.dayIndex;
          this.startTime = c.startTime;
          this.endTime = c.endTime;
          this.startWeek = c.startWeek;
          this.endWeek = c.endWeek;
          this.courseType = c.courseType;
          this.credit = c.credit;
          this.color = c.color;
          return;
        }
      }
    });
  }

  private saveCourse(): void {
    // 表单验证
    if (this.courseName.trim() === '') {
      promptAction.showToast({ message: '请输入课程名称' });
      return;
    }
    if (this.startTime === '' || this.endTime === '') {
      promptAction.showToast({ message: '请填写上课时间' });
      return;
    }
    if (this.credit === '') {
      promptAction.showToast({ message: '请填写学分' });
      return;
    }

    const ctx: Context = getContext(this);
    const id: string = this.isEditing ? this.courseId : 'c' + Date.now().toString();
    const row: CourseRow = {
      id: id,
      name: this.courseName.trim(),
      teacher: this.teacher.trim(),
      location: this.location.trim(),
      dayIndex: this.dayIndex,
      startTime: this.startTime,
      endTime: this.endTime,
      startWeek: this.startWeek,
      endWeek: this.endWeek,
      courseType: this.courseType,
      color: this.color,
      credit: this.credit,
      remark: ''
    };

    if (this.isEditing) {
      CourseDao.update(ctx, row).then(() => {
        promptAction.showToast({ message: '课程已更新' });
        router.back();
      }).catch(() => {
        promptAction.showToast({ message: '更新失败' });
      });
    } else {
      CourseDao.insert(ctx, row).then(() => {
        promptAction.showToast({ message: '课程已添加' });
        router.back();
      }).catch(() => {
        promptAction.showToast({ message: '添加失败' });
      });
    }
  }

  private deleteCourse(): void {
    if (!this.isEditing) {
      return;
    }
    const ctx: Context = getContext(this);
    CourseDao.deleteById(ctx, this.courseId).then(() => {
      promptAction.showToast({ message: '课程已删除' });
      router.back();
    }).catch(() => {
      promptAction.showToast({ message: '删除失败' });
    });
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24).fillColor('#1D2129')
          .onClick(() => { router.back(); })
        Blank()
        Text(this.isEditing ? '编辑课程' : '添加课程')
          .fontSize(30).fontWeight(600).fontColor('#1D2129')
        Blank()
        Row().width(24)
      }
      .width('100%').height(56).padding({ left: 16, right: 20 })
      .backgroundColor('#FFFFFF').alignItems(VerticalAlign.Center)

      Scroll() {
        Column({ space: 16 }) {
          // 基本信息卡片
          Column({ space: 16 }) {
            Text('基本信息').fontSize(28).fontWeight(700).fontColor('#1D2129')

            this.buildInputField('课程名称', this.courseName,
              (val: string) => { this.courseName = val; }, '请输入课程名称')
            this.buildInputField('授课老师', this.teacher,
              (val: string) => { this.teacher = val; }, '请输入授课老师')
            this.buildInputField('上课地点', this.location,
              (val: string) => { this.location = val; }, '请输入上课地点')
          }
          .width('100%').padding(16)
          .backgroundColor('#FFFFFF').borderRadius(8)

          // 时间设置卡片
          Column({ space: 16 }) {
            Text('上课时间').fontSize(28).fontWeight(700).fontColor('#1D2129')

            // 星期选择
            Column({ space: 8 }) {
              Text('星期').fontSize(24).fontColor('#86909C').width('100%')
              Row({ space: 8 }) {
                ForEach(this.dayOptions, (opt: DayOption) => {
                  Text(opt.label)
                    .fontSize(22)
                    .fontColor(this.dayIndex === opt.value ? '#FFFFFF' : '#1D2129')
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.dayIndex === opt.value ? '#1677FF' : '#F5F7FA')
                    .borderRadius(6)
                    .onClick(() => {
                      this.dayIndex = opt.value;
                    })
                }, (opt: DayOption) => opt.label)
              }
              .width('100%')
            }

            // 时间输入
            Row({ space: 16 }) {
              Column({ space: 8 }) {
                Text('开始时间').fontSize(24).fontColor('#86909C').width('100%')
                TextInput({ placeholder: '如 08:00', text: this.startTime })
                  .height(48).fontSize(26)
                  .placeholderColor('#86909C')
                  .backgroundColor('#F5F7FA').borderRadius(8)
                  .onChange((val: string) => { this.startTime = val; })
              }
              .layoutWeight(1)

              Column({ space: 8 }) {
                Text('结束时间').fontSize(24).fontColor('#86909C').width('100%')
                TextInput({ placeholder: '如 09:40', text: this.endTime })
                  .height(48).fontSize(26)
                  .placeholderColor('#86909C')
                  .backgroundColor('#F5F7FA').borderRadius(8)
                  .onChange((val: string) => { this.endTime = val; })
              }
              .layoutWeight(1)
            }
            .width('100%')

            // 周次范围
            Row({ space: 16 }) {
              Column({ space: 8 }) {
                Text('起始周').fontSize(24).fontColor('#86909C').width('100%')
                TextInput({ placeholder: '如 1', text: this.startWeek.toString() })
                  .height(48).fontSize(26)
                  .placeholderColor('#86909C')
                  .backgroundColor('#F5F7FA').borderRadius(8)
                  .onChange((val: string) => {
                    const n: number = parseInt(val);
                    if (!isNaN(n) && n >= 1 && n <= 20) {
                      this.startWeek = n;
                    }
                  })
              }
              .layoutWeight(1)

              Column({ space: 8 }) {
                Text('结束周').fontSize(24).fontColor('#86909C').width('100%')
                TextInput({ placeholder: '如 16', text: this.endWeek.toString() })
                  .height(48).fontSize(26)
                  .placeholderColor('#86909C')
                  .backgroundColor('#F5F7FA').borderRadius(8)
                  .onChange((val: string) => {
                    const n: number = parseInt(val);
                    if (!isNaN(n) && n >= 1 && n <= 20) {
                      this.endWeek = n;
                    }
                  })
              }
              .layoutWeight(1)
            }
            .width('100%')
          }
          .width('100%').padding(16)
          .backgroundColor('#FFFFFF').borderRadius(8)

          // 课程类型与学分
          Column({ space: 16 }) {
            Text('课程属性').fontSize(28).fontWeight(700).fontColor('#1D2129')

            // 课程类型
            Column({ space: 8 }) {
              Text('课程类型').fontSize(24).fontColor('#86909C').width('100%')
              Row({ space: 8 }) {
                ForEach(this.typeOptions, (opt: TypeOption) => {
                  Text(opt.label)
                    .fontSize(22)
                    .fontColor(this.courseType === opt.label ? '#FFFFFF' : '#1D2129')
                    .padding({ left: 16, right: 16, top: 6, bottom: 6 })
                    .backgroundColor(this.courseType === opt.label ? '#1677FF' : '#F5F7FA')
                    .borderRadius(6)
                    .onClick(() => {
                      this.courseType = opt.label;
                    })
                }, (opt: TypeOption) => opt.label)
              }
              .width('100%')
            }

            this.buildInputField('学分', this.credit,
              (val: string) => { this.credit = val; }, '如 3.0')

            // 课程颜色
            Column({ space: 8 }) {
              Text('课程颜色').fontSize(24).fontColor('#86909C').width('100%')
              Row({ space: 12 }) {
                ForEach(COURSE_COLORS, (c: string) => {
                  Circle()
                    .width(36).height(36)
                    .fill(c)
                    .stroke(this.color === c ? '#1D2129' : '#00FFFFFF')
                    .strokeWidth(3)
                    .onClick(() => {
                      this.color = c;
                    })
                }, (c: string) => c)
              }
              .width('100%')
            }
          }
          .width('100%').padding(16)
          .backgroundColor('#FFFFFF').borderRadius(8)

          // 保存按钮
          Button('保存课程')
            .width('100%').height(48)
            .fontSize(26).fontColor('#FFFFFF')
            .backgroundColor('#1677FF').borderRadius(8)
            .onClick(() => {
              this.saveCourse();
            })

          // 删除按钮（仅编辑模式）
          if (this.isEditing) {
            Button('删除课程')
              .width('100%').height(48)
              .fontSize(26).fontColor('#FF7D00')
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .border({ width: 1, color: '#FF7D00' })
              .onClick(() => {
                this.deleteCourse();
              })
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%').height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder
  buildInputField(label: string, value: string, onChange: (val: string) => void, placeholder: string) {
    Column({ space: 8 }) {
      Text(label).fontSize(24).fontColor('#86909C').width('100%')
      TextInput({ placeholder: placeholder, text: value })
        .height(48).fontSize(26)
        .placeholderColor('#86909C')
        .backgroundColor('#F5F7FA').borderRadius(8)
        .onChange((val: string) => { onChange(val); })
    }
    .width('100%').alignItems(HorizontalAlign.Start)
  }
}
