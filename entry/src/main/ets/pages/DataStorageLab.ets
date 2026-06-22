import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import { StudentDao } from '../common/database/StudentDao';
import { DatabaseHelper } from '../common/database/DatabaseHelper';
import { Student, StudentInput } from '../common/model/Student';

@Entry
@Component
struct DataStorageLab {
  @State currentTab: number = 0;
  @State studentName: string = '';
  @State studentAge: string = '';
  @State studentScore: string = '';
  @State queryKeyword: string = '';
  @State students: Student[] = [];
  @State loading: boolean = false;
  @State importDuration: number = 0;

  private context: Context = getContext(this) as Context;

  async aboutToAppear() {
    await DatabaseHelper.getRdbStore(this.context);
    await this.loadStudents();
  }

  private async loadStudents(): Promise<void> {
    const keyword = this.queryKeyword.trim();
    if (keyword.length > 0) {
      this.students = await StudentDao.queryByName(this.context, keyword);
      return;
    }
    this.students = await StudentDao.queryAll(this.context);
  }

  private getPageBackgroundColor(): string {
    return '#F5F5F5';
  }

  private getCardBackgroundColor(): string {
    return '#FFFFFF';
  }

  private getPrimaryTextColor(): string {
    return '#333333';
  }

  private getSecondaryTextColor(): string {
    return '#666666';
  }

  private buildRandomStudents(count: number): StudentInput[] {
    const students: StudentInput[] = [];
    for (let index = 0; index < count; index++) {
      students.push({
        name: `学生${Date.now()}_${index + 1}`,
        age: 18 + (index % 5),
        score: 60 + (index % 40)
      });
    }
    return students;
  }

  private async addStudent(): Promise<void> {
    const name = this.studentName.trim();
    const age = Number(this.studentAge);
    const score = Number(this.studentScore);

    if (!name) {
      promptAction.showToast({ message: '请输入姓名' });
      return;
    }
    if (!Number.isFinite(age) || age <= 0) {
      promptAction.showToast({ message: '请输入有效年龄' });
      return;
    }
    if (!Number.isFinite(score)) {
      promptAction.showToast({ message: '请输入有效分数' });
      return;
    }

    await StudentDao.insert(this.context, { name, age, score });
    this.studentName = '';
    this.studentAge = '';
    this.studentScore = '';
    await this.loadStudents();
    promptAction.showToast({ message: '新增成功' });
  }

  private async queryStudents(): Promise<void> {
    this.students = await StudentDao.queryByName(this.context, this.queryKeyword);
    promptAction.showToast({ message: `查询到 ${this.students.length} 条记录` });
  }

  private async refreshStudents(): Promise<void> {
    this.queryKeyword = '';
    await this.loadStudents();
  }

  private async updateStudentScore(student: Student): Promise<void> {
    const nextScore = Number((student.score + 1).toFixed(1));
    await StudentDao.updateScore(this.context, student.id!, nextScore);
    await this.loadStudents();
    promptAction.showToast({ message: `已将 ${student.name} 分数更新为 ${nextScore}` });
  }

  private async deleteStudent(student: Student): Promise<void> {
    await StudentDao.deleteById(this.context, student.id!);
    await this.loadStudents();
    promptAction.showToast({ message: `已删除 ${student.name}` });
  }

  private async batchInsertStudents(): Promise<void> {
    if (this.loading) {
      return;
    }

    this.loading = true;
    const startTime = Date.now();
    try {
      await StudentDao.batchInsert(this.context, this.buildRandomStudents(100));
      this.importDuration = Date.now() - startTime;
      await this.loadStudents();
      promptAction.showToast({ message: '100 条测试数据导入成功' });
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column() {
      this.buildHeader();

      Column({ space: 12 }) {
        this.buildTabBar();

        if (this.currentTab === 0) {
          this.buildStudentManageSection();
        } else {
          this.buildStudentListSection();
        }
      }
      .layoutWeight(1)
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.getPageBackgroundColor())
  }

  @Builder
  private buildHeader() {
    Row() {
      Text('< 返回')
        .fontSize(16)
        .fontColor('#007DFF')
        .onClick(() => {
          router.back();
        })

      Blank()

      Text('数据存储实验')
        .fontSize(20)
        .fontWeight(700)
        .fontColor(this.getPrimaryTextColor())

      Blank()

      Row()
        .width(52)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.getCardBackgroundColor())
  }

  @Builder
  private buildSummaryCard() {
    Column({ space: 8 }) {
      Text('学生信息管理实验')
        .fontSize(18)
        .fontWeight(700)
        .fontColor(this.getPrimaryTextColor())
      Text(`学生总数：${this.students.length}`)
        .fontSize(14)
        .fontColor(this.getSecondaryTextColor())
      Text(`批量导入耗时：${this.importDuration} ms`)
        .fontSize(14)
        .fontColor(this.getSecondaryTextColor())
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.getCardBackgroundColor())
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildTabBar() {
    Row({ space: 12 }) {
      this.buildTabButton('学生管理', 0);
      this.buildTabButton('数据展示', 1);
    }
    .width('100%')
  }

  @Builder
  private buildTabButton(title: string, index: number) {
    Button(title)
      .layoutWeight(1)
      .height(40)
      .fontSize(14)
      .fontColor(this.currentTab === index ? '#FFFFFF' : '#007DFF')
      .backgroundColor(this.currentTab === index ? '#007DFF' : this.getCardBackgroundColor())
      .borderRadius(20)
      .onClick(() => {
        this.currentTab = index;
      })
  }

  @Builder
  private buildStudentManageSection() {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 12 }) {
          Text('新增学生')
            .fontSize(16)
            .fontWeight(600)
            .fontColor(this.getPrimaryTextColor())

          TextInput({ placeholder: '姓名', text: this.studentName })
            .fontSize(16)
            .onChange((value: string) => {
              this.studentName = value;
            })

          TextInput({ placeholder: '年龄', text: this.studentAge })
            .fontSize(16)
            .type(InputType.Number)
            .onChange((value: string) => {
              this.studentAge = value;
            })

          TextInput({ placeholder: '分数', text: this.studentScore })
            .fontSize(16)
            .type(InputType.Number)
            .onChange((value: string) => {
              this.studentScore = value;
            })

          Button('新增学生')
            .width('100%')
            .height(44)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#007DFF')
            .borderRadius(10)
            .onClick(() => {
              this.addStudent();
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.getCardBackgroundColor())
        .borderRadius(12)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 12 }) {
          Text('查询与批量操作')
            .fontSize(16)
            .fontWeight(600)
            .fontColor(this.getPrimaryTextColor())

          TextInput({ placeholder: '按姓名模糊查询', text: this.queryKeyword })
            .fontSize(16)
            .onChange((value: string) => {
              this.queryKeyword = value;
            })

          Row({ space: 12 }) {
            Button('查询')
              .layoutWeight(1)
              .height(40)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('#007DFF')
              .borderRadius(10)
              .onClick(() => {
                this.queryStudents();
              })

            Button('刷新全部')
              .layoutWeight(1)
              .height(40)
              .fontSize(16)
              .fontColor('#007DFF')
              .backgroundColor('#EAF3FF')
              .borderRadius(10)
              .onClick(() => {
                this.refreshStudents();
              })
          }
          .width('100%')

          Button(this.loading ? '导入中...' : '生成100条随机数据')
            .width('100%')
            .height(44)
            .enabled(!this.loading)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor(this.loading ? '#A0CFFF' : '#52C41A')
            .borderRadius(10)
            .onClick(() => {
              this.batchInsertStudents();
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.getCardBackgroundColor())
        .borderRadius(12)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  private buildStudentListSection() {
    List({ space: 12 }) {
      ForEach(this.students, (student: Student) => {
        ListItem() {
          Column({ space: 10 }) {
            Row({ space: 12 }) {
              Text(`${student.name}（ID: ${student.id ?? 0}）`)
                .layoutWeight(1)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .fontSize(16)
                .fontWeight(600)
                .fontColor(this.getPrimaryTextColor())
              Text(`分数 ${student.score}`)
                .fontSize(16)
                .fontColor('#007DFF')
            }
            .width('100%')

            Text(`年龄：${student.age}  更新时间：${student.updateTime}`)
              .fontSize(13)
              .fontColor(this.getSecondaryTextColor())

            Row({ space: 12 }) {
              Button('分数+1')
                .layoutWeight(1)
                .height(36)
                .fontSize(13)
                .fontColor('#FFFFFF')
                .backgroundColor('#007DFF')
                .borderRadius(8)
                .onClick(() => {
                  this.updateStudentScore(student);
                })

              Button('删除')
                .layoutWeight(1)
                .height(36)
                .fontSize(13)
                .fontColor('#FFFFFF')
                .backgroundColor('#F53F3F')
                .borderRadius(8)
                .onClick(() => {
                  this.deleteStudent(student);
                })
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.getCardBackgroundColor())
          .borderRadius(12)
          .alignItems(HorizontalAlign.Start)
        }
      }, (student: Student) => `${student.id ?? 0}`)
    }
    .width('100%')
    .layoutWeight(1)
  }
}
