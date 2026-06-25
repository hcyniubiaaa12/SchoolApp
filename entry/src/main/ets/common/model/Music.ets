/**
 * Music.ets - 音乐模型
 */
export interface SongItem {
  id: string;
  title: string;            // 歌名
  artist: string;           // 歌手
  album: string;            // 专辑
  duration: number;         // 时长（秒）
  filePath: string;         // 本地音频文件路径
  coverPath: string;        // 封面图片路径（预留）
}
