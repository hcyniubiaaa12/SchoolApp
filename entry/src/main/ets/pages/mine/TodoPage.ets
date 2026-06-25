/**
 * TodoPage.ets - 待办事项管理页
 * 新增/删除/标记完成/分类查看
 */
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';

interface TodoItem {
  id: string;
  content: string;
  category: string;
  isCompleted: boolean;
  remindTime: string;
  createTime: string;
}

@Entry
@Component
struct TodoPage {
  @State todos: TodoItem[] = [
    { id: 't1', content: '提交数据结构课程设计报告', category: '学习', isCompleted: false, remindTime: '2026-06-28 23:59', createTime: '2026-06-20' },
    { id: 't2', content: '购买实验器材', category: '生活', isCompleted: false, remindTime: '2026-06-26 18:00', createTime: '2026-06-19' },
    { id: 't3', content: '复习高等数学期末考试', category: '学习', isCompleted: true, remindTime: '2026-07-01 08:00', createTime: '2026-06-15' },
    { id: 't4', content: '参加社团例会', category: '其他', isCompleted: false, remindTime: '2026-06-27 19:00', createTime: '2026-06-14' },
  ];
  @State currentFilter: string = '全部';
  @State showAddInput: boolean = false;
  @State newTodoContent: string = '';
  @State newTodoCategory: string = '学习';
  @State batchMode: boolean = false;
  @State selectedIds: string[] = [];

  private filters: string[] = ['全部', '学习', '生活', '其他'];
  private categories: string[] = ['学习', '生活', '其他'];

  private get filteredTodos(): TodoItem[] {
    if (this.currentFilter === '全部') {
      return this.todos;
    }
    const result: TodoItem[] = [];
    for (let i = 0; i < this.todos.length; i++) {
      if (this.todos[i].category === this.currentFilter) {
        result.push(this.todos[i]);
      }
    }
    return result;
  }

  private get pendingCount(): number {
    let count: number = 0;
    for (let i = 0; i < this.todos.length; i++) {
      if (!this.todos[i].isCompleted) {
        count++;
      }
    }
    return count;
  }

  private addTodo(): void {
    if (this.newTodoContent.trim() === '') {
      promptAction.showToast({ message: '请输入待办内容' });
      return;
    }
    const now: string = new Date().toISOString().substring(0, 10);
    const newTodo: TodoItem = {
      id: 't' + Date.now().toString(),
      content: this.newTodoContent.trim(),
      category: this.newTodoCategory,
      isCompleted: false,
      remindTime: '',
      createTime: now
    };
    const newList: TodoItem[] = [newTodo];
    for (let i = 0; i < this.todos.length; i++) {
      newList.push(this.todos[i]);
    }
    this.todos = newList;
    this.newTodoContent = '';
    this.showAddInput = false;
    promptAction.showToast({ message: '已添加待办' });
  }

  private toggleComplete(id: string): void {
    for (let i = 0; i < this.todos.length; i++) {
      if (this.todos[i].id === id) {
        this.todos[i].isCompleted = !this.todos[i].isCompleted;
        return;
      }
    }
  }

  private deleteTodo(id: string): void {
    const newList: TodoItem[] = [];
    for (let i = 0; i < this.todos.length; i++) {
      if (this.todos[i].id !== id) {
        newList.push(this.todos[i]);
      }
    }
    this.todos = newList;
    promptAction.showToast({ message: '已删除待办' });
  }

  private toggleSelect(id: string): void {
    const index: number = this.selectedIds.indexOf(id);
    if (index >= 0) {
      this.selectedIds.splice(index, 1);
    } else {
      this.selectedIds.push(id);
    }
  }

  private batchDelete(): void {
    if (this.selectedIds.length === 0) {
      promptAction.showToast({ message: '请选择要删除的待办' });
      return;
    }
    const newList: TodoItem[] = [];
    for (let i = 0; i < this.todos.length; i++) {
      if (this.selectedIds.indexOf(this.todos[i].id) < 0) {
        newList.push(this.todos[i]);
      }
    }
    this.todos = newList;
    this.selectedIds = [];
    this.batchMode = false;
    promptAction.showToast({ message: '批量删除成功' });
  }

  private batchComplete(): void {
    if (this.selectedIds.length === 0) {
      promptAction.showToast({ message: '请选择待办' });
      return;
    }
    for (let i = 0; i < this.todos.length; i++) {
      if (this.selectedIds.indexOf(this.todos[i].id) >= 0) {
        this.todos[i].isCompleted = true;
      }
    }
    this.selectedIds = [];
    this.batchMode = false;
    promptAction.showToast({ message: '已标记完成' });
  }

  private getCategoryColor(category: string): string {
    if (category === '学习') return '#1677FF';
    if (category === '生活') return '#00B42A';
    return '#FF7D00';
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24).fillColor('#1D2129')
          .onClick(() => { router.back(); })
        Blank()
        Text('我的待办')
          .fontSize(30).fontWeight(600).fontColor('#1D2129')
          .layoutWeight(1).textAlign(TextAlign.Center)
        Blank()
        Text(this.batchMode ? '取消' : '批量')
          .fontSize(24).fontColor('#1677FF')
          .onClick(() => {
            this.batchMode = !this.batchMode;
            if (!this.batchMode) {
              this.selectedIds = [];
            }
          })
      }
      .width('100%').height(56).padding({ left: 16, right: 20 })
      .backgroundColor('#FFFFFF').alignItems(VerticalAlign.Center)

      // 概况
      Row() {
        Text('待完成 ' + this.pendingCount.toString() + ' 项')
          .fontSize(22).fontColor('#FF7D00')
        Blank()
        if (this.batchMode) {
          Row({ space: 8 }) {
            Text('完成')
              .fontSize(22).fontColor('#00B42A')
              .onClick(() => { this.batchComplete(); })
            Text('|').fontSize(22).fontColor('#E5E6EB')
            Text('删除')
              .fontSize(22).fontColor('#FF7D00')
              .onClick(() => { this.batchDelete(); })
          }
        }
      }
      .width('100%').padding({ left: 20, right: 20, top: 8, bottom: 8 })
      .backgroundColor('#FFF3E0')

      // 分类筛选
      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.filters, (filter: string) => {
            Text(filter)
              .fontSize(22)
              .fontColor(this.currentFilter === filter ? '#FFFFFF' : '#1D2129')
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
              .backgroundColor(this.currentFilter === filter ? '#1677FF' : '#F5F7FA')
              .borderRadius(20)
              .onClick(() => { this.currentFilter = filter; })
          }, (filter: string) => filter)
        }
        .padding({ left: 20, right: 20, top: 12, bottom: 12 })
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)
      .backgroundColor('#FFFFFF')

      // 新增待办输入区
      if (this.showAddInput) {
        Column({ space: 12 }) {
          TextInput({ placeholder: '输入待办内容', text: this.newTodoContent })
            .height(48).fontSize(26)
            .placeholderColor('#86909C')
            .backgroundColor('#F5F7FA').borderRadius(8)
            .onChange((val: string) => { this.newTodoContent = val; })

          Row({ space: 12 }) {
            ForEach(this.categories, (cat: string) => {
              Text(cat)
                .fontSize(22)
                .fontColor(this.newTodoCategory === cat ? '#FFFFFF' : '#1D2129')
                .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                .backgroundColor(this.newTodoCategory === cat ? '#1677FF' : '#F5F7FA')
                .borderRadius(12)
                .onClick(() => { this.newTodoCategory = cat; })
            }, (cat: string) => cat)
          }
          .width('100%')

          Button('添加')
            .width('100%').height(44)
            .fontSize(24).fontColor('#FFFFFF')
            .backgroundColor('#1677FF').borderRadius(8)
            .onClick(() => { this.addTodo(); })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
      }

      // 待办列表
      Scroll() {
        Column({ space: 8 }) {
          if (this.filteredTodos.length === 0) {
            Column({ space: 16 }) {
              Text('✅')
                .fontSize(48)
              Text('暂无待办事项')
                .fontSize(26).fontColor('#86909C')
            }
            .width('100%').height(200)
            .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          } else {
            ForEach(this.filteredTodos, (item: TodoItem) => {
              Column({ space: 8 }) {
                Row() {
                  if (this.batchMode) {
                    // 批量选择模式
                    Text(this.selectedIds.indexOf(item.id) >= 0 ? '☑️' : '⬜')
                      .fontSize(24)
                      .onClick(() => { this.toggleSelect(item.id); })
                      .margin({ right: 8 })
                  }

                  // 完成状态
                  Text(item.isCompleted ? '✅' : '⭕')
                    .fontSize(24)
                    .onClick(() => { this.toggleComplete(item.id); })
                    .margin({ right: 8 })

                  Column({ space: 4 }) {
                    Text(item.content)
                      .fontSize(26)
                      .fontColor(item.isCompleted ? '#86909C' : '#1D2129')
                      .decoration({ type: item.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
                      .layoutWeight(1)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })

                    Row({ space: 8 }) {
                      Text(item.category)
                        .fontSize(20)
                        .fontColor('#FFFFFF')
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .backgroundColor(this.getCategoryColor(item.category))
                        .borderRadius(4)

                      if (item.remindTime !== '') {
                        Text('⏰' + item.remindTime)
                          .fontSize(20).fontColor('#86909C')
                      }

                      Text(item.createTime)
                        .fontSize(20).fontColor('#86909C')
                    }
                    .width('100%')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  if (!this.batchMode) {
                    Text('🗑️')
                      .fontSize(22)
                      .onClick(() => { this.deleteTodo(item.id); })
                  }
                }
                .width('100%').padding(12)
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
                .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 1 })
                .alignItems(VerticalAlign.Center)
              }
            }, (item: TodoItem) => item.id)
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 12, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)

      // 底部添加按钮
      if (!this.showAddInput) {
        Button('+ 新增待办')
          .width('90%').height(48)
          .fontSize(26).fontColor('#FFFFFF')
          .backgroundColor('#1677FF').borderRadius(8)
          .margin({ bottom: 16 })
          .onClick(() => {
            this.showAddInput = true;
          })
      }
    }
    .width('100%').height('100%')
    .backgroundColor('#F5F7FA')
  }
}
