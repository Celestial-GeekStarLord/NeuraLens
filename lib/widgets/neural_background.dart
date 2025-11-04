import 'dart:math';
import 'package:flutter/material.dart';

class NeuralBackgroundPainter extends CustomPainter {
  final double progress;
  final Random _random = Random();

  NeuralBackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint bgPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.black,
          const Color.fromARGB(255, 8, 8, 8),
          const Color.fromARGB(255, 0, 0, 0),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final Paint particlePaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 60; i++) {
      double dx =
          (size.width * ((i * 37 % 100) / 100)) +
          sin(progress * 2 * pi + i) * 20;
      double dy =
          (size.height * ((i * 53 % 100) / 100)) +
          cos(progress * 2 * pi + i) * 20;
      canvas.drawCircle(Offset(dx, dy), 1.8, particlePaint);
    }

    final Paint linePaint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.15)
      ..strokeWidth = 0.6;
  }

  @override
  bool shouldRepaint(covariant NeuralBackgroundPainter oldDelegate) => true;
}
