
/**
 * DataInitializer.ets - 首次启动数据初始化
 *
 * 检查 RDB 表是否为空，若为空则从 rawfile JSON 导入初始数据。
 * 在 Index 的 aboutToAppear 中调用。
 */
import { relationalStore } from '@kit.ArkData';
import { JsonStoreUtil } from '../utils/JsonStoreUtil';
import { AppDbHelper } from './AppDbHelper';
import { CourseDao, CourseRow } from './CourseDao';

type JsonRecord = Record<string, string | number | boolean | string[]>;

export class DataInitializer {
  static async seedIfEmpty(context: Context): Promise<void> {
    try {
      const empty: boolean = await AppDbHelper.isTableEmpty(context, 'course');
      if (!empty) {
        console.info('[DataInitializer] RDB 已有数据，跳过初始化');
        return;
      }
      console.info('[DataInitializer] 开始导入初始数据到 RDB...');
      await DataInitializer.importCourses(context);
      await DataInitializer.importScores(context);
      await DataInitializer.importBooks(context);
      await DataInitializer.importFood(context);
      await DataInitializer.importWeather(context);
      console.info('[DataInitializer] 初始数据导入完成');
    } catch (err) {
      console.error('[DataInitializer] 初始化失败: ' + JSON.stringify(err));
    }
  }

  private static async importCourses(context: Context): Promise<void> {
    const data: CourseRow[] | null = await JsonStoreUtil.readFromRaw<CourseRow[]>('schedule.json');
    if (data) {
      for (let i = 0; i < data.length; i++) {
        await CourseDao.insert(context, data[i]);
      }
    }
  }

  private static async importScores(context: Context): Promise<void> {
    const data: JsonRecord[] | null =
      await JsonStoreUtil.readFromRaw<JsonRecord[]>('score.json');
    if (data) {
      const store = await AppDbHelper.getStore(context);
      for (let i = 0; i < data.length; i++) {
        const item: JsonRecord = data[i];
        const bucket: relationalStore.ValuesBucket = {
          id: item['id'] as string,
          course_name: item['courseName'] as string,
          score: item['score'] as number,
          gpa: item['gpa'] as number,
          credit: item['credit'] as string,
          exam_time: item['examTime'] as string,
          semester: item['semester'] as string
        };
        await store.insert('score', bucket);
      }
    }
  }

  private static async importBooks(context: Context): Promise<void> {
    const data: JsonRecord[] | null =
      await JsonStoreUtil.readFromRaw<JsonRecord[]>('books.json');
    if (data) {
      const store = await AppDbHelper.getStore(context);
      for (let i = 0; i < data.length; i++) {
        const item: JsonRecord = data[i];
        const bucket: relationalStore.ValuesBucket = {
          id: item['id'] as string,
          title: item['title'] as string,
          author: item['author'] as string,
          publisher: item['publisher'] as string,
          isbn: item['isbn'] as string,
          cover: item['cover'] as string,
          location: item['location'] as string,
          total_count: item['totalCount'] as number,
          available_count: item['availableCount'] as number,
          summary: item['summary'] as string,
          is_favorited: (item['isFavorited'] as boolean) ? 1 : 0
        };
        await store.insert('book', bucket);
      }
    }
  }

  private static async importFood(context: Context): Promise<void> {
    const data: JsonRecord[] | null =
      await JsonStoreUtil.readFromRaw<JsonRecord[]>('food.json');
    if (data) {
      const store = await AppDbHelper.getStore(context);
      for (let i = 0; i < data.length; i++) {
        const item: JsonRecord = data[i];
        const bucket: relationalStore.ValuesBucket = {
          id: item['id'] as string,
          name: item['name'] as string,
          canteen: item['canteen'] as string,
          image_path: item['imagePath'] as string,
          rating: item['rating'] as number,
          signature_dish: item['signatureDish'] as string,
          tags: (item['tags'] as string[]).join(','),
          is_favorited: (item['isFavorited'] as boolean) ? 1 : 0
        };
        await store.insert('food', bucket);
      }
    }
  }

  private static async importWeather(context: Context): Promise<void> {
    const data: JsonRecord[] | null =
      await JsonStoreUtil.readFromRaw<JsonRecord[]>('weather.json');
    if (data) {
      const store = await AppDbHelper.getStore(context);
      for (let i = 0; i < data.length; i++) {
        const item: JsonRecord = data[i];
        const bucket: relationalStore.ValuesBucket = {
          id: item['id'] as string,
          date_text: item['dateText'] as string,
          week_day: item['weekDay'] as string,
          weather: item['weather'] as string,
          temp_high: item['tempHigh'] as number,
          temp_low: item['tempLow'] as number,
          icon: item['icon'] as string
        };
        await store.insert('weather', bucket);
      }
    }
  }
}
