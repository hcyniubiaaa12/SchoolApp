/**
 * MessageCenterPage.ets - 消息中心页
 * 点击首页铃铛图标进入，展示通知消息列表
 */
import { router } from '@kit.ArkUI';

interface MessageItem {
  id: string;
  title: string;
  content: string;
  time: string;
  type: string;
  isRead: boolean;
}

@Entry
@Component
struct MessageCenterPage {
  @State messages: MessageItem[] = [
    { id: 'm1', title: '课程提醒', content: '您有「高级人工智能」课程即将在10:00开始', time: '2026-06-25 09:30', type: '课程', isRead: false },
    { id: 'm2', title: '公告通知', content: '关于2026年暑期放假安排的通知已发布', time: '2026-06-20 09:00', type: '公告', isRead: false },
    { id: 'm3', title: '待办提醒', content: '您有待办事项「提交课程报告」即将到期', time: '2026-06-19 14:00', type: '待办', isRead: true },
    { id: 'm4', title: '系统通知', content: '校园一卡通系统将于7月1日至3日升级维护', time: '2026-06-16 08:30', type: '系统', isRead: true },
    { id: 'm5', title: '活动通知', content: '2026年校园歌手大赛海选即将开始', time: '2026-06-15 10:00', type: '活动', isRead: true },
  ];

  private markAllRead(): void {
    for (let i = 0; i < this.messages.length; i++) {
      this.messages[i].isRead = true;
    }
  }

  private getUnreadCount(): number {
    let count: number = 0;
    for (let i = 0; i < this.messages.length; i++) {
      if (!this.messages[i].isRead) {
        count++;
      }
    }
    return count;
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24).fillColor('#1D2129')
          .onClick(() => {
            router.back();
          })

        Blank()

        Text('消息中心')
          .fontSize(30)
          .fontWeight(600)
          .fontColor('#1D2129')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank()

        Text('全部已读')
          .fontSize(24)
          .fontColor('#1677FF')
          .onClick(() => {
            this.markAllRead();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 20 })
      .backgroundColor('#FFFFFF')
      .alignItems(VerticalAlign.Center)

      // 未读概况
      Row() {
        Text('未读消息 ' + this.getUnreadCount().toString() + ' 条')
          .fontSize(24)
          .fontColor('#FF7D00')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })
      .backgroundColor('#FFF3E0')

      // 消息列表
      Scroll() {
        Column({ space: 8 }) {
          ForEach(this.messages, (item: MessageItem) => {
            Row() {
              // 类型图标
              Stack() {
                Circle()
                  .width(44)
                  .height(44)
                  .fill(this.getMessageColor(item.type) + '1A')
                Text(this.getMessageIcon(item.type))
                  .fontSize(24)
              }

              Column({ space: 4 }) {
                Row() {
                  Text(item.title)
                    .fontSize(26)
                    .fontWeight(600)
                    .fontColor('#1D2129')
                    .layoutWeight(1)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  if (!item.isRead) {
                    Circle()
                      .width(8)
                      .height(8)
                      .fill('#FF7D00')
                  }
                }
                .width('100%')

                Text(item.content)
                  .fontSize(24)
                  .fontColor('#86909C')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')

                Text(item.time)
                  .fontSize(22)
                  .fontColor('#86909C')
                  .width('100%')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 12 })
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 1 })
            .alignItems(VerticalAlign.Center)
          }, (item: MessageItem) => item.id)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 12, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  private getMessageColor(type: string): string {
    if (type === '课程') return '#1677FF';
    if (type === '公告') return '#FF7D00';
    if (type === '待办') return '#00B42A';
    return '#86909C';
  }

  private getMessageIcon(type: string): string {
    if (type === '课程') return '📅';
    if (type === '公告') return '📢';
    if (type === '待办') return '📝';
    if (type === '活动') return '🎉';
    return '🔔';
  }
}
