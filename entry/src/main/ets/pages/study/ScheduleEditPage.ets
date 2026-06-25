/**
 * ScheduleEditPage.ets - 课程编辑页（仅编辑已有课程）
 * 接收 courseId 参数，从 RDB 加载数据回显，用户修改后手动保存
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
  @State isLoading: boolean = true;

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
    try {
      const params: Record<string, string> = router.getParams() as Record<string, string>;
      if (!params || !params['courseId']) {
        promptAction.showToast({ message: '缺少课程参数' });
        router.back();
        return;
      }
      this.courseId = params['courseId'];
      this.loadCourse(this.courseId);
    } catch (_e) {
      promptAction.showToast({ message: '加载课程失败' });
      router.back();
    }
  }

  private loadCourse(id: string): void {
    try {
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
            this.isLoading = false;
            return;
          }
        }
        promptAction.showToast({ message: '未找到该课程' });
        router.back();
      });
    } catch (_e) {
      promptAction.showToast({ message: '加载失败' });
      router.back();
    }
  }

  private saveCourse(): void {
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

    try {
      const ctx: Context = getContext(this);
      const row: CourseRow = {
        id: this.courseId,
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

      CourseDao.update(ctx, row).then(() => {
        promptAction.showToast({ message: '课程已更新' });
        router.back();
      });
    } catch (_e) {
      promptAction.showToast({ message: '保存失败' });
    }
  }

  private deleteCourse(): void {
    try {
      const ctx: Context = getContext(this);
      CourseDao.deleteById(ctx, this.courseId).then(() => {
        promptAction.showToast({ message: '课程已删除' });
        router.back();
      });
    } catch (_e) {
      promptAction.showToast({ message: '删除失败' });
    }
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24).fillColor('#1D2129')
          .onClick(() => { router.back(); })
        Blank()
        Text('编辑课程')
          .fontSize(30).fontWeight(600).fontColor('#1D2129')
        Blank()
        Row().width(24)
      }
      .width('100%').height(56).padding({ left: 16, right: 20 })
      .backgroundColor('#FFFFFF').alignItems(VerticalAlign.Center)

      if (this.isLoading) {
        Column() {
          Text('加载中...').fontSize(26).fontColor('#86909C')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            // 基本信息
            Column({ space: 16 }) {
              Text('基本信息').fontSize(28).fontWeight(700).fontColor('#1D2129')
              this.buildFormField('课程名称', this.courseName,
                (val: string) => { this.courseName = val; }, '请输入课程名称')
              this.buildFormField('授课老师', this.teacher,
                (val: string) => { this.teacher = val; }, '请输入授课老师')
              this.buildFormField('上课地点', this.location,
                (val: string) => { this.location = val; }, '请输入上课地点')
            }
            .width('100%').padding(16)
            .backgroundColor('#FFFFFF').borderRadius(8)

            // 上课时间
            Column({ space: 16 }) {
              Text('上课时间').fontSize(28).fontWeight(700).fontColor('#1D2129')
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
                      .onClick(() => { this.dayIndex = opt.value; })
                  }, (opt: DayOption) => opt.label)
                }
                .width('100%')
              }

              Row({ space: 16 }) {
                this.buildTimeField('开始时间', this.startTime,
                  (val: string) => { this.startTime = val; }, '如 08:00')
                this.buildTimeField('结束时间', this.endTime,
                  (val: string) => { this.endTime = val; }, '如 09:40')
              }
              .width('100%')

              Row({ space: 16 }) {
                this.buildWeekField('起始周', this.startWeek,
                  (val: number) => { this.startWeek = val; })
                this.buildWeekField('结束周', this.endWeek,
                  (val: number) => { this.endWeek = val; })
              }
              .width('100%')
            }
            .width('100%').padding(16)
            .backgroundColor('#FFFFFF').borderRadius(8)

            // 课程属性
            Column({ space: 16 }) {
              Text('课程属性').fontSize(28).fontWeight(700).fontColor('#1D2129')
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
                      .onClick(() => { this.courseType = opt.label; })
                  }, (opt: TypeOption) => opt.label)
                }
                .width('100%')
              }

              this.buildFormField('学分', this.credit,
                (val: string) => { this.credit = val; }, '如 3.0')

              Column({ space: 8 }) {
                Text('课程颜色').fontSize(24).fontColor('#86909C').width('100%')
                Row({ space: 12 }) {
                  ForEach(COURSE_COLORS, (c: string, idx: number) => {
                    Circle()
                      .width(36).height(36)
                      .fill(c)
                      .stroke(this.color === c ? '#1D2129' : '#00FFFFFF')
                      .strokeWidth(3)
                      .onClick(() => { this.color = c; })
                  }, (c: string, idx: number) => c + idx.toString())
                }
                .width('100%')
              }
            }
            .width('100%').padding(16)
            .backgroundColor('#FFFFFF').borderRadius(8)

            Button('保存修改')
              .width('100%').height(48)
              .fontSize(26).fontColor('#FFFFFF')
              .backgroundColor('#1677FF').borderRadius(8)
              .onClick(() => { this.saveCourse(); })

            Button('删除课程')
              .width('100%').height(48)
              .fontSize(26).fontColor('#FF7D00')
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .border({ width: 1, color: '#FF7D00' })
              .onClick(() => { this.deleteCourse(); })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 24 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
    }
    .width('100%').height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder
  buildFormField(label: string, value: string, onValChange: (val: string) => void, placeholder: string) {
    Column({ space: 8 }) {
      Text(label).fontSize(24).fontColor('#86909C').width('100%')
      TextInput({ placeholder: placeholder, text: value })
        .height(48).fontSize(26)
        .placeholderColor('#86909C')
        .backgroundColor('#F5F7FA').borderRadius(8)
        .onChange((val: string) => { onValChange(val); })
    }
    .width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildTimeField(label: string, value: string, onValChange: (val: string) => void, placeholder: string) {
    Column({ space: 8 }) {
      Text(label).fontSize(24).fontColor('#86909C').width('100%')
      TextInput({ placeholder: placeholder, text: value })
        .height(48).fontSize(26)
        .placeholderColor('#86909C')
        .backgroundColor('#F5F7FA').borderRadius(8)
        .onChange((val: string) => { onValChange(val); })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildWeekField(label: string, value: number, onValChange: (val: number) => void) {
    Column({ space: 8 }) {
      Text(label).fontSize(24).fontColor('#86909C').width('100%')
      TextInput({ placeholder: '1~20', text: value.toString() })
        .height(48).fontSize(26)
        .placeholderColor('#86909C')
        .backgroundColor('#F5F7FA').borderRadius(8)
        .onChange((val: string) => {
          const n: number = Number(val);
          if (n >= 1 && n <= 20) {
            onValChange(n);
          }
        })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }
}
