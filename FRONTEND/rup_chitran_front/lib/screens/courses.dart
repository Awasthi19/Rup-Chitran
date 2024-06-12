import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rup_chitran_front/screens/image_sender.dart';
import 'package:rup_chitran_front/screens/login.dart';
import 'package:rup_chitran_front/screens/student.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rup_chitran_front/constants/constant.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class CoursePage extends StatefulWidget {
  static String id = 'course';

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  List _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  void fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');

    if (token == null) {
      setState(() {
        _isLoading = false;
      });
      showErrorDialog(context, err: 'No token found. Please log in.');
      return;
    }

    var url = Uri.http('127.0.0.1:8000', '/courses/');
    try {
      var response = await http.get(
        url,
        headers: {
          'Authorization': '$token',
        },
      );

      if (response.statusCode == 200) {
        // Change this from 201 to 200
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        setState(() {
          _courses = responseBody['courses'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        showErrorDialog(context,
            err: 'Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showErrorDialog(context, err: 'An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.pushNamed(context, LoginPage.id);
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      String courseName = _courses[index][
                          'course_name']; // Change 'courseName' to 'course_name'
                      if (kIsWeb) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CameraPage(courseName: courseName),
                          ),
                        );
                        print('Running on the web');
                      } else {
                        if (Platform.isAndroid) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Student(
                                        courseName: courseName,
                                      )));
                          print('Running on Android');
                        } else if (Platform.isIOS) {
                          print('Running on iOS');
                        } else {
                          print('Running on an unknown platform');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _courses[index][
                                'course_name'], // Change 'courseName' to 'course_name'
                            style: TextStyle(fontSize: 20.0),
                          ),
                          // If there's no teacherId in the response, you can remove the following lines
                          // SizedBox(height: 8.0),
                          // Text(
                          //   'Teacher ID: ${_courses[index]['teacherId']}',
                          //   style: TextStyle(fontSize: 16.0),
                          // ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
