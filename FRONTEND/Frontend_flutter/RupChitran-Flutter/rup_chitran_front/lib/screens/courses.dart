import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rup_chitran_front/screens/student.dart'; // Import the StudentPage
import 'package:rup_chitran_front/constants/constant.dart';

// Main widget for displaying courses
class CoursePage extends StatefulWidget {
  static String id = 'course';

  @override
  _CoursePageState createState() => _CoursePageState();
}

// State class for CoursePage
class _CoursePageState extends State<CoursePage> {
  List _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  // Method to fetch courses from the API
  Future<void> _fetchCourses() async {
    // Replace with your actual API URL
    var url = Uri.parse('http://example.com/api/courses');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _courses = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      showErrorDialog(context,err: 'Failed to load courses');
    }
  }

  // Method to show error dialog


  // Method to navigate to the StudentPage
  void _navigateToStudents(int courseId) async{
    var Url=Uri.parse('http://example.com/api/students');
   var response = await http.post(Url,
        body: {'courseId':courseId});
    if (response.statusCode == 200) {
      print(response.statusCode);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Student(courseId: courseId),
      ),
    );
    } else {
      showErrorDialog(context,err:'${response.statusCode} Failed to load students');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () => _navigateToStudents(_courses[index]['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Background color
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _courses[index]['courseName'],
                            style: TextStyle(fontSize: 20.0),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Teacher ID: ${_courses[index]['teacherId']}',
                            style: TextStyle(fontSize: 16.0),
                          ),
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
