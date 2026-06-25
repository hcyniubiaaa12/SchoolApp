/**
 * WeatherDao.ets - 天气数据访问
 *
 * 核心查询：未来 N 天
 */
import { relationalStore } from '@kit.ArkData';
import { AppDbHelper } from './AppDbHelper';

export interface WeatherRow {
  id: string;
  dateText: string;
  weekDay: string;
  weather: string;
  tempHigh: number;
  tempLow: number;
  icon: string;
}

function toRow(rs: relationalStore.ResultSet): WeatherRow {
  return {
    id: rs.getString(rs.getColumnIndex('id')),
    dateText: rs.getString(rs.getColumnIndex('date_text')),
    weekDay: rs.getString(rs.getColumnIndex('week_day')),
    weather: rs.getString(rs.getColumnIndex('weather')),
    tempHigh: rs.getLong(rs.getColumnIndex('temp_high')),
    tempLow: rs.getLong(rs.getColumnIndex('temp_low')),
    icon: rs.getString(rs.getColumnIndex('icon'))
  };
}

function readList(rs: relationalStore.ResultSet): WeatherRow[] {
  const list: WeatherRow[] = [];
  while (rs.goToNextRow()) {
    list.push(toRow(rs));
  }
  rs.close();
  return list;
}

export class WeatherDao {
  static async queryAll(context: Context): Promise<WeatherRow[]> {
    const store = await AppDbHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('weather');
    predicates.orderByAsc('date_text');
    const rs = await store.query(predicates);
    return readList(rs);
  }
}
