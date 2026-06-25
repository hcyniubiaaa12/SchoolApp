/**
 * MusicListPage.ets - 本地音乐列表页
 * 从 rawfile JSON 读取音乐列表，支持点击选歌播放
 */
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import { JsonStoreUtil } from '../../common/utils/JsonStoreUtil';

interface SongItem {
  id: string;
  title: string;
  artist: string;
  album: string;
  duration: number;
  filePath: string;
  coverPath: string;
}

@Entry
@Component
struct MusicListPage {
  @State songList: SongItem[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadSongs();
  }

  private loadSongs(): void {
    this.isLoading = true;
    JsonStoreUtil.read<SongItem[]>('music.json').then((data: SongItem[] | null) => {
      if (data) {
        this.songList = data;
      }
      this.isLoading = false;
    }).catch(() => {
      this.isLoading = false;
    });
  }

  private formatDuration(seconds: number): string {
    const min: number = Math.floor(seconds / 60);
    const sec: number = seconds % 60;
    return min.toString().padStart(2, '0') + ':' + sec.toString().padStart(2, '0');
  }

  private playSong(song: SongItem): void {
    promptAction.showToast({ message: '正在播放: ' + song.title });
    // 实际播放功能需要接入音频播放 API，预留扩展
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24).fillColor('#1D2129')
          .onClick(() => { router.back(); })
        Blank()
        Text('本地音乐')
          .fontSize(30).fontWeight(600).fontColor('#1D2129')
          .layoutWeight(1).textAlign(TextAlign.Center)
        Blank()
        Row().width(24)
      }
      .width('100%').height(56).padding({ left: 16, right: 20 })
      .backgroundColor('#FFFFFF').alignItems(VerticalAlign.Center)

      // 提示信息
      Row({ space: 8 }) {
        Text('📌')
          .fontSize(22)
        Text('当前为演示列表，实际音频文件需放入设备存储')
          .fontSize(22).fontColor('#86909C').layoutWeight(1)
      }
      .width('100%').padding({ left: 20, right: 20, top: 10, bottom: 10 })
      .backgroundColor('#FFF3E0')

      if (this.isLoading) {
        // 加载中
        Column() {
          Text('加载中...')
            .fontSize(26).fontColor('#86909C')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.songList.length === 0) {
        // 空状态
        Column({ space: 16 }) {
          Text('🎵')
            .fontSize(64)
          Text('暂无本地音乐')
            .fontSize(26).fontColor('#86909C')
          Text('请将音频文件放入设备存储后刷新')
            .fontSize(24).fontColor('#86909C')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        // 歌曲列表
        Scroll() {
          Column({ space: 8 }) {
            ForEach(this.songList, (song: SongItem, index: number) => {
              Row() {
                // 序号/封面占位
                Stack() {
                  Circle()
                    .width(48).height(48)
                    .fill('#E8F3FF')
                  Text('🎵')
                    .fontSize(24)
                }

                Column({ space: 4 }) {
                  Text(song.title)
                    .fontSize(26).fontWeight(600)
                    .fontColor('#1D2129')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  Row({ space: 8 }) {
                    Text(song.artist)
                      .fontSize(22).fontColor('#86909C')
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })

                    Text('·')
                      .fontSize(22).fontColor('#E5E6EB')

                    Text(song.album)
                      .fontSize(22).fontColor('#86909C')
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .layoutWeight(1)
                  }
                  .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })

                // 时长 + 播放按钮
                Row({ space: 8 }) {
                  Text(this.formatDuration(song.duration))
                    .fontSize(22).fontColor('#86909C')
                  Text('▶️')
                    .fontSize(24)
                    .onClick(() => { this.playSong(song); })
                }
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 1 })
              .alignItems(VerticalAlign.Center)
              .onClick(() => { this.playSong(song); })
            }, (song: SongItem) => song.id)
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 12, bottom: 24 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
    }
    .width('100%').height('100%')
    .backgroundColor('#F5F7FA')
  }
}
