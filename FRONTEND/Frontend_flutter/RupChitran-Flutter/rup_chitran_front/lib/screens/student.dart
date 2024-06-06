import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:async/async.dart';
import 'package:animate_do/animate_do.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rup_chitran_front/screens/login.dart';

class Student extends StatefulWidget {
  static String id = 'student';
  final int? courseId;

  const Student({Key? key, this.courseId}) : super(key: key);

  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
  CameraController? _controller;
  bool _isRecording = false;
  bool _completed = false;
  bool _isCameraPermissionGranted = false;
  bool _isCameraInitialized = false;
  late Directory _tempDir;
  late String _videoFilePath;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        _isCameraPermissionGranted = true;
      });
      await _initializeCamera();
    } else {
      setState(() {
        _isCameraPermissionGranted = false;
      });
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.medium);

    try {
      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      _showSnackBar(context, 'Error initializing camera: $e');
    }
  }

  Future<void> _startVideoRecording() async {
    if (!(_controller?.value.isInitialized ?? false)) {
      _showSnackBar(context, 'Error: Camera not initialized');
      return;
    }

    setState(() {
      _isRecording = true;
    });

    try {
      _tempDir = await getTemporaryDirectory();
      _videoFilePath = path.join(_tempDir.path, '${DateTime.now()}.mp4');
      await _controller!.startVideoRecording();

      _controller!.startImageStream((CameraImage image) {
        _processCameraImage(image);
      });
    } catch (e) {
      _showSnackBar(context, 'Error: $e');
    }
  }

  void _processCameraImage(CameraImage image) async {
    final Uint8List imageBytes = Uint8List.fromList(image.planes[0].bytes);
    _sendFrameToBackend(imageBytes);
  }

  Future<void> _sendFrameToBackend(Uint8List frameBytes) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('YOUR_BACKEND_URL_HERE'));
      var multipartFile = http.MultipartFile.fromBytes('frame', frameBytes,
          filename: 'frame.jpg');
      request.files.add(multipartFile);

      var response = await request.send();
      if (response.statusCode == 200) {
        print('Frame sent successfully');
      } else {
        print('Failed to send frame with status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending frame: $e');
    }
  }

  Future<void> _stopVideoRecording() async {
    if (!(_controller?.value.isRecordingVideo ?? false)) return;

    try {
      await _controller!.stopVideoRecording();
    } catch (e) {
      _showSnackBar(context, 'Error: $e');
    } finally {
      setState(() {
        _isRecording = false;
      });
    }
  }

  void _handleSubmit(BuildContext ctx) async {
    setState(() {
      _completed = true;
    });

    if (!_isRecording) {
      _showSnackBar(ctx, 'Please start recording');
      setState(() {
        _completed = false;
      });
      return;
    }

    await _stopVideoRecording();

    setState(() {
      _completed = false;
    });

    Navigator.pushNamed(ctx, LoginPage.id);
  }

  void _showSnackBar(BuildContext ctx, String message) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(message)));
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
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    FadeInUp(
                      duration: Duration(milliseconds: 1000),
                      child: Text(
                        "Student Video",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 20),
                    FadeInUp(
                      duration: Duration(milliseconds: 1200),
                      child: Text(
                        "Capture a video to proceed!!!",
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    SizedBox(height: 20),
                    FadeInUp(
                      duration: Duration(milliseconds: 1400),
                      child: ElevatedButton(
                        onPressed: _isRecording
                            ? _stopVideoRecording
                            : _startVideoRecording,
                        child: Text(_isRecording
                            ? 'Stop Recording'
                            : 'Start Recording'),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (_isCameraInitialized)
                      FadeInUp(
                        duration: Duration(milliseconds: 1500),
                        child: Container(
                          height: 300, // Specify a fixed height
                          child: CameraPreview(_controller!),
                        ),
                      )
                    else if (_isCameraPermissionGranted)
                      FadeInUp(
                        duration: Duration(milliseconds: 1600),
                        child: CircularProgressIndicator(),
                      )
                    else
                      FadeInUp(
                        duration: Duration(milliseconds: 1600),
                        child: Text('Camera permission not granted'),
                      ),
                  ],
                ),
                FadeInUp(
                  duration: Duration(milliseconds: 1600),
                  child: Container(
                    padding: EdgeInsets.only(top: 3, left: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.black),
                    ),
                    child: MaterialButton(
                      height: 60,
                      onPressed: () => _handleSubmit(context),
                      color: Colors.greenAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
