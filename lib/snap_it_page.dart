// lib/main.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'Models/object_detection.dart';
import 'Models/painter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart' show rootBundle;

class SnapItPage extends StatefulWidget {
  @override
  _SnapItPageState createState() => _SnapItPageState();
}

class _SnapItPageState extends State<SnapItPage> {
  File? _imageFile;
  List<DetectionResult>? _detections;
  final ObjectDetection _objectDetection = ObjectDetection();
  Size? _imageSize;
  bool _isLoading = false;
  FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();

  // List of recommended image paths (these should be paths to local images)
  final List<String> _recommendedImages = [
    'assets/Recommended1.png',
    'assets/Recommended2.jpeg',
    'assets/Recommended3.jpeg',
    'assets/Recommended4.jpeg',
    'assets/Recommended5.jpeg',
    'assets/Recommended6.jpeg',
    'assets/Recommended7.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    await _objectDetection.loadModel();
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
    });
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      File image = File(pickedFile.path);
      final decodedImage = await decodeImageFromList(image.readAsBytesSync());

      setState(() {
        _imageFile = image;
        _detections = null; // Clear previous detections
        _imageSize =
            Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
      });
      await _runObjectDetection(image);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _tryRecommendedImage() async {
    setState(() {
      _isLoading = true;
    });
    // Pick a random image from the recommended images list
    String imagePath =
        _recommendedImages[_random.nextInt(_recommendedImages.length)];
    print(imagePath);

    // Load image as byte data
    final ByteData data = await rootBundle.load(imagePath);
    final Uint8List bytes = data.buffer.asUint8List();

    // Decode the image
    final decodedImage = await decodeImageFromList(bytes);

    // Save byte data to temporary file to use with File class
    final tempDir = await Directory.systemTemp.createTemp();
    final tempFile = File('${tempDir.path}/temp_image.png');
    await tempFile.writeAsBytes(bytes);

    setState(() {
      _imageFile = tempFile;
      _detections = null; // Clear previous detections
      _imageSize =
          Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
    });

    await _runObjectDetection(tempFile);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _runObjectDetection(File image) async {
    try {
      List<DetectionResult> detections =
          await _objectDetection.detectObject(image);
      setState(() {
        _detections = detections;
      });
    } catch (e) {
      print("Error during object detection: $e");
      setState(() {
        _detections = [];
      });
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _speakDetections() async {
    if (_detections != null && _detections!.isNotEmpty) {
      String detectedObjects =
          _detections!.map((d) => d.detectedClass).join(', ');
      await _flutterTts.speak("Detected objects are: $detectedObjects");
    } else {
      await _flutterTts.speak("No objects detected.");
    }
  }

  @override
  void dispose() {
    _objectDetection.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snap It'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isLoading
                  ? CircularProgressIndicator()
                  : _imageFile != null
                      ? Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                    ),
                                    child: Image.file(
                                      _imageFile!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 300,
                                    ),
                                  ),
                                  if (_detections != null && _imageSize != null)
                                    CustomPaint(
                                      painter: DetectorPainter(
                                          _detections!, _imageSize!),
                                      child: Container(
                                        width: double.infinity,
                                        height: 300,
                                      ),
                                    ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: _detections != null &&
                                        _detections!.isNotEmpty
                                    ? Wrap(
                                        spacing: 8.0,
                                        runSpacing: 4.0,
                                        children: _detections!
                                            .map((detection) => ActionChip(
                                                  label: Text(
                                                      detection.detectedClass),
                                                  onPressed: () => _speak(
                                                      detection.detectedClass),
                                                ))
                                            .toList(),
                                      )
                                    : Text(
                                        'No objects detected.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ),
                            ],
                          ),
                        )
                      : Text(
                          'No image selected',
                          style: TextStyle(fontSize: 18),
                        ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: Icon(Icons.photo_library),
                label: Text('Choose Image'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: Icon(Icons.camera_alt),
                label: Text('Take Picture'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _speakDetections,
                icon: Icon(Icons.play_arrow),
                label: Text('Play All'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _tryRecommendedImage,
                icon: Icon(Icons.image),
                label: Text('Try Recommended Image'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
