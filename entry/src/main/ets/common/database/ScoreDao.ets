/**
 * ScoreDao.ets - 成绩数据访问
 *
 * 核心查询：按绩点降序、按学期筛选
 */
import { relationalStore } from '@kit.ArkData';
import { AppDbHelper } from './AppDbHelper';

export interface ScoreRow {
  id: string;
  courseName: string;
  score: number;
  gpa: number;
  credit: string;
  examTime: string;
  semester: string;
}

function toScoreRow(rs: relationalStore.ResultSet): ScoreRow {
  return {
    id: rs.getString(rs.getColumnIndex('id')),
    courseName: rs.getString(rs.getColumnIndex('course_name')),
    score: rs.getDouble(rs.getColumnIndex('score')),
    gpa: rs.getDouble(rs.getColumnIndex('gpa')),
    credit: rs.getString(rs.getColumnIndex('credit')),
    examTime: rs.getString(rs.getColumnIndex('exam_time')),
    semester: rs.getString(rs.getColumnIndex('semester'))
  };
}

function readScores(rs: relationalStore.ResultSet): ScoreRow[] {
  const list: ScoreRow[] = [];
  while (rs.goToNextRow()) {
    list.push(toScoreRow(rs));
  }
  rs.close();
  return list;
}

export class ScoreDao {
  static async queryAll(context: Context): Promise<ScoreRow[]> {
    const store = await AppDbHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('score');
    predicates.orderByDesc('gpa');
    const rs = await store.query(predicates);
    return readScores(rs);
  }

  static async queryBySemester(context: Context, semester: string): Promise<ScoreRow[]> {
    const store = await AppDbHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('score');
    predicates.equalTo('semester', semester);
    predicates.orderByDesc('gpa');
    const rs = await store.query(predicates);
    return readScores(rs);
  }
}
