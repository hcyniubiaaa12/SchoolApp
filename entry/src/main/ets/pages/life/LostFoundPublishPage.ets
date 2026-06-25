/**
 * LostFoundPublishPage.ets - 失物/拾物发布/编辑页
 * DatePicker/TimePicker 选时间 + 自动关联当前用户 + 编辑模式
 */
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import { LostFoundDao, LostFoundRow } from '../../common/database/LostFoundDao';

interface TypeOption {
  label: string;
  value: string;
}

interface CategoryOption {
  label: string;
}

@Entry
@Component
struct LostFoundPublishPage {
  @State publishType: string = 'lost';
  @State category: string = '';
  @State itemName: string = '';
  @State location: string = '';
  @State time: string = '';
  @State description: string = '';
  @State contactPhone: string = '';
  @State isSubmitting: boolean = false;
  @State errorMessage: string = '';
  @State selectedDate: Date = new Date();
  @State selectedTime: Date = new Date();

  // 编辑模式
  private editId: string = '';
  private isEditMode: boolean = false;

  private typeOptions: TypeOption[] = [
    { label: '寻物启事', value: 'lost' },
    { label: '失物招领', value: 'found' }
  ];

  private categoryOptions: CategoryOption[] = [
    { label: '校园卡' }, { label: '电子产品' }, { label: '书籍' },
    { label: '证件' }, { label: '钥匙' }, { label: '衣物' }, { label: '其他' }
  ];

  aboutToAppear(): void {
    // 检查是否编辑模式（router.getParams() 可能返回 null/undefined）
    const params: Object = router.getParams();
    let editId: string = '';
    if (params) {
      editId = (params as Record<string, string>)['editId'] ?? '';
    }
    if (editId !== '') {
      this.editId = editId;
      this.isEditMode = true;
      this.loadItem(this.editId);
    }
    // 初始化时间
    const now: Date = new Date();
    this.selectedDate = now;
    this.selectedTime = now;
    this.updateTimeDisplay();
  }

  /** 加载已有记录（编辑模式） */
  private async loadItem(id: string): Promise<void> {
    try {
      const ctx: Context = getContext(this);
      const item: LostFoundRow | null = await LostFoundDao.queryById(ctx, id);
      if (item) {
        this.publishType = item.type;
        this.category = item.category;
        this.itemName = item.itemName;
        this.location = item.location;
        this.time = item.time;
        this.description = item.description;
        this.contactPhone = item.contactPhone;
        // 解析时间
        const parsed: Date = new Date(item.time);
        if (!isNaN(parsed.getTime())) {
          this.selectedDate = parsed;
          this.selectedTime = parsed;
        }
      }
    } catch (err) {
      console.error('[LostFoundPublish] 加载失败: ' + JSON.stringify(err));
    }
  }

  /** 将 selectedDate + selectedTime 合并写入 time 字符串 */
  private updateTimeDisplay(): void {
    const d: Date = this.selectedDate;
    const t: Date = this.selectedTime;
    this.time = d.getFullYear().toString() + '-' +
      (d.getMonth() + 1).toString().padStart(2, '0') + '-' +
      d.getDate().toString().padStart(2, '0') + ' ' +
      t.getHours().toString().padStart(2, '0') + ':' +
      t.getMinutes().toString().padStart(2, '0');
  }

  /** 弹出日期选择器 */
  private showDatePicker(): void {
    DatePickerDialog.show({
      start: new Date(2020, 0, 1),
      end: new Date(2030, 11, 31),
      selected: this.selectedDate,
      onAccept: (value: DatePickerResult): void => {
        this.selectedDate = new Date(value.year ?? 2026, value.month ?? 0, value.day ?? 1);
        this.updateTimeDisplay();
      }
    });
  }

  /** 弹出时间选择器 */
  private showTimePicker(): void {
    TimePickerDialog.show({
      selected: this.selectedTime,
      onAccept: (value: TimePickerResult): void => {
        this.selectedTime = new Date();
        this.selectedTime.setHours(value.hour ?? 0, value.minute ?? 0, 0, 0);
        this.updateTimeDisplay();
      }
    });
  }

  private get isFormValid(): boolean {
    return this.itemName.trim() !== '' &&
      this.location.trim() !== '' &&
      this.time.trim() !== '' &&
      this.category.trim() !== '';
  }

  private async submitPublish(): Promise<void> {
    this.errorMessage = '';
    const missing: string[] = [];
    if (this.itemName.trim() === '') missing.push('物品名称');
    if (this.location.trim() === '') missing.push('地点');
    if (this.time.trim() === '') missing.push('时间');
    if (this.category.trim() === '') missing.push('分类');
    console.info('[LostFoundPublish] 校验: itemName="' + this.itemName
      + '" location="' + this.location + '" time="' + this.time
      + '" category="' + this.category + '"');
    if (missing.length > 0) {
      const msg: string = '请填写完整信息（' + missing.join('、') + '）';
      this.errorMessage = msg;
      promptAction.showToast({ message: msg });
      return;
    }
    this.isSubmitting = true;
    try {
      const ctx: Context = getContext(this);
      const userId: string = AppStorage.get('userId') ?? '';
      const nowStr: string = new Date().toISOString().substring(0, 19).replace('T', ' ');
      const itemData: LostFoundRow = {
        id: '',
        type: this.publishType,
        category: this.category,
        itemName: this.itemName.trim(),
        location: this.location.trim(),
        time: this.time.trim(),
        description: this.description.trim(),
        contactPhone: this.contactPhone.trim(),
        imagePath: '',
        publisherId: userId,
        publishTime: nowStr,
        status: 'pending'
      };
      if (this.isEditMode && this.editId) {
        // 更新已有记录
        itemData.id = this.editId;
        await LostFoundDao.update(ctx, itemData);
        promptAction.showToast({ message: '修改成功' });
      } else {
        // 新增
        itemData.id = 'lf_' + Date.now().toString() + '_' + Math.random().toString(36).substring(2, 6);
        await LostFoundDao.insert(ctx, itemData);
        promptAction.showToast({ message: '发布成功' });
      }
      this.isSubmitting = false;
      router.back();
    } catch (err) {
      const errMsg: string = (err instanceof Error) ? err.message : String(err);
      console.error('[LostFoundPublish] 失败: ' + errMsg);
      promptAction.showToast({ message: (this.isEditMode ? '修改' : '发布') + '失败: ' + errMsg });
      this.isSubmitting = false;
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
        Text(this.isEditMode ? '编辑信息' : '发布信息')
          .fontSize(30).fontWeight(600).fontColor('#1D2129')
        Blank()
        Row().width(24)
      }
      .width('100%').height(56).padding({ left: 16, right: 20 })
      .backgroundColor('#FFFFFF').alignItems(VerticalAlign.Center)

      // 表单内容
      Scroll() {
        Column({ space: 20 }) {
          // —— 类型选择 ——
          Column({ space: 8 }) {
            Text('发布类型')
              .fontSize(26).fontWeight(600).fontColor('#1D2129')
            Row({ space: 16 }) {
              ForEach(this.typeOptions, (opt: TypeOption) => {
                Row({ space: 6 }) {
                  Radio({ value: opt.value, group: 'publishType' })
                    .checked(this.publishType === opt.value)
                    .onChange(() => { this.publishType = opt.value; })
                  Text(opt.label)
                    .fontSize(26).fontColor('#1D2129')
                }
                .alignItems(VerticalAlign.Center)
                .onClick(() => { this.publishType = opt.value; })
              }, (opt: TypeOption) => opt.value)
            }
          }
          .width('100%').padding(16)
          .backgroundColor('#FFFFFF').borderRadius(8)

          // —— 分类 ——
          Column({ space: 8 }) {
            Text('物品分类')
              .fontSize(26).fontWeight(600).fontColor('#1D2129')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.categoryOptions, (opt: CategoryOption) => {
                Text(opt.label)
                  .fontSize(24)
                  .fontColor(this.category === opt.label ? '#FFFFFF' : '#1D2129')
                  .padding({ left: 16, right: 16, top: 6, bottom: 6 })
                  .backgroundColor(this.category === opt.label ? '#1677FF' : '#F5F7FA')
                  .borderRadius(16)
                  .margin({ right: 8, bottom: 8 })
                  .onClick(() => { this.category = opt.label; })
              }, (opt: CategoryOption) => opt.label)
            }
          }
          .width('100%').padding(16)
          .backgroundColor('#FFFFFF').borderRadius(8)

          // —— 表单输入 ——
          Column({ space: 16 }) {
            // 物品名
            Column({ space: 6 }) {
              Text('物品名称 *')
                .fontSize(24).fontColor('#1D2129')
              TextInput({ placeholder: '请输入物品名称' })
                .height(48).fontSize(26)
                .placeholderColor('#86909C')
                .backgroundColor('#F5F7FA').borderRadius(8)
                .onChange((val: string) => { this.itemName = val; })
            }

            // 地点
            Column({ space: 6 }) {
              Text('丢失/拾取地点 *')
                .fontSize(24).fontColor('#1D2129')
              TextInput({ placeholder: '如：二食堂一楼、图书馆三楼' })
                .height(48).fontSize(26)
                .placeholderColor('#86909C')
                .backgroundColor('#F5F7FA').borderRadius(8)
                .onChange((val: string) => { this.location = val; })
            }

            // 时间（DatePicker + TimePicker 选择）
            Column({ space: 6 }) {
              Text('时间 *')
                .fontSize(24).fontColor('#1D2129')
              Row({ space: 12 }) {
                // 日期选择
                Column() {
                  Text(this.time.split(' ')[0] || this.time)
                    .fontSize(26).fontColor('#1677FF')
                    .padding({ top: 12, bottom: 12, left: 16, right: 16 })
                }
                .height(48)
                .backgroundColor('#F5F7FA').borderRadius(8)
                .layoutWeight(1)
                .onClick(() => { this.showDatePicker(); })

                // 时间选择
                Column() {
                  Text(this.time.split(' ')[1] || '')
                    .fontSize(26).fontColor('#1677FF')
                    .padding({ top: 12, bottom: 12, left: 16, right: 16 })
                }
                .height(48)
                .backgroundColor('#F5F7FA').borderRadius(8)
                .layoutWeight(1)
                .onClick(() => { this.showTimePicker(); })
              }
            }

            // 描述
            Column({ space: 6 }) {
              Text('详细描述')
                .fontSize(24).fontColor('#1D2129')
              TextArea({ placeholder: '请输入详细描述，如物品特征、颜色、品牌等' })
                .height(120).fontSize(26)
                .placeholderColor('#86909C')
                .backgroundColor('#F5F7FA').borderRadius(8)
                .onChange((val: string) => { this.description = val; })
            }

            // 联系电话
            Column({ space: 6 }) {
              Text('联系电话')
                .fontSize(24).fontColor('#1D2129')
              TextInput({ placeholder: '请输入联系电话' })
                .height(48).fontSize(26)
                .placeholderColor('#86909C')
                .backgroundColor('#F5F7FA').borderRadius(8)
                .onChange((val: string) => { this.contactPhone = val; })
            }
          }
          .width('100%').padding(16)
          .backgroundColor('#FFFFFF').borderRadius(8)

          // —— 提交按钮 ——
          Button(this.isSubmitting ? (this.isEditMode ? '修改中...' : '发布中...')
            : (this.isEditMode ? '保存修改' : '发布'))
            .width('100%').height(48)
            .fontSize(26).fontColor('#FFFFFF')
            .backgroundColor(this.isFormValid ? '#1677FF' : '#C6E2FF')
            .borderRadius(8)
            .enabled(!this.isSubmitting)
            .onClick(() => { this.submitPublish(); })

          // 错误提示（可视，不会消失）
          if (this.errorMessage !== '') {
            Text(this.errorMessage)
              .fontSize(22).fontColor('#FF7D00').width('100%')
              .textAlign(TextAlign.Center).margin({ top: 4 })
          }

          // 底部提示
          Text('请确认信息真实有效，虚假信息将被删除')
            .fontSize(22).fontColor('#86909C')
            .width('100%').textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 32 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%').height('100%')
    .backgroundColor('#F5F7FA')
  }
}
