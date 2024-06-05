"use client";

import { useState } from 'react';
import TeacherComponent from '@/components/Teacher';
import StudentComponent from '@/components/Student';
import CourseComponent from '@/components/Course';
import AttendanceComponent from '@/components/Attendance';
import { Teacher, Student, Course, Attendance } from '@/types';

const Home = () => {
  const [teachers, setTeachers] = useState<Teacher[]>([]);
  const [students, setStudents] = useState<Student[]>([]);
  const [courses, setCourses] = useState<Course[]>([]);

  return (
    <div>
      <h1>School Management System</h1>
      <TeacherComponent />
      <StudentComponent />
      <CourseComponent teachers={teachers} />
      <AttendanceComponent courses={courses} />
    </div>
  );
};

export default Home;
