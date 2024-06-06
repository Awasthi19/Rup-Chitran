import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' as ui;
import 'package:flutter/widgets.dart' as widgets;


class CameraPage extends StatefulWidget {
  static String id='CameraPage';
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

  void _initializeCamera() {
    _videoElement = html.VideoElement();
    html.window.navigator.mediaDevices!.getUserMedia({'video': true}).then((stream) {
      _videoElement!.srcObject = stream;
      _videoElement!.play();
    }).catchError((e) {
      print('Error accessing camera: $e');
    });
  }

  Future<void> _captureImage() async {
    if (_isDetecting) {
      try {
        final canvas = html.CanvasElement(width: _videoElement!.videoWidth, height: _videoElement!.videoHeight);
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
        print(e);
      }
    }
  }

  Future<void> _postImage(html.File imageFile) async {
    try {
      final uri = Uri.parse('YOUR_IMAGE_POST_URL_HERE');
      final request = http.MultipartRequest('POST', uri);

      final reader = html.FileReader();
      reader.readAsArrayBuffer(imageFile);
      await reader.onLoad.first;

      final bytes = reader.result as Uint8List;
      final multipartFile = http.MultipartFile.fromBytes('image', bytes, filename: imageFile.name);
      request.files.add(multipartFile);

      final response = await request.send();
      if (response.statusCode == 200) {
        print('Image posted successfully: ${imageFile.name}');
        setState(() {
          _queue.remove(imageFile);
        });
      } else {
        print('Image post failed with status: ${response.statusCode} for image: ${imageFile.name}');
      }
    } catch (e) {
      print('Image post failed with error: $e for image: ${imageFile.name}');
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

  Future<String> _convertToDataUrl(html.File imageFile) async {
    final reader = html.FileReader();
    reader.readAsDataUrl(imageFile);
    await reader.onLoad.first;
    return reader.result as String;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera Page')),
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
          // Comment out or remove the ListView.builder
          // Expanded(
          //   child: ListView.builder(
          //     itemCount: _imageFiles.length,
          //     itemBuilder: (context, index) {
          //       return FutureBuilder<String>(
          //         future: _convertToDataUrl(_imageFiles[index]),
          //         builder: (context, snapshot) {
          //           if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          //             return ListTile(
          //               title: Text('Image ${index + 1}'),
          //               subtitle: Text(_imageFiles[index].name),
          //               onTap: () {
          //                 Navigator.push(
          //                   context,
          //                   MaterialPageRoute(
          //                     builder: (context) => ImageDisplayPage(imageDataUrl: snapshot.data!),
          //                   ),
          //                 );
          //               },
          //               leading: Image.network(snapshot.data!),
          //             );
          //           } else {
          //             return ListTile(
          //               title: Text('Image ${index + 1}'),
          //               subtitle: Text('Loading...'),
          //             );
          //           }
          //         },
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}

// The ImageDisplayPage class remains the same, but you can also remove it if it's not needed anymore
class ImageDisplayPage extends StatelessWidget {
  final String imageDataUrl;

  ImageDisplayPage({required this.imageDataUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Display')),
      body: Center(
        child: Image.network(imageDataUrl),
      ),
    );
  }
}
