import 'package:flutter/material.dart';
import 'package:rup_chitran_front/screens/courses.dart';
import 'package:rup_chitran_front/screens/home.dart';
import 'package:rup_chitran_front/screens/image_sender.dart';
import 'package:rup_chitran_front/screens/login.dart';
import 'package:rup_chitran_front/screens/signup.dart';
import 'package:rup_chitran_front/screens/student.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute:HomePage.id,
    routes: {
      HomePage.id: (context) => HomePage(),
      LoginPage.id: (context) => LoginPage(),
      SignupPage.id: (context) => SignupPage(),
      CoursePage.id: (context) => CoursePage(),
      Student.id: (context) => Student(),
      CameraPage.id: (context) => CameraPage(),
    },
  ));
}
