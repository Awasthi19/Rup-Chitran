"use client";

import React, { useState } from 'react';
import { Teacher } from '@/types';

const TeacherComponent: React.FC = () => {
  const [teachers, setTeachers] = useState<Teacher[]>([]);
  const [teacherName, setTeacherName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const addTeacher = () => {
    const newTeacher: Teacher = {
      id: teachers.length + 1,
      teacherName,
      email,
      password,
    };
    setTeachers([...teachers, newTeacher]);
  };

  return (
    <div>
      <h2>Teachers</h2>
      <div>
        <input
          type="text"
          placeholder="Teacher Name"
          value={teacherName}
          onChange={(e) => setTeacherName(e.target.value)}
        />
        <input
          type="email"
          placeholder="Email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
        />
        <input
          type="password"
          placeholder="Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
        <button onClick={addTeacher}>Add Teacher</button>
      </div>
      <ul>
        {teachers.map((teacher) => (
          <li key={teacher.id}>{teacher.teacherName}</li>
        ))}
      </ul>
    </div>
  );
};

export default TeacherComponent;
