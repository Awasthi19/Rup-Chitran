import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Student extends StatefulWidget {
  static String id = 'Student';

  final String? courseName;
  Student({this.courseName});

  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  bool _isDetecting = false;
  List<String> _imagePaths = [];
  List<String> _queue = [];

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_isDetecting) {
      try {
        await _initializeControllerFuture;

        final image = await _controller!.takePicture();
        final imagePath = image.path;

        setState(() {
          _imagePaths.add(imagePath);
          _queue.add(imagePath);
        });

        print('Image captured: $imagePath');
        _processQueue();
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _postImage(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      final uri = Uri.parse('http://127.0.0.1:8000/image/');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = '$token'
        ..files.add(await http.MultipartFile.fromPath('image', imagePath))
        ..fields['course'] = widget.courseName ?? '';

      final response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Image posted successfully: $imagePath');
        setState(() {
          _queue.remove(imagePath);
        });
      } else {
        print(
            'Image post failed with status: ${response.statusCode} for image: $imagePath');
      }
    } catch (e) {
      print('Image post failed with error: $e for image: $imagePath');
    }
  }

  void _processQueue() {
    for (var imagePath in _queue) {
      _postImage(imagePath);
    }
  }

  void _startDetecting() {
    setState(() {
      _isDetecting = true;
    });
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isDetecting) {
        timer.cancel();
      } else {
        _captureImage();
      }
    });
  }

  void _stopDetecting() {
    setState(() {
      _isDetecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera Page')),
      body: Column(
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ElevatedButton(
            onPressed: _isDetecting ? _stopDetecting : _startDetecting,
            child: Text(_isDetecting ? 'Stop Detecting' : 'Start Detecting'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _imagePaths.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Image ${index + 1}'),
                  subtitle: Text(_imagePaths[index]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ImageDisplayPage(imagePath: _imagePaths[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ImageDisplayPage extends StatelessWidget {
  final String imagePath;

  ImageDisplayPage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Display')),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}
