import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'package:rup_chitran_front/screens/login.dart';

class EmotionPage extends StatefulWidget {
  static String id = 'EmotionPage';

  @override
  State<EmotionPage> createState() => _EmotionPageState();
}

class _EmotionPageState extends State<EmotionPage> {
  @override
  bool _isDetecting = false;
  bool _cameraInitialized = false;
  List<html.File> _imageFiles = [];
  List<html.File> _queue = [];
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  List<Rect> _faceBoundingBoxes = [];
  List<String?> _detectedNames = [];

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

        // Process face detection
        _detectFaces(response.body);
      } else {
        print(
            'Image post failed with status: ${response.statusCode} for image: ${imageFile.name}');
      }
    } catch (e) {
      print(
          'Image post failed with error: ${e.toString()} for image: ${imageFile.name}');
    }
  }

  Future<void> _detectFaces(String responseBody) async {
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:8000/recognize_emotion/'));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.isNotEmpty && responseData[0] != null) {
          setState(() {
            _faceBoundingBoxes = [];
            _detectedNames = [];
            for (var faceData in responseData) {
              if (faceData['coordinates'] != null) {
                _faceBoundingBoxes.add(Rect.fromLTWH(
                  double.parse(faceData['coordinates']['x'].toString()),
                  double.parse(faceData['coordinates']['y'].toString()),
                  double.parse(faceData['coordinates']['w'].toString()),
                  double.parse(faceData['coordinates']['h'].toString()),
                ));
                _detectedNames.add(faceData['Name']);
              }
            }
          });

          // Remove the bounding boxes and names after a second
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              _faceBoundingBoxes = [];
              _detectedNames = [];
            });
          });
        } else {
          print('No valid face data received');
        }
      }
    } catch (e) {
      print('Face detection failed with error: ${e.toString()}');
    }
  }

  void _processQueue() {
    if (_queue.isNotEmpty) {
      _postImage(_queue.first);
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
      body: Stack(
        children: [
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
          if (_faceBoundingBoxes.isNotEmpty)
            CustomPaint(
              painter: FacePainter(_faceBoundingBoxes, _detectedNames),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: _isDetecting ? _stopDetecting : _startDetecting,
              child: Text(_isDetecting ? 'Stop Detecting' : 'Start Detecting'),
            ),
          ),
        ],
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  final List<Rect> faceBoundingBoxes;
  final List<String?> names;

  FacePainter(this.faceBoundingBoxes, this.names);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < faceBoundingBoxes.length; i++) {
      // Draw the bounding box
      canvas.drawRect(faceBoundingBoxes[i], paint);

      // Draw the name above the bounding box
      if (names[i] != null) {
        final textSpan = TextSpan(
          text: names[i],
          style: TextStyle(color: Colors.red, fontSize: 20.0),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
            canvas,
            Offset(faceBoundingBoxes[i].left,
                faceBoundingBoxes[i].top - textPainter.height));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
