import relationalStore from '@ohos.data.relationalStore';
import { DatabaseHelper } from './DatabaseHelper';
import { Student, StudentInput } from '../model/Student';
import { TABLE_STUDENT } from '../constants/StorageKeys';

interface StudentRow {
  id: number;
  name: string;
  age: number;
  score: number;
  updateTime: string;
}

function getNow(): string {
  const now = new Date();
  const year = now.getFullYear();
  const month = `${now.getMonth() + 1}`.padStart(2, '0');
  const day = `${now.getDate()}`.padStart(2, '0');
  const hours = `${now.getHours()}`.padStart(2, '0');
  const minutes = `${now.getMinutes()}`.padStart(2, '0');
  const seconds = `${now.getSeconds()}`.padStart(2, '0');
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
}

function toStudentRow(result: relationalStore.ResultSet): StudentRow {
  return {
    id: result.getLong(result.getColumnIndex('id')),
    name: result.getString(result.getColumnIndex('name')),
    age: result.getLong(result.getColumnIndex('age')),
    score: result.getDouble(result.getColumnIndex('score')),
    updateTime: result.getString(result.getColumnIndex('update_time'))
  };
}

function toStudent(row: StudentRow): Student {
  return {
    id: row.id,
    name: row.name,
    age: row.age,
    score: row.score,
    updateTime: row.updateTime
  };
}

function buildStudentBucket(input: StudentInput): relationalStore.ValuesBucket {
  const bucket: relationalStore.ValuesBucket = {
    name: input.name,
    age: input.age,
    score: input.score,
    update_time: getNow()
  };
  return bucket;
}

function buildScoreBucket(score: number): relationalStore.ValuesBucket {
  const bucket: relationalStore.ValuesBucket = {
    score: score,
    update_time: getNow()
  };
  return bucket;
}

function toError(err: Object): Error {
  return err instanceof Error ? err : new Error(JSON.stringify(err));
}

function readStudents(resultSet: relationalStore.ResultSet): Student[] {
  const students: Student[] = [];
  try {
    while (resultSet.goToNextRow()) {
      students.push(toStudent(toStudentRow(resultSet)));
    }
  } finally {
    resultSet.close();
  }
  return students;
}

export class StudentDao {
  static async insert(context: Context, input: StudentInput): Promise<number> {
    const store = await DatabaseHelper.getRdbStore(context);
    return store.insert(TABLE_STUDENT, buildStudentBucket(input));
  }

  static async queryAll(context: Context): Promise<Student[]> {
    const store = await DatabaseHelper.getRdbStore(context);
    const predicates = new relationalStore.RdbPredicates(TABLE_STUDENT);
    predicates.orderByDesc('id');
    const resultSet = await store.query(predicates);
    return readStudents(resultSet);
  }

  static async queryByName(context: Context, keyword: string): Promise<Student[]> {
    const store = await DatabaseHelper.getRdbStore(context);
    const predicates = new relationalStore.RdbPredicates(TABLE_STUDENT);
    if (keyword.trim().length > 0) {
      predicates.contains('name', keyword.trim());
    }
    predicates.orderByDesc('id');
    const resultSet = await store.query(predicates);
    return readStudents(resultSet);
  }

  static async updateScore(context: Context, id: number, score: number): Promise<void> {
    const store = await DatabaseHelper.getRdbStore(context);
    const predicates = new relationalStore.RdbPredicates(TABLE_STUDENT);
    predicates.equalTo('id', id);
    await store.update(buildScoreBucket(score), predicates);
  }

  static async deleteById(context: Context, id: number): Promise<void> {
    const store = await DatabaseHelper.getRdbStore(context);
    const predicates = new relationalStore.RdbPredicates(TABLE_STUDENT);
    predicates.equalTo('id', id);
    await store.delete(predicates);
  }

  static async batchInsert(context: Context, students: StudentInput[]): Promise<void> {
    const store = await DatabaseHelper.getRdbStore(context);
    await store.beginTransaction();
    try {
      for (const student of students) {
        await store.insert(TABLE_STUDENT, buildStudentBucket(student));
      }
      await store.commit();
    } catch (err) {
      await store.rollBack();
      throw toError(err as Object);
    }
  }
}
