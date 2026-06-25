/**
 * CourseDao.ets - 课程表数据访问
 *
 * 核心查询：按天查、按周次范围查、增删改
 */
import { relationalStore } from '@kit.ArkData';
import { AppDbHelper } from './AppDbHelper';

export interface CourseRow {
  id: string;
  name: string;
  teacher: string;
  location: string;
  dayIndex: number;
  startTime: string;
  endTime: string;
  startWeek: number;
  endWeek: number;
  courseType: string;
  color: string;
  credit: string;
  remark: string;
}

function toCourseRow(rs: relationalStore.ResultSet): CourseRow {
  return {
    id: rs.getString(rs.getColumnIndex('id')),
    name: rs.getString(rs.getColumnIndex('name')),
    teacher: rs.getString(rs.getColumnIndex('teacher')),
    location: rs.getString(rs.getColumnIndex('location')),
    dayIndex: rs.getLong(rs.getColumnIndex('day_index')),
    startTime: rs.getString(rs.getColumnIndex('start_time')),
    endTime: rs.getString(rs.getColumnIndex('end_time')),
    startWeek: rs.getLong(rs.getColumnIndex('start_week')),
    endWeek: rs.getLong(rs.getColumnIndex('end_week')),
    courseType: rs.getString(rs.getColumnIndex('course_type')),
    color: rs.getString(rs.getColumnIndex('color')),
    credit: rs.getString(rs.getColumnIndex('credit')),
    remark: rs.getString(rs.getColumnIndex('remark'))
  };
}

function readCourses(rs: relationalStore.ResultSet): CourseRow[] {
  const list: CourseRow[] = [];
  while (rs.goToNextRow()) {
    list.push(toCourseRow(rs));
  }
  rs.close();
  return list;
}

function toBucket(data: CourseRow): relationalStore.ValuesBucket {
  return {
    id: data.id,
    name: data.name,
    teacher: data.teacher,
    location: data.location,
    day_index: data.dayIndex,
    start_time: data.startTime,
    end_time: data.endTime,
    start_week: data.startWeek,
    end_week: data.endWeek,
    course_type: data.courseType,
    color: data.color,
    credit: data.credit,
    remark: data.remark
  };
}

export class CourseDao {
  static async insert(context: Context, data: CourseRow): Promise<void> {
    const store = await AppDbHelper.getStore(context);
    await store.insert('course', toBucket(data));
  }

  static async update(context: Context, data: CourseRow): Promise<void> {
    const store = await AppDbHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('course');
    predicates.equalTo('id', data.id);
    await store.update(toBucket(data), predicates);
  }

  static async deleteById(context: Context, id: string): Promise<void> {
    const store = await AppDbHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('course');
    predicates.equalTo('id', id);
    await store.delete(predicates);
  }

  static async queryAll(context: Context): Promise<CourseRow[]> {
    const store = await AppDbHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('course');
    predicates.orderByAsc('day_index');
    const rs = await store.query(predicates);
    return readCourses(rs);
  }

  /** 按周次范围查：查出在该周次内有效的课程 */
  static async queryByWeek(context: Context, week: number): Promise<CourseRow[]> {
    const store = await AppDbHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('course');
    predicates.lessThanOrEqualTo('start_week', week);
    predicates.greaterThanOrEqualTo('end_week', week);
    predicates.orderByAsc('day_index');
    predicates.orderByAsc('start_time');
    const rs = await store.query(predicates);
    return readCourses(rs);
  }

  /** 按天查 */
  static async queryByDay(context: Context, dayIndex: number, week: number): Promise<CourseRow[]> {
    const store = await AppDbHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('course');
    predicates.equalTo('day_index', dayIndex);
    predicates.lessThanOrEqualTo('start_week', week);
    predicates.greaterThanOrEqualTo('end_week', week);
    predicates.orderByAsc('start_time');
    const rs = await store.query(predicates);
    return readCourses(rs);
  }
}
