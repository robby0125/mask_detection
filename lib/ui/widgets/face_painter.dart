import 'package:flutter/material.dart';

class FacePainter extends CustomPainter {
  const FacePainter({
    required this.rectFaces,
    required this.detectionResult,
  });

  final List<Rect> rectFaces;
  final List<int> detectionResult;

  @override
  void paint(Canvas canvas, Size size) {
    final _paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.5;

    if (rectFaces.length != detectionResult.length) return;

    for (int i = 0; i < rectFaces.length; i++) {
      _paint.color = detectionResult[i] == 0 ? Colors.green : Colors.red;
      canvas.drawRect(rectFaces[i], _paint);
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) => true;
}
