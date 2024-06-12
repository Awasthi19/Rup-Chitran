import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'package:rup_chitran_front/screens/login.dart';

class CameraPage extends StatefulWidget {
  static String id = 'CameraPage';
  CameraPage({ this.courseName}) {}

  final String? courseName;

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _isDetecting = false;
  bool _cameraInitialized = false;
  List<html.File> _imageFiles = [];
  List<html.File> _queue = [];
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
      );

      _initializeControllerFuture = _controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _cameraInitialized = true;
        });
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _captureImage() async {
    if (_isDetecting && _cameraInitialized) {
      try {
        await _initializeControllerFuture;

        final XFile file = await _controller!.takePicture();
        final imageBytes = await file.readAsBytes();
        final imageFile = html.File([imageBytes], 'capture.png');

        setState(() {
          _imageFiles.add(imageFile);
          _queue.add(imageFile);
        });

        print('Image captured: ${imageFile.name}');
        _processQueue();
      } catch (e) {
        print('Error capturing image: ${e.toString()}');
      }
    }
  }

  Future<void> _postImage(html.File imageFile) async {
    try {
      final uri = Uri.parse('http://127.0.0.1:8000/image/');

      // Convert the image file to base64
      String base64Image = await _convertToBase64(imageFile);

      // Create the request body
      var body = jsonEncode({
        'image': base64Image,
        'course': widget.courseName,
      });

      // Send the POST request
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Both 200 and 201 are treated as success
        print('Image posted successfully: ${imageFile.name}');
        setState(() {
          _queue.remove(imageFile);
        });
      } else {
        print(
            'Image post failed with status: ${response.statusCode} for image: ${imageFile.name}');
      }
    } catch (e) {
      print(
          'Image post failed with error: ${e.toString()} for image: ${imageFile.name}');
    }
  }

  void _processQueue() {
    for (var imageFile in _queue) {
      _postImage(imageFile);
    }
  }

  void _startDetecting() {
    if (!_cameraInitialized) {
      _initializeCamera().then((_) {
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
      });
    } else {
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
  }

  void _stopDetecting() {
    setState(() {
      _isDetecting = false;
    });
  }

  Future<String> _convertToBase64(html.File imageFile) async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(imageFile);
    await reader.onLoad.first;
    final Uint8List bytes = reader.result as Uint8List;
    return base64Encode(bytes);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.pushNamed(context, LoginPage.id);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _isDetecting ? _stopDetecting : _startDetecting,
            child: Text(_isDetecting ? 'Stop Detecting' : 'Start Detecting'),
          ),
          if (_cameraInitialized)
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller!);
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error initializing camera: ${snapshot.error}'),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
        ],
      ),
    );
  }
}
