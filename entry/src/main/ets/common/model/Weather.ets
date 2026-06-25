/**
 * Weather.ets - 天气模型
 */
export interface WeatherItem {
  date: string;
  weekDay: string;
  weather: string;          // 晴/多云/阴/雨
  tempHigh: number;
  tempLow: number;
  icon: string;             // 天气图标路径（预留）
}
