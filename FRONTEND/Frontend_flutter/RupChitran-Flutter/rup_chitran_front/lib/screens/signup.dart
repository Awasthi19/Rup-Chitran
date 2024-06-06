import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rup_chitran_front/screens/login.dart';
import 'package:rup_chitran_front/functionality/makeInput.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:rup_chitran_front/constants/constant.dart';

class SignupPage extends StatefulWidget {
  static String id = 'signup';

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isEmpty = false;
  bool _completed = false;

  

  void HandleSubmit() async {
    setState(() {
      _completed = true;
    });

    var email = _emailController.text.trim();
    var password = _passwordController.text.trim();
    var username = _usernameController.text.trim();
    

    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      setState(() {
        _isEmpty = true;
        showErrorDialog(context, err: 'Please fill all the fields');
        _completed = false;
      });
      return;
    }

    var url = Uri.http('127.0.0.1:8000', '/signup/');
    try {
      var response = await http.post(
        url,
        body: {'email': email, 'password': password, 'username': username},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        setState(() {
          _completed = false;
        });
        Navigator.pushNamed(context, LoginPage.id);
      } else {
        setState(() {
          _completed = false;
        });
        var responseBody = response.body;
        print('Error response: $responseBody');
        showErrorDialog(context, err: 'Something went wrong: $responseBody');
      }
    } catch (e) {
      setState(() {
        _completed = false;
      });
      print('Exception: $e');
      showErrorDialog(context, err: 'An error occurred: $e');
    }
  }
  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            padding: EdgeInsets.symmetric(horizontal: 40),
            height: MediaQuery.of(context).size.height - 50,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    FadeInUp(
                        duration: Duration(milliseconds: 1000),
                        child: Text(
                          "Sign up",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    FadeInUp(
                        duration: Duration(milliseconds: 1200),
                        child: Text(
                          "Create an account, It's free",
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey[700]),
                        )),
                  ],
                ),
                Column(
                  children: <Widget>[
                    FadeInUp(
                        duration: Duration(milliseconds: 1200),
                        child: makeInput(
                          label: "Email",
                          controller: _emailController,
                          obscureText: false,
                          borderColor: _isEmpty ? Colors.red : Colors.grey,
                          errorText: _isEmpty ? "This field is required" : null,
                        )),
                    FadeInUp(
                        duration: Duration(milliseconds: 1300),
                        child: makeInput(
                          label: "User Name",
                          obscureText: false,
                          controller: _usernameController,
                          borderColor: _isEmpty ? Colors.red : Colors.grey,
                          errorText: _isEmpty ? "This field is required" : null,
                        )),
                    FadeInUp(
                        duration: Duration(milliseconds: 1400),
                        child: makeInput(
                          label: "Password",
                          obscureText: true,
                          isPasswordField: true,
                          controller: _passwordController,
                          borderColor: _isEmpty ? Colors.red : Colors.grey,
                          errorText: _isEmpty ? "This field is required" : null,
                        )),
                  ],
                ),
                FadeInUp(
                    duration: Duration(milliseconds: 1500),
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
                            HandleSubmit();
                          });
                        },
                        color: Colors.greenAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        child: Text(
                          "Sign up",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                      ),
                    )),
                FadeInUp(
                    duration: Duration(milliseconds: 1600),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Already have an account?"),
                        GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            Navigator.pushNamed(context, LoginPage.id);
                          },
                          child: Text(
                            " Login",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
