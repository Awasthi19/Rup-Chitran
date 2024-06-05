"use client";

import React, { useState } from 'react';
import { Student } from '@/types';

const StudentComponent: React.FC = () => {
  const [students, setStudents] = useState<Student[]>([]);
  const [studentName, setStudentName] = useState('');
  const [rollNo, setRollNo] = useState<number | string>('');

  const addStudent = () => {
    const newStudent: Student = {
      id: students.length + 1,
      studentName,
      rollNo: Number(rollNo),
    };
    setStudents([...students, newStudent]);
  };

  return (
    <div>
      <h2>Students</h2>
      <div>
        <input
          type="text"
          placeholder="Student Name"
          value={studentName}
          onChange={(e) => setStudentName(e.target.value)}
        />
        <input
          type="number"
          placeholder="Roll No"
          value={rollNo}
          onChange={(e) => setRollNo(e.target.value)}
        />
        <button onClick={addStudent}>Add Student</button>
      </div>
      <ul>
        {students.map((student) => (
          <li key={student.id}>{student.studentName}</li>
        ))}
      </ul>
    </div>
  );
};

export default StudentComponent;
