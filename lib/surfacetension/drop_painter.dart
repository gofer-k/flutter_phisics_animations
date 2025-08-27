import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DropPainter extends CustomPainter {
  final double time; // normalized 0→1
  Offset dropPosition;
  DropPainter(this.time, this.dropPosition);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    final waterY = h * 0.6;
    final dropX = w * 0.5;
    const dropR = 10.0;

    // Draw static water below the surface
    paint.color = Colors.blue.shade700;
    canvas.drawRect(Rect.fromLTWH(0, waterY, w, h - waterY), paint);

    // Split into drop‐fall (t<0.5) and ripple (t>=0.5)
    final fallProgress = (time / 0.5).clamp(0.0, 1.0);
    final rippleProgress = ((time - 0.5) / 0.5).clamp(0.0, 1.0);

    // 1) Falling drop
    if (time < 0.5) {
      final dropY = dropR + (waterY - 2 * dropR) * fallProgress;
      paint.color = Colors.lightBlueAccent;
      canvas.drawCircle(Offset(dropX, dropY), dropR, paint);
    }

    // 2) Ripple on surface
    final path = Path()..moveTo(0, waterY);

    // damped sinusoidal amplitude
    final amp0 = 20.0;
    final damping = 3.0;
    final phase = rippleProgress * 4 * pi; // two full cycles
    // Amplitude A(t) = A₀·e^(–d·t)·sin(ωt), creating a damped oscillation.
    final amp = amp0 * exp(-damping * rippleProgress) * sin(phase);

    // Gaussian spread
    final sigma = w * 0.15;
    for (double x = 0; x <= w; x++) {
      final dx = x - dropX;
      // y(x) = waterLevel + A(t) · exp(–(x–x₀)²/(2σ²))
      final dy = amp * exp(-dx * dx / (2 * sigma * sigma));
      path.lineTo(x, waterY + dy);
    }

    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    paint.color = Colors.blue;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant DropPainter old) => old.time != time;
}