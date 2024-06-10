import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rup_chitran_front/screens/login.dart';

class CameraPage extends StatefulWidget {
  static String id = 'CameraPage';
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _isDetecting = false;
  List<html.File> _imageFiles = [];
  List<html.File> _queue = [];

  html.VideoElement? _videoElement;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    _videoElement = html.VideoElement();
    await html.window.navigator.mediaDevices!
        .getUserMedia({'video': true}).then((stream) {
      _videoElement!.srcObject = stream;
      _videoElement!.play();
    }).catchError((e) {
      print('Error accessing camera: $e');
    });
  }

  Future<void> _captureImage() async {
    if (_isDetecting) {
      try {
        final canvas = html.CanvasElement(
            width: _videoElement!.videoWidth,
            height: _videoElement!.videoHeight);
        final ctx = canvas.context2D;
        ctx.drawImage(_videoElement!, 0, 0);
        final blob = await canvas.toBlob('image/png');
        final imageFile = html.File([blob], 'capture.png');

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
    final uri = Uri.parse('http://127.0.0.1:8000/images/');

    // Convert the image file to base64
    String base64Image = await _convertToBase64(imageFile);

    // Create the request body
    var body = jsonEncode({'image': base64Image});

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
    print('Image post failed with error: ${e.toString()} for image: ${imageFile.name}');
  }
}

  void _processQueue() {
    for (var imageFile in _queue) {
      _postImage(imageFile);
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

  Future<String> _convertToBase64(html.File imageFile) async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(imageFile);
    await reader.onLoad.first;
    final Uint8List bytes = reader.result as Uint8List;
    return base64Encode(bytes);
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
          if (_videoElement != null)
            Container(
              child: HtmlElementView(viewType: 'videoElement'),
              height: 300,
            ),
        ],
      ),
    );
  }
}
