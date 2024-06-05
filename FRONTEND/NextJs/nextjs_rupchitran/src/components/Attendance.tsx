"use client";

import React, { useState } from 'react';
import { Attendance, Course } from '@/types';

const AttendanceComponent: React.FC<{ courses: Course[] }> = ({ courses }) => {
  const [attendanceRecords, setAttendanceRecords] = useState<Attendance[]>([]);
  const [courseId, setCourseId] = useState<number | string>('');
  const [date, setDate] = useState('');
  const [status, setStatus] = useState<boolean>(false);

  const addAttendance = () => {
    const newAttendance: Attendance = {
      id: attendanceRecords.length + 1,
      courseId: Number(courseId),
      date,
      status,
    };
    setAttendanceRecords([...attendanceRecords, newAttendance]);
  };

  return (
    <div>
      <h2>Attendance</h2>
      <div>
        <select
          value={courseId}
          onChange={(e) => setCourseId(e.target.value)}
        >
          <option value="">Select Course</option>
          {courses.map((course) => (
            <option key={course.id} value={course.id}>
              {course.courseName}
            </option>
          ))}
        </select>
        <input
          type="date"
          value={date}
          onChange={(e) => setDate(e.target.value)}
        />
        <label>
          Present:
          <input
            type="checkbox"
            checked={status}
            onChange={() => setStatus(!status)}
          />
        </label>
        <button onClick={addAttendance}>Add Attendance</button>
      </div>
      <ul>
        {attendanceRecords.map((record) => (
          <li key={record.id}>
            {record.date} - {record.status ? 'Present' : 'Absent'}
          </li>
        ))}
      </ul>
    </div>
  );
};

export default AttendanceComponent;
