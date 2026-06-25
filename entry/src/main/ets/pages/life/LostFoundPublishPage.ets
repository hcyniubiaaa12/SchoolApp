/**
 * LostFoundPublishPage.ets - 失物/拾物发布页
 * 完整的发布表单：选择类型、填写物品信息、上传图片、提交到 RDB
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

  private typeOptions: TypeOption[] = [
    { label: '寻物启事', value: 'lost' },
    { label: '失物招领', value: 'found' }
  ];

  private categoryOptions: CategoryOption[] = [
    { label: '校园卡' }, { label: '电子产品' }, { label: '书籍' },
    { label: '证件' }, { label: '钥匙' }, { label: '衣物' }, { label: '其他' }
  ];

  aboutToAppear(): void {
    // 默认时间为当前日期
    const now: Date = new Date();
    this.time = now.getFullYear().toString() + '-' +
      (now.getMonth() + 1).toString().padStart(2, '0') + '-' +
      now.getDate().toString().padStart(2, '0') + ' ' +
      now.getHours().toString().padStart(2, '0') + ':' +
      now.getMinutes().toString().padStart(2, '0');
  }

  private get isFormValid(): boolean {
    return this.itemName.trim() !== '' &&
      this.location.trim() !== '' &&
      this.time.trim() !== '' &&
      this.category.trim() !== '';
  }

  private submitPublish(): void {
    if (!this.isFormValid) {
      promptAction.showToast({ message: '请填写完整信息（物品名、地点、时间、分类）' });
      return;
    }
    this.isSubmitting = true;
    try {
      const ctx: Context = getContext(this);
      const nowStr: string = new Date().toISOString().substring(0, 19).replace('T', ' ');
      const newItem: LostFoundRow = {
        id: 'lf_' + Date.now().toString(),
        type: this.publishType,
        category: this.category,
        itemName: this.itemName.trim(),
        location: this.location.trim(),
        time: this.time.trim(),
        description: this.description.trim(),
        contactPhone: this.contactPhone.trim(),
        imagePath: '',
        publisherId: '',
        publishTime: nowStr,
        status: 'pending'
      };
      LostFoundDao.insert(ctx, newItem).then(() => {
        promptAction.showToast({ message: '发布成功' });
        router.back();
      }).catch((err: Error) => {
        promptAction.showToast({ message: '发布失败，请重试' });
        console.error('[LostFoundPublish] 保存失败: ' + JSON.stringify(err));
        this.isSubmitting = false;
      });
    } catch (err) {
      promptAction.showToast({ message: '发布异常' });
      console.error('[LostFoundPublish] 异常: ' + JSON.stringify(err));
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
        Text('发布信息')
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
              TextInput({ placeholder: '请输入物品名称', text: this.itemName })
                .height(48).fontSize(26)
                .placeholderColor('#86909C')
                .backgroundColor('#F5F7FA').borderRadius(8)
                .onChange((val: string) => { this.itemName = val; })
            }

            // 地点
            Column({ space: 6 }) {
              Text('丢失/拾取地点 *')
                .fontSize(24).fontColor('#1D2129')
              TextInput({ placeholder: '如：二食堂一楼、图书馆三楼', text: this.location })
                .height(48).fontSize(26)
                .placeholderColor('#86909C')
                .backgroundColor('#F5F7FA').borderRadius(8)
                .onChange((val: string) => { this.location = val; })
            }

            // 时间
            Column({ space: 6 }) {
              Text('时间 *')
                .fontSize(24).fontColor('#1D2129')
              TextInput({ placeholder: '请输入时间，如：2026-06-25 14:30', text: this.time })
                .height(48).fontSize(26)
                .placeholderColor('#86909C')
                .backgroundColor('#F5F7FA').borderRadius(8)
                .onChange((val: string) => { this.time = val; })
            }

            // 描述
            Column({ space: 6 }) {
              Text('详细描述')
                .fontSize(24).fontColor('#1D2129')
              TextArea({ placeholder: '请输入详细描述，如物品特征、颜色、品牌等', text: this.description })
                .height(120).fontSize(26)
                .placeholderColor('#86909C')
                .backgroundColor('#F5F7FA').borderRadius(8)
                .onChange((val: string) => { this.description = val; })
            }

            // 联系电话
            Column({ space: 6 }) {
              Text('联系电话')
                .fontSize(24).fontColor('#1D2129')
              TextInput({ placeholder: '请输入联系电话', text: this.contactPhone })
                .height(48).fontSize(26)
                .placeholderColor('#86909C')
                .backgroundColor('#F5F7FA').borderRadius(8)
                .onChange((val: string) => { this.contactPhone = val; })
            }
          }
          .width('100%').padding(16)
          .backgroundColor('#FFFFFF').borderRadius(8)

          // —— 提交按钮 ——
          Button(this.isSubmitting ? '发布中...' : '发布')
            .width('100%').height(48)
            .fontSize(26).fontColor('#FFFFFF')
            .backgroundColor(this.isFormValid ? '#1677FF' : '#C6E2FF')
            .borderRadius(8)
            .enabled(!this.isSubmitting)
            .onClick(() => { this.submitPublish(); })

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
