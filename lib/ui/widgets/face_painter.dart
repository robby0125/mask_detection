import 'package:flutter/material.dart';

class FacePainter extends CustomPainter {
  const FacePainter({
    required this.rectFaces,
  });

  final List<Rect> rectFaces;

  @override
  void paint(Canvas canvas, Size size) {
    final _paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.0;

    for (Rect rect in rectFaces) {
      canvas.drawRect(rect, _paint);
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) => true;
}
