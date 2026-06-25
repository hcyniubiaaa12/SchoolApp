/**
 * Course.ets - 课程模型
 */
export interface CourseItem {
  id: string;
  name: string;
  teacher: string;
  location: string;
  dayIndex: number;       // 1-7：周一至周日
  startTime: string;       // '08:00'
  endTime: string;         // '09:40'
  startWeek: number;
  endWeek: number;
  courseType: string;      // 必修/选修/公共课/实践
  color: string;           // 课程卡片颜色
  credit: string;          // 学分
  remark?: string;         // 备注
}
