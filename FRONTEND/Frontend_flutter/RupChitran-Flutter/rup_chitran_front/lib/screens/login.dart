import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rup_chitran_front/screens/courses.dart';
import 'package:rup_chitran_front/screens/image_sender.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:rup_chitran_front/screens/signup.dart';
import 'package:rup_chitran_front/functionality/makeInput.dart';
import 'package:rup_chitran_front/constants/constant.dart';

class LoginPage extends StatefulWidget {
  static String id = 'login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _loginEmailController = TextEditingController();
  TextEditingController _loginPasswordController = TextEditingController();
  bool _hasEmailError = false;
  bool _hasPasswordError = false;
  bool _completed = false;

  void Login() async {
    setState(() {
      _completed = true;
    });

    String email = _loginEmailController.text.trim();
    String password = _loginPasswordController.text.trim();
    print('Email: $email, Password: $password,');

    if (email.isEmpty || password.isEmpty) {
      showErrorDialog(context, err: 'Please fill all the fields');
      setState(() {
        _completed = false;
      });
      return;
    }

    var url = Uri.http('127.0.0.1:8000', '/login/');
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        // Checking if the token is null
        if (responseBody.containsKey('jwt') && responseBody['jwt'] != null) {
          final String token = responseBody['jwt'];
          // saving the response to shared preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt', token);
          print('token: $token');

          setState(() {
            _hasEmailError = false;
            _hasPasswordError = false;
            _completed = false;
          });

          // Navigate to the next page or show a success message
          // Navigator.pushNamed(context, CoursePage.id);
          Navigator.pushNamed(context, CameraPage.id);
        } else {
          showErrorDialog(context,
              err: 'An unknown error occurred: Invalid response format');
        }
      } else if (response.statusCode == 400) {
        showErrorDialog(context, err: 'Email and password are required');
      } else if (response.statusCode == 404) {
        setState(() {
          _hasEmailError = true;
        });
        showErrorDialog(context, err: 'User not found');
      } else if (response.statusCode == 401) {
        setState(() {
          _hasPasswordError = true;
        });
        showErrorDialog(context, err: 'Invalid credentials');
      } else {
        showErrorDialog(context, err: 'An unknown error occurred');
      }

      _loginEmailController.clear();
      _loginPasswordController.clear();
    } catch (e) {
      showErrorDialog(context, err: 'An error occurred: $e');
    }

    setState(() {
      _completed = false;
    });
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _completed,
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          FadeInUp(
                              duration: Duration(milliseconds: 1000),
                              child: Text(
                                "Login",
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              )),
                          SizedBox(
                            height: 20,
                          ),
                          FadeInUp(
                              duration: Duration(milliseconds: 1200),
                              child: Text(
                                "Login to your account",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey[700]),
                              )),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: <Widget>[
                            FadeInUp(
                              duration: Duration(milliseconds: 1200),
                              child: makeInput(
                                obscureText: false,
                                label: "Email",
                                controller: _loginEmailController,
                                borderColor:
                                    _hasEmailError ? Colors.red : Colors.grey,
                                errorText: _hasEmailError
                                    ? "Couldn't find your Account"
                                    : null,
                              ),
                            ),
                            FadeInUp(
                              duration: Duration(milliseconds: 1300),
                              child: makeInput(
                                label: "Password",
                                obscureText: true,
                                isPasswordField: true,
                                controller: _loginPasswordController,
                                borderColor: _hasPasswordError
                                    ? Colors.red
                                    : Colors.grey,
                                errorText: _hasPasswordError
                                    ? "Incorrect password"
                                    : null,
                                // onTap: () => setState(() {
                                //   _hasPasswordError = false;},
                                // ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      FadeInUp(
                          duration: Duration(milliseconds: 1400),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Container(
                              padding: EdgeInsets.only(top: 3, left: 3),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border(
                                    bottom: BorderSide(color: Colors.black),
                                    top: BorderSide(color: Colors.black),
                                    left: BorderSide(color: Colors.black),
                                    right: BorderSide(color: Colors.black),
                                  )),
                              child: MaterialButton(
                                minWidth: double.infinity,
                                height: 60,
                                onPressed: () {
                                  setState(() {
                                    try {
                                      Login();
                                    } catch (e) {
                                      print(e);
                                    }
                                  });
                                },
                                color: Colors.greenAccent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18),
                                ),
                              ),
                            ),
                          )),
                      FadeInUp(
                          duration: Duration(milliseconds: 1500),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Don't have an account?"),
                              GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  Navigator.pushNamed(context, SignupPage.id);
                                },
                                child: Text(
                                  "Sign up",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18),
                                ),
                              ),
                            ],
                          ))
                    ],
                  ),
                ),
                FadeInUp(
                    duration: Duration(milliseconds: 1200),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 3,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/background.png'),
                              fit: BoxFit.cover)),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
