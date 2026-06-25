/**
 * Score.ets - 成绩模型
 */
export interface ScoreItem {
  id: string;
  courseName: string;
  score: number;           // 百分制成绩
  gpa: number;             // 绩点
  credit: string;          // 学分
  examTime: string;        // 考试时间
  semester: string;        // 学期
}
