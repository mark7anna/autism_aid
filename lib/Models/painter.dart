// lib/detector_painter.dart
import 'package:flutter/material.dart';
import 'object_detection.dart';

class DetectorPainter extends CustomPainter {
  final List<DetectionResult> detections;
  final Size imageSize;

  DetectorPainter(this.detections, this.imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (var detection in detections) {
      final rect = Rect.fromLTWH(
        detection.x * size.width,
        detection.y * size.height,
        detection.w * size.width,
        detection.h * size.height,
      );

      final center = Offset(
        (rect.left + rect.right) / 2,
        (rect.top + rect.bottom) / 2,
      );
      final radius = rect.width > rect.height ? rect.height / 2 : rect.width / 2;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
