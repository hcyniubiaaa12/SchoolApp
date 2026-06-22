import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { media } from '@kit.MediaKit';
import { avSession } from '@kit.AVSessionKit';
import promptAction from '@ohos.promptAction';
import { TransientTaskUtil, DraftData } from '../common/utils/TransientTaskUtil';
import { ContinuousTaskUtil } from '../common/utils/ContinuousTaskUtil';
import { DeferredTaskUtil } from '../common/utils/DeferredTaskUtil';
import { ReminderUtil } from '../common/utils/ReminderUtil';
import { DatabaseHelper } from '../common/database/DatabaseHelper';
import { StudentDao } from '../common/database/StudentDao';

// 测试音频 URL（依次尝试，首个不通则换备用）
const AUDIO_URLS: string[] = [
  'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
  'https://filesamples.com/samples/audio/mp3/sample1.mp3'
];
const LAB_ENTRY_NAME: string = '后台服务实验';

@Entry
@Component
struct BackgroundTaskLab {
  @State currentTab: number = 0;

  // Tab1 短时任务状态
  @State draftContent: string = '';
  @State scrollPosition: string = '0';
  @State transientActive: boolean = false;
  @State transientRemaining: number = 0;
  @State savedDraftPreview: string = '（暂无）';

  // Tab2 长时任务状态
  @State musicPlaying: boolean = false;
  @State continuousActive: boolean = false;
  @State musicStatusText: string = '未播放';
  private avPlayer: media.AVPlayer | null = null;
  private avSession: avSession.AVSession | null = null;

  // Tab3 延迟任务状态
  @State deferredActive: boolean = false;
  @State studentCount: number = 0;

  // Tab4 代理提醒状态
  @State reminderSeconds: string = '30';
  @State reminderTitle: string = '上课提醒';
  @State validReminderCount: number = 0;
  @State lastReminderId: number = -1;

  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  async aboutToAppear() {
    // 预初始化数据库，供延迟任务扩展能力读取
    await DatabaseHelper.getRdbStore(this.context);
    // 加载已保存的草稿
    await this.loadDraft();
    // 初始化短时任务激活状态
    this.transientActive = TransientTaskUtil.isActive();
    // 查询有效提醒数量
    await this.refreshReminderCount();
    // 统计学生数据条数（延迟任务上报对象）
    await this.refreshStudentCount();
  }

  aboutToDisappear() {
    // 离开页面释放播放器
    this.releasePlayer();
  }

  onPageShow() {
    // 页面重新可见时（从后台回到前台），自动刷新短时任务剩余时间
    // 因为后台期间剩余时间被消耗，但前台时 UI 显示的是旧值，需同步刷新
    console.info('>>> [BackgroundTaskLab] onPageShow 触发，自动刷新剩余时间');
    this.refreshRemainingTime();
  }

  // 注意：不在 onPageHide 中释放播放器
  // 因为应用退至后台也会触发 onPageHide，释放后音乐无法继续播放（长时任务失效）
  // 仅在返回上一页或页面销毁时释放

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

  // ============ Tab1 短时任务 ============

  private async loadDraft(): Promise<void> {
    const draft: DraftData = await TransientTaskUtil.loadDraft(this.context);
    this.draftContent = draft.content;
    this.scrollPosition = draft.scrollPos.toString();
    if (draft.content.length > 0) {
      this.savedDraftPreview = draft.content;
    }
  }

  private async requestTransientTask(): Promise<void> {
    try {
      await TransientTaskUtil.requestDelay();
      // 申请成功后保存草稿
      await TransientTaskUtil.saveDraft(this.context, this.draftContent, Number(this.scrollPosition) || 0);
      this.transientActive = true;
      this.savedDraftPreview = this.draftContent || '（空草稿已保存）';
      await this.refreshRemainingTime();
      promptAction.showToast({ message: '短时任务已申请，草稿已保存' });
    } catch (err) {
      promptAction.showToast({ message: '申请失败: ' + (err as Error).message });
    }
  }

  private cancelTransientTask(): void {
    TransientTaskUtil.cancelDelay();
    this.transientActive = false;
    this.transientRemaining = 0;
    promptAction.showToast({ message: '短时任务已取消' });
  }

  private async refreshRemainingTime(): Promise<void> {
    const before: number = this.transientRemaining;
    this.transientRemaining = await TransientTaskUtil.getRemainingDelayTime();
    console.info('>>> [TransientTask] 剩余时间刷新: ' + before + 'ms → ' + this.transientRemaining + 'ms' +
      ' (变化: ' + (before - this.transientRemaining) + 'ms)');
  }

  private async resetTransientTask(): Promise<void> {
    // 取消旧任务（释放旧配额），重新申请（获得新配额），清除累计消耗
    TransientTaskUtil.cancelDelay();
    try {
      await TransientTaskUtil.requestDelay();
      await TransientTaskUtil.saveDraft(this.context, this.draftContent, Number(this.scrollPosition) || 0);
      this.transientActive = true;
      await this.refreshRemainingTime();
      promptAction.showToast({ message: '任务已重置，配额已刷新为 3 分钟' });
    } catch (err) {
      promptAction.showToast({ message: '重置失败: ' + (err as Error).message });
    }
  }

  // ============ Tab2 长时任务 ============

  private async startMusic(): Promise<void> {
    try {
      // 先申请长时任务
      await ContinuousTaskUtil.startBackgroundRunning(this.context);
      this.continuousActive = true;

      // 先释放旧播放器和旧 session
      this.releasePlayer();

      // 创建并激活 AVSession（后台音频必须，否则退后台系统静音）
      await this.activateAVSession();

      // 创建播放器
      const player: media.AVPlayer = await media.createAVPlayer();
      this.avPlayer = player;

      // 逐个尝试音频 URL，等待 initialized
      let urlSuccess: boolean = false;
      for (const url of AUDIO_URLS) {
        try {
          console.info('>>> [ContinuousTask] 尝试音频URL: ' + url);
          await new Promise<void>((resolve, reject) => {
            const onStateChange = (state: string, reason: media.StateChangeReason) => {
              console.info('>>> [ContinuousTask] AVPlayer state: ' + state + ', reason: ' + reason);
              if (state === 'initialized') {
                player.off('stateChange');
                resolve();
              } else if (state === 'error') {
                player.off('stateChange');
                reject(new Error('init error, reason: ' + reason));
              }
            };
            player.on('stateChange', onStateChange);
            player.url = url;
          });
          urlSuccess = true;
          console.info('>>> [ContinuousTask] URL 加载成功: ' + url);
          break;
        } catch (initErr) {
          console.warn('>>> [ContinuousTask] URL 失败: ' + url + ', 尝试下一个...');
        }
      }

      if (!urlSuccess) {
        console.error('>>> [ContinuousTask] 所有音频 URL 均无法访问');
        this.musicStatusText = '音频URL不通（长时任务已生效）';
        promptAction.showToast({ message: '所有音频URL不通，但长时任务已申请，退后台验证' });
        return;
      }

      // 注册永久状态监听
      player.on('stateChange', (state: string, reason: media.StateChangeReason) => {
        console.info('>>> [ContinuousTask] AVPlayer state: ' + state);
        if (state === 'playing') {
          this.musicPlaying = true;
          this.musicStatusText = '正在播放';
        } else if (state === 'paused') {
          this.musicPlaying = false;
          this.musicStatusText = '已暂停';
        } else if (state === 'completed') {
          this.musicPlaying = false;
          this.musicStatusText = '播放结束';
        } else if (state === 'error') {
          this.musicPlaying = false;
          this.musicStatusText = '播放出错（仍演示长时任务）';
          console.error('>>> [ContinuousTask] AVPlayer error reason: ' + reason);
        }
      });

      // prepare + play
      await player.prepare();
      await player.play();
      this.musicPlaying = true;
      this.musicStatusText = '正在播放';

      promptAction.showToast({ message: '长时任务已申请，开始播放' });
    } catch (err) {
      console.error('>>> [ContinuousTask] 启动失败: ' + (err as Error).message);
      this.musicStatusText = '播放失败（长时任务仍生效）';
      promptAction.showToast({ message: '播放失败但长时任务已申请' });
    }
  }

  private async pauseMusic(): Promise<void> {
    try {
      if (this.avPlayer !== null && this.musicPlaying) {
        await this.avPlayer.pause();
      }
      await ContinuousTaskUtil.stopBackgroundRunning(this.context);
      this.continuousActive = false;
      promptAction.showToast({ message: '已暂停并停止长时任务' });
    } catch (err) {
      promptAction.showToast({ message: '停止失败: ' + (err as Error).message });
    }
  }

  private async activateAVSession(): Promise<void> {
    try {
      // 已有 session 则复用
      if (this.avSession !== null) {
        return;
      }
      // 创建 AVSession（type: audio），激活后系统允许后台音频输出
      this.avSession = await avSession.createAVSession(this.context, 'audio', 'audio');
      await this.avSession.activate();
      console.info('>>> [ContinuousTask] AVSession 已激活，支持后台音频');
    } catch (err) {
      console.error('>>> [ContinuousTask] AVSession 激活失败: ' + (err as Error).message);
      // 不阻塞播放流程（退后台可能没声音但长时任务仍生效）
    }
  }

  private async deactivateAVSession(): Promise<void> {
    try {
      if (this.avSession !== null) {
        await this.avSession.deactivate();
        this.avSession = null;
        console.info('>>> [ContinuousTask] AVSession 已释放');
      }
    } catch (err) {
      console.error('>>> [ContinuousTask] AVSession 释放失败: ' + (err as Error).message);
    }
  }

  private releasePlayer(): void {
    if (this.avPlayer !== null) {
      this.avPlayer.release();
      this.avPlayer = null;
      this.musicPlaying = false;
    }
    // 释放 AVSession
    this.deactivateAVSession();
  }

  // ============ Tab3 延迟任务 ============

  private async refreshStudentCount(): Promise<void> {
    const students = await StudentDao.queryAll(this.context);
    this.studentCount = students.length;
  }

  private async registerDeferredTask(): Promise<void> {
    try {
      await DeferredTaskUtil.startWork(this.context);
      this.deferredActive = true;
      promptAction.showToast({ message: '延迟任务已注册，等待 WiFi+充电触发' });
    } catch (err) {
      promptAction.showToast({ message: '注册失败: ' + (err as Error).message });
    }
  }

  private async cancelDeferredTask(): Promise<void> {
    try {
      await DeferredTaskUtil.stopWork(this.context);
      this.deferredActive = false;
      promptAction.showToast({ message: '延迟任务已取消' });
    } catch (err) {
      promptAction.showToast({ message: '取消失败: ' + (err as Error).message });
    }
  }

  // ============ Tab4 代理提醒 ============

  private async refreshReminderCount(): Promise<void> {
    try {
      const reminders = await ReminderUtil.getValidReminders();
      this.validReminderCount = reminders.length;
    } catch (err) {
      console.error('>>> [Reminder] 刷新数量失败: ' + (err as Error).message);
    }
  }

  private async publishReminder(): Promise<void> {
    const seconds: number = Number(this.reminderSeconds);
    if (!Number.isFinite(seconds) || seconds <= 0) {
      promptAction.showToast({ message: '请输入有效秒数' });
      return;
    }
    try {
      const reminderId: number = await ReminderUtil.publishReminder(
        seconds, this.reminderTitle, `${this.reminderTitle}：${seconds}秒倒计时已到`);
      this.lastReminderId = reminderId;
      await this.refreshReminderCount();
      promptAction.showToast({ message: `提醒已发布，${seconds}秒后通知（可退出应用验证）` });
    } catch (err) {
      promptAction.showToast({ message: '发布失败: ' + (err as Error).message });
    }
  }

  private async cancelReminder(): Promise<void> {
    if (this.lastReminderId === -1) {
      promptAction.showToast({ message: '暂无可取消的提醒' });
      return;
    }
    try {
      await ReminderUtil.cancelReminder(this.lastReminderId);
      this.lastReminderId = -1;
      await this.refreshReminderCount();
      promptAction.showToast({ message: '提醒已取消' });
    } catch (err) {
      promptAction.showToast({ message: '取消失败: ' + (err as Error).message });
    }
  }

  // ============ 构建 UI ============

  build() {
    Column() {
      this.buildHeader();

      Column({ space: 12 }) {
        this.buildTabBar();

        if (this.currentTab === 0) {
          this.buildTransientSection();
        } else if (this.currentTab === 1) {
          this.buildContinuousSection();
        } else if (this.currentTab === 2) {
          this.buildDeferredSection();
        } else {
          this.buildReminderSection();
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
          // 返回前释放播放器并停止长时任务，避免资源泄漏
          this.releasePlayer();
          if (this.continuousActive) {
            ContinuousTaskUtil.stopBackgroundRunning(this.context);
          }
          router.back();
        })

      Blank()

      Text(LAB_ENTRY_NAME)
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
  private buildTabBar() {
    Row({ space: 8 }) {
      this.buildTabButton('短时任务', 0);
      this.buildTabButton('长时任务', 1);
      this.buildTabButton('延迟任务', 2);
      this.buildTabButton('代理提醒', 3);
    }
    .width('100%')
  }

  @Builder
  private buildTabButton(title: string, index: number) {
    Button(title)
      .layoutWeight(1)
      .height(40)
      .fontSize(13)
      .fontColor(this.currentTab === index ? '#FFFFFF' : '#007DFF')
      .backgroundColor(this.currentTab === index ? '#007DFF' : this.getCardBackgroundColor())
      .borderRadius(20)
      .onClick(() => {
        this.currentTab = index;
      })
  }

  // Tab1 短时任务
  @Builder
  private buildTransientSection() {
    Scroll() {
      Column({ space: 16 }) {
        // 说明卡
        this.buildInfoCard('短时任务（Transient Task）',
          '应用退至后台时申请，用于保存草稿等紧急短时操作。单次最长3分钟，单日配额10分钟。退后台时 MainAbility.onBackground 会自动触发。');

        // 草稿输入
        Column({ space: 12 }) {
          Text('草稿内容（模拟学习笔记）')
            .fontSize(16)
            .fontWeight(600)
            .fontColor(this.getPrimaryTextColor())

          TextArea({ placeholder: '输入草稿内容，退后台后将自动保存...', text: this.draftContent })
            .fontSize(16)
            .height(100)
            .onChange((value: string) => {
              this.draftContent = value;
              AppStorage.setOrCreate<string>('lab_draft_content', value);
            })

          Row({ space: 12 }) {
            Text('滚动位置：').fontSize(14).fontColor(this.getSecondaryTextColor())
            TextInput({ text: this.scrollPosition })
              .layoutWeight(1)
              .fontSize(14)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.scrollPosition = value;
                AppStorage.setOrCreate<number>('lab_scroll_position', Number(value) || 0);
              })
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.getCardBackgroundColor())
        .borderRadius(12)
        .alignItems(HorizontalAlign.Start)

        // 状态展示
        Column({ space: 8 }) {
          Text('任务状态')
            .fontSize(16)
            .fontWeight(600)
            .fontColor(this.getPrimaryTextColor())
          Text(`激活状态：${this.transientActive ? '已申请' : '未申请'}`)
            .fontSize(14)
            .fontColor(this.getSecondaryTextColor())
          Text(`单次配额：${TransientTaskUtil.getActualDelayTime()} ms（≈${(TransientTaskUtil.getActualDelayTime() / 60000).toFixed(1)}分钟）`)
            .fontSize(14)
            .fontColor(this.getSecondaryTextColor())
          Text(`累计消耗：${TransientTaskUtil.getTotalConsumed()} ms（≈${(TransientTaskUtil.getTotalConsumed() / 60000).toFixed(1)}分钟）`)
            .fontSize(14)
            .fontColor('#FF7D00')
          Text(`估算剩余：${this.transientRemaining} ms（≈${(this.transientRemaining / 60000).toFixed(1)}分钟）`)
            .fontSize(14)
            .fontColor(this.transientRemaining > 0 ? '#52C41A' : '#F53F3F')
          Text(`已保存草稿：${this.savedDraftPreview}`)
            .fontSize(14)
            .fontColor(this.getSecondaryTextColor())
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text('提示：退后台→回前台时自动刷新剩余。点"重置任务"可清空累计消耗重新申请新配额')
            .fontSize(12)
            .fontColor('#999999')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.getCardBackgroundColor())
        .borderRadius(12)
        .alignItems(HorizontalAlign.Start)

        // 操作按钮
        Row({ space: 12 }) {
          Button('申请并保存')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor('#007DFF')
            .borderRadius(10)
            .onClick(() => {
              this.requestTransientTask();
            })

          Button('取消任务')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontColor('#007DFF')
            .backgroundColor('#EAF3FF')
            .borderRadius(10)
            .onClick(() => {
              this.cancelTransientTask();
            })
        }
        .width('100%')

        Button('重置任务（取消旧配额 + 申请新配额）')
          .width('100%')
          .height(40)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#FF7D00')
          .borderRadius(10)
          .onClick(() => {
            this.resetTransientTask();
          })

        Button('重新读取草稿')
          .width('100%')
          .height(40)
          .fontSize(14)
          .fontColor('#007DFF')
          .backgroundColor('#EAF3FF')
          .borderRadius(10)
          .onClick(() => {
            this.loadDraft();
            promptAction.showToast({ message: '草稿已重新读取' });
          })
      }
      .width('100%')
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  // Tab2 长时任务
  @Builder
  private buildContinuousSection() {
    Scroll() {
      Column({ space: 16 }) {
        this.buildInfoCard('长时任务（Continuous Task）',
          '后台长时间运行且用户可感知的任务，使用 AUDIO_PLAYBACK 类型。申请后通知栏显示歌曲信息，退后台音乐继续播放。');

        // 播放卡片
        Column({ space: 12 }) {
          Row({ space: 12 }) {
            Stack() {
              Circle().width(56).height(56).fill('#007DFF1A')
              Text('🎵').fontSize(28)
            }
            Column({ space: 4 }) {
              Text('校园电台 - 轻音乐合集')
                .fontSize(16)
                .fontWeight(600)
                .fontColor(this.getPrimaryTextColor())
              Text('状态：' + this.musicStatusText)
                .fontSize(13)
                .fontColor(this.getSecondaryTextColor())
              Text(`长时任务：${this.continuousActive ? '运行中' : '未申请'}`)
                .fontSize(13)
                .fontColor(this.continuousActive ? '#52C41A' : this.getSecondaryTextColor())
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)

          Row({ space: 12 }) {
            Button(this.musicPlaying ? '暂停' : '播放')
              .layoutWeight(1)
              .height(44)
              .fontSize(15)
              .fontColor('#FFFFFF')
              .backgroundColor(this.musicPlaying ? '#FF7D00' : '#007DFF')
              .borderRadius(10)
              .onClick(() => {
                if (this.musicPlaying) {
                  this.pauseMusic();
                } else {
                  this.startMusic();
                }
              })

            Button('停止长时任务')
              .layoutWeight(1)
              .height(44)
              .fontSize(15)
              .fontColor('#007DFF')
              .backgroundColor('#EAF3FF')
              .borderRadius(10)
              .onClick(() => {
                this.pauseMusic();
              })
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.getCardBackgroundColor())
        .borderRadius(12)

        // 操作提示
        Column({ space: 6 }) {
          Text('验证方式')
            .fontSize(14)
            .fontWeight(600)
            .fontColor(this.getPrimaryTextColor())
          Text('1. 点击播放，申请长时任务并开始播放')
            .fontSize(13)
            .fontColor(this.getSecondaryTextColor())
          Text('2. 按Home键退至后台，音乐继续播放')
            .fontSize(13)
            .fontColor(this.getSecondaryTextColor())
          Text('3. 通知栏显示歌曲信息，点击可拉起应用')
            .fontSize(13)
            .fontColor(this.getSecondaryTextColor())
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
    .scrollBar(BarState.Auto)
  }

  // Tab3 延迟任务
  @Builder
  private buildDeferredSection() {
    Scroll() {
      Column({ space: 16 }) {
        this.buildInfoCard('延迟任务（Deferred Task）',
          '实时性要求不高的延迟任务，由系统在满足条件时调度。触发条件：连接 Wi-Fi 且处于充电状态。执行时读取学生表模拟日志上报。');

        // 任务状态
        Column({ space: 8 }) {
          Text('任务状态')
            .fontSize(16)
            .fontWeight(600)
            .fontColor(this.getPrimaryTextColor())
          Text(`注册状态：${this.deferredActive ? '已注册' : '未注册'}`)
            .fontSize(14)
            .fontColor(this.getSecondaryTextColor())
          Text(`待上报学生数据：${this.studentCount} 条`)
            .fontSize(14)
            .fontColor(this.getSecondaryTextColor())
          Text('触发条件：Wi-Fi 网络 + 充电中')
            .fontSize(14)
            .fontColor(this.getSecondaryTextColor())
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.getCardBackgroundColor())
        .borderRadius(12)
        .alignItems(HorizontalAlign.Start)

        // 操作按钮
        Row({ space: 12 }) {
          Button('注册延迟任务')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor('#007DFF')
            .borderRadius(10)
            .onClick(() => {
              this.registerDeferredTask();
            })

          Button('取消延迟任务')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontColor('#007DFF')
            .backgroundColor('#EAF3FF')
            .borderRadius(10)
            .onClick(() => {
              this.cancelDeferredTask();
            })
        }
        .width('100%')

        Button('刷新学生数据条数')
          .width('100%')
          .height(40)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#52C41A')
          .borderRadius(10)
          .onClick(() => {
            this.refreshStudentCount();
          })

        // 验证提示
        Column({ space: 6 }) {
          Text('验证方式')
            .fontSize(14)
            .fontWeight(600)
            .fontColor(this.getPrimaryTextColor())
          Text('1. 点击注册延迟任务')
            .fontSize(13)
            .fontColor(this.getSecondaryTextColor())
          Text('2. 连接 Wi-Fi 并接入充电器')
            .fontSize(13)
            .fontColor(this.getSecondaryTextColor())
          Text('3. 在 hilog 中查看 DataSync onWorkStart 日志')
            .fontSize(13)
            .fontColor(this.getSecondaryTextColor())
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
    .scrollBar(BarState.Auto)
  }

  // Tab4 代理提醒
  @Builder
  private buildReminderSection() {
    Scroll() {
      Column({ space: 16 }) {
        this.buildInfoCard('代理提醒（Agent-powered Reminder）',
          '应用退出或进程终止后，系统代理提醒。使用倒计时类型，需 PUBLISH_AGENT_REMINDER 权限。发布后即使退出应用，到点仍弹通知。');

        // 设置卡片
        Column({ space: 12 }) {
          Text('倒计时设置')
            .fontSize(16)
            .fontWeight(600)
            .fontColor(this.getPrimaryTextColor())

          Row({ space: 12 }) {
            Text('提醒标题：').fontSize(14).fontColor(this.getSecondaryTextColor())
            TextInput({ text: this.reminderTitle })
              .layoutWeight(1)
              .fontSize(14)
              .onChange((value: string) => {
                this.reminderTitle = value;
              })
          }
          .width('100%')

          Row({ space: 12 }) {
            Text('倒计时(秒)：').fontSize(14).fontColor(this.getSecondaryTextColor())
            TextInput({ text: this.reminderSeconds })
              .layoutWeight(1)
              .fontSize(14)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.reminderSeconds = value;
              })
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.getCardBackgroundColor())
        .borderRadius(12)
        .alignItems(HorizontalAlign.Start)

        // 状态展示
        Column({ space: 8 }) {
          Text('提醒状态')
            .fontSize(16)
            .fontWeight(600)
            .fontColor(this.getPrimaryTextColor())
          Text(`有效提醒数量：${this.validReminderCount}`)
            .fontSize(14)
            .fontColor(this.getSecondaryTextColor())
          Text(`最近发布ID：${this.lastReminderId === -1 ? '无' : this.lastReminderId}`)
            .fontSize(14)
            .fontColor(this.getSecondaryTextColor())
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.getCardBackgroundColor())
        .borderRadius(12)
        .alignItems(HorizontalAlign.Start)

        // 操作按钮
        Row({ space: 12 }) {
          Button('发布提醒')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor('#007DFF')
            .borderRadius(10)
            .onClick(() => {
              this.publishReminder();
            })

          Button('取消最近提醒')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontColor('#007DFF')
            .backgroundColor('#EAF3FF')
            .borderRadius(10)
            .onClick(() => {
              this.cancelReminder();
            })
        }
        .width('100%')

        Button('刷新有效提醒数量')
          .width('100%')
          .height(40)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#52C41A')
          .borderRadius(10)
          .onClick(() => {
            this.refreshReminderCount();
          })

        // 验证提示
        Column({ space: 6 }) {
          Text('验证方式')
            .fontSize(14)
            .fontWeight(600)
            .fontColor(this.getPrimaryTextColor())
          Text('1. 输入秒数（如30），点击发布提醒')
            .fontSize(13)
            .fontColor(this.getSecondaryTextColor())
          Text('2. 退出应用或杀进程')
            .fontSize(13)
            .fontColor(this.getSecondaryTextColor())
          Text('3. 倒计时结束后系统弹出通知')
            .fontSize(13)
            .fontColor(this.getSecondaryTextColor())
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
    .scrollBar(BarState.Auto)
  }

  // 通用信息卡片
  @Builder
  private buildInfoCard(title: string, desc: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(16)
        .fontWeight(700)
        .fontColor('#007DFF')
      Text(desc)
        .fontSize(13)
        .fontColor(this.getSecondaryTextColor())
        .lineHeight(20)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.getCardBackgroundColor())
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }
}
