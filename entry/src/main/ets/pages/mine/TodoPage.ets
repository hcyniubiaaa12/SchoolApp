/**
 * TodoPage.ets - 待办事项管理页
 * 新增/删除/标记完成/分类查看 + Preferences 持久化（异步 API）
 *
 * 数据流：aboutToAppear 异步加载，每次增删改后保存。
 * 使用 async Preferences API 避免 aboutToAppear 中 sync 调用导致闪退。
 */
import { router } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import promptAction from '@ohos.promptAction';

interface TodoItem {
  id: string;
  content: string;
  category: string;
  isCompleted: boolean;
  remindTime: string;
  createTime: string;
}

const TODO_PREFS_NAME: string = 'school_app_prefs';
const KEY_TODO_DATA: string = 'todo_data_json';

@Entry
@Component
struct TodoPage {
  @State todos: TodoItem[] = [];
  @State currentFilter: string = '全部';
  @State showAddInput: boolean = false;
  @State newTodoContent: string = '';
  @State newTodoCategory: string = '学习';
  @State batchMode: boolean = false;
  @State selectedIds: string[] = [];

  private filters: string[] = ['全部', '学习', '生活', '其他'];
  private categories: string[] = ['学习', '生活', '其他'];

  aboutToAppear(): void {
    this.loadTodos();
  }

  // ===== Preferences 持久化（异步 API，与 PreferencesUtil 一致） =====

  /** 获取 Preferences 实例 */
  private async getPref(context: Context): Promise<preferences.Preferences> {
    return preferences.getPreferences(context, TODO_PREFS_NAME);
  }

  /** 从 Preferences 异步加载待办数据 */
  private async loadTodos(): Promise<void> {
    try {
      const ctx: Context = getContext(this);
      const pref = await this.getPref(ctx);
      const json: string = await pref.get(KEY_TODO_DATA, '') as string;
      if (json === '') {
        // 首次：使用演示数据
        this.todos = [
          { id: 't1', content: '提交数据结构课程设计报告', category: '学习', isCompleted: false, remindTime: '2026-06-28 23:59', createTime: '2026-06-20' },
          { id: 't2', content: '购买实验器材', category: '生活', isCompleted: false, remindTime: '2026-06-26 18:00', createTime: '2026-06-19' },
          { id: 't3', content: '复习高等数学期末考试', category: '学习', isCompleted: true, remindTime: '2026-07-01 08:00', createTime: '2026-06-15' },
          { id: 't4', content: '参加社团例会', category: '其他', isCompleted: false, remindTime: '2026-06-27 19:00', createTime: '2026-06-14' },
        ];
        await this.saveTodos();
      } else {
        this.todos = JSON.parse(json) as TodoItem[];
      }
    } catch (err) {
      console.error('[TodoPage] 加载待办失败: ' + JSON.stringify(err));
      this.todos = [];
    }
  }

  /** 异步保存待办数据到 Preferences */
  private async saveTodos(): Promise<void> {
    try {
      const ctx: Context = getContext(this);
      const pref = await this.getPref(ctx);
      await pref.put(KEY_TODO_DATA, JSON.stringify(this.todos));
      await pref.flush();
    } catch (err) {
      console.error('[TodoPage] 保存待办失败: ' + JSON.stringify(err));
    }
  }

  // ===== 业务逻辑 =====

  private getFilteredTodos(): TodoItem[] {
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

  private getPendingCount(): number {
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
    this.saveTodos();
    promptAction.showToast({ message: '已添加待办' });
  }

  private toggleComplete(id: string): void {
    for (let i = 0; i < this.todos.length; i++) {
      if (this.todos[i].id === id) {
        this.todos[i].isCompleted = !this.todos[i].isCompleted;
        this.saveTodos();
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
    this.saveTodos();
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
    this.saveTodos();
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
    this.saveTodos();
    promptAction.showToast({ message: '已标记完成' });
  }

  private getCategoryColor(category: string): Resource {
    if (category === '学习') return $r('app.color.primary');
    if (category === '生活') return $r('app.color.fresh_green');
    return $r('app.color.warm_orange');
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
          .fontSize(24).fontColor($r('app.color.primary'))
          .onClick(() => {
            this.batchMode = !this.batchMode;
            if (!this.batchMode) {
              this.selectedIds = [];
            }
          })
      }
      .width('100%').height(56).padding({ left: 16, right: 20 })
      .backgroundColor($r('app.color.card_white')).alignItems(VerticalAlign.Center)

      // 概况
      Row() {
        Text('待完成 ' + this.getPendingCount().toString() + ' 项')
          .fontSize(22).fontColor($r('app.color.warm_orange'))
        Blank()
        if (this.batchMode) {
          Row({ space: 8 }) {
            Text('完成')
              .fontSize(22).fontColor($r('app.color.fresh_green'))
              .onClick(() => { this.batchComplete(); })
            Text('|').fontSize(22).fontColor($r('app.color.border'))
            Text('删除')
              .fontSize(22).fontColor($r('app.color.warm_orange'))
              .onClick(() => { this.batchDelete(); })
          }
        }
      }
      .width('100%').padding({ left: 20, right: 20, top: 8, bottom: 8 })
      .backgroundColor($r('app.color.warm_orange'))

      // 分类筛选
      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.filters, (filter: string) => {
            Text(filter)
              .fontSize(22)
              .fontColor(this.currentFilter === filter ? $r('app.color.card_white') : '#1D2129')
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
              .backgroundColor(this.currentFilter === filter ? $r('app.color.primary') : $r('app.color.background'))
              .borderRadius(20)
              .onClick(() => { this.currentFilter = filter; })
          }, (filter: string) => filter)
        }
        .padding({ left: 20, right: 20, top: 12, bottom: 12 })
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)
      .backgroundColor($r('app.color.card_white'))

      // 新增待办输入区
      if (this.showAddInput) {
        Column({ space: 12 }) {
          TextInput({ placeholder: '输入待办内容', text: this.newTodoContent })
            .height(48).fontSize(26)
            .placeholderColor($r('app.color.text_secondary'))
            .backgroundColor($r('app.color.background')).borderRadius(8)
            .onChange((val: string) => { this.newTodoContent = val; })

          Row({ space: 12 }) {
            ForEach(this.categories, (cat: string) => {
              Text(cat)
                .fontSize(22)
                .fontColor(this.newTodoCategory === cat ? $r('app.color.card_white') : '#1D2129')
                .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                .backgroundColor(this.newTodoCategory === cat ? $r('app.color.primary') : $r('app.color.background'))
                .borderRadius(12)
                .onClick(() => { this.newTodoCategory = cat; })
            }, (cat: string) => cat)
          }
          .width('100%')

          Button('添加')
            .width('100%').height(44)
            .fontSize(24).fontColor($r('app.color.card_white'))
            .backgroundColor($r('app.color.primary')).borderRadius(8)
            .onClick(() => { this.addTodo(); })
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.card_white'))
      }

      // 待办列表
      Scroll() {
        Column({ space: 8 }) {
          if (this.getFilteredTodos().length === 0) {
            Column({ space: 16 }) {
              SymbolGlyph($r('sys.symbol.checkmark_circle'))
                .fontSize(48)
              Text('暂无待办事项')
                .fontSize(26).fontColor($r('app.color.text_secondary'))
            }
            .width('100%').height(200)
            .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          } else {
            ForEach(this.getFilteredTodos(), (item: TodoItem) => {
              Column({ space: 8 }) {
                Row() {
                  if (this.batchMode) {
                    // 批量选择模式
                    SymbolGlyph(this.selectedIds.indexOf(item.id) >= 0 ? $r('sys.symbol.checkmark_square') : $r('sys.symbol.square'))
                      .fontSize(24)
                      .onClick(() => { this.toggleSelect(item.id); })
                      .margin({ right: 8 })
                  }

                  // 完成状态
                  SymbolGlyph(item.isCompleted ? $r('sys.symbol.checkmark_circle') : $r('sys.symbol.circle'))
                    .fontSize(24)
                    .onClick(() => { this.toggleComplete(item.id); })
                    .margin({ right: 8 })

                  Column({ space: 4 }) {
                    Text(item.content)
                      .fontSize(26)
                      .fontColor(item.isCompleted ? $r('app.color.text_secondary') : '#1D2129')
                      .decoration({ type: item.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
                      .layoutWeight(1)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })

                    Row({ space: 8 }) {
                      Text(item.category)
                        .fontSize(20)
                        .fontColor($r('app.color.card_white'))
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .backgroundColor(this.getCategoryColor(item.category))
                        .borderRadius(4)

                      if (item.remindTime !== '') {
                        Text('⏰' + item.remindTime)
                          .fontSize(20).fontColor($r('app.color.text_secondary'))
                      }

                      Text(item.createTime)
                        .fontSize(20).fontColor($r('app.color.text_secondary'))
                    }
                    .width('100%')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  if (!this.batchMode) {
                    SymbolGlyph($r('sys.symbol.trash'))
                      .fontSize(22)
                      .onClick(() => { this.deleteTodo(item.id); })
                  }
                }
                .width('100%').padding(12)
                .backgroundColor($r('app.color.card_white'))
                .borderRadius(8)
                .shadow({ radius: 4, color: $r('app.color.shadow'), offsetX: 0, offsetY: 1 })
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
          .fontSize(26).fontColor($r('app.color.card_white'))
          .backgroundColor($r('app.color.primary')).borderRadius(8)
          .margin({ bottom: 16 })
          .onClick(() => {
            this.showAddInput = true;
          })
      }
    }
    .width('100%').height('100%')
    .backgroundColor($r('app.color.background'))
  }
}
