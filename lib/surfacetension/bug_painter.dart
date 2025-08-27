import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class BugPainter extends CustomPainter {
  final double progress;
  final Offset target;

  BugPainter({required this.progress, required this.target});

  @override
  void paint(Canvas canvas, Size size) {
    final bugPaint = Paint()..color = Colors.black;
    final legPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;

    // Pozycja owada
    final bugX = lerpDouble(50, target.dx, progress)!;
    final bugY = lerpDouble(size.height / 2, target.dy, progress)!;
    final bugCenter = Offset(bugX, bugY);
    final bugLegLength = 20;

    // Rysuj ciało
    canvas.drawCircle(bugCenter, 10, bugPaint);

    // Rysuj nogi (oscylujące)
    for (int i = 0; i < 6; i++) {
      final angle = pi / 3 * i + sin(progress * pi * 2) * 0.2;
      final legOffset = Offset(cos(angle) * bugLegLength, sin(angle) * bugLegLength);
      canvas.drawLine(bugCenter, bugCenter + legOffset, legPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BugPainter oldDelegate) => true;
}