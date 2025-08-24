import 'package:flutter/material.dart';

class ConnectionLine extends StatelessWidget {
  final double startX, startY, endX, endY;

  const ConnectionLine({
    super.key,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LinePainter(startX, startY, endX, endY),
    );
  }
}

class _LinePainter extends CustomPainter {
  final double startX, startY, endX, endY;

  _LinePainter(this.startX, this.startY, this.endX, this.endY);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellowAccent // dark background-ൽ കാണാൻ yellow
      ..strokeWidth = 2;

    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
