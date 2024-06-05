"use client";

import React, { useState } from 'react';
import { Course, Teacher } from '@/types';

const CourseComponent: React.FC<{ teachers: Teacher[] }> = ({ teachers }) => {
  const [courses, setCourses] = useState<Course[]>([]);
  const [courseName, setCourseName] = useState('');
  const [teacherId, setTeacherId] = useState<number | string>('');

  const addCourse = () => {
    const newCourse: Course = {
      id: courses.length + 1,
      courseName,
      teacherId: Number(teacherId),
    };
    setCourses([...courses, newCourse]);
  };

  return (
    <div>
      <h2>Courses</h2>
      <div>
        <input
          type="text"
          placeholder="Course Name"
          value={courseName}
          onChange={(e) => setCourseName(e.target.value)}
        />
        <select
          value={teacherId}
          onChange={(e) => setTeacherId(e.target.value)}
        >
          <option value="">Select Teacher</option>
          {teachers.map((teacher) => (
            <option key={teacher.id} value={teacher.id}>
              {teacher.teacherName}
            </option>
          ))}
        </select>
        <button onClick={addCourse}>Add Course</button>
      </div>
      <ul>
        {courses.map((course) => (
          <li key={course.id}>{course.courseName}</li>
        ))}
      </ul>
    </div>
  );
};

export default CourseComponent;
