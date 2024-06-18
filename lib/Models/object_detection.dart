// lib/object_detection.dart
import 'package:tflite_v2/tflite_v2.dart';
import 'dart:io';

// lib/object_detection.dart
class DetectionResult {
  final String detectedClass;
  final double x, y, w, h;

  DetectionResult({
    required this.detectedClass,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });

  factory DetectionResult.fromMap(Map<String, dynamic> map) {
    return DetectionResult(
      detectedClass: map['detectedClass'] as String,
      x: (map['rect']['x'] as num).toDouble(),
      y: (map['rect']['y'] as num).toDouble(),
      w: (map['rect']['w'] as num).toDouble(),
      h: (map['rect']['h'] as num).toDouble(),
    );
  }
}

class ObjectDetection {
  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/models/ssd_mobilenet.tflite",
      labels: "assets/models/ssd_mobilenet.txt",
    );
  }

  Future<List<DetectionResult>> detectObject(File image) async {
    var recognitions = await Tflite.detectObjectOnImage(
      path: image.path,
      model: "SSDMobileNet",
      threshold: 0.5,
      numResultsPerClass: 1,
    );

    if (recognitions == null) {
      return [];
    }

    return recognitions.map<DetectionResult>((recog) {
      return DetectionResult.fromMap(Map<String, dynamic>.from(recog));
    }).toList();
  }

  void dispose() {
    Tflite.close();
  }
}
