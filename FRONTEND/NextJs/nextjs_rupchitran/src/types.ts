// src/types.ts
export interface Teacher {
    id: number;
    teacherName: string;
    email: string;
    password: string;
  }
  
  export interface Student {
    id: number;
    studentName: string;
    rollNo: number;
  }
  
  export interface Course {
    id: number;
    courseName: string;
    teacherId: number;
  }
  
  export interface Attendance {
    id: number;
    courseId: number;
    date: string;
    status: boolean;
  }
  
  export interface CourseStudents {
    id: number;
    courseId: number;
    studentId: number;
  }
  
  export interface AttendanceStudents {
    id: number;
    attendanceId: number;
    studentId: number;
  }
  