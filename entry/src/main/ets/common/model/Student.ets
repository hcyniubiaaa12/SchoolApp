export interface Student {
  id?: number;
  name: string;
  age: number;
  score: number;
  updateTime: string;
}

export interface StudentInput {
  name: string;
  age: number;
  score: number;
}
