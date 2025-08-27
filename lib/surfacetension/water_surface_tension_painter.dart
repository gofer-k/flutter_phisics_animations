import 'dart:math';
import 'dart:ui';

import 'package:first_flutter_app/surfacetension/drop_painter.dart';
import 'package:flutter/material.dart';

class WaterSurfaceTensionPainter extends CustomPainter {
  final double t; // Normalized time [0..1]
  final Offset dropPosition;

  WaterSurfaceTensionPainter(this.t, this.dropPosition);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    final waterLevel = h * 0.6; // y-coordinate of calm surface
    final dropX = dropPosition.dx;
    final maxDropRadius = 10.0;
    final waterSurface = h - waterLevel;
    // 1) Draw static water body below the surface
    // paint.color = Colors.blue.shade700;
    paint.color = Colors.blue.shade700;
    canvas.drawRect(
      Rect.fromLTWH(0, waterLevel, w, waterSurface),
      paint,
    );

    // 2) Draw calm surface
    paint.color = Colors.blue.shade900;
    paint.strokeWidth = 8.0;
    canvas.drawLine(Offset(0, waterLevel), Offset(w, waterLevel), paint);

    // 3) Compute drop animation phases
    // Phase 1: drop falls (t in [0, 0.5])
    // Phase 2: ripple evolves (t in (0.5, 1])
    final fallProgress = (t / 0.5).clamp(0.0, 1.0);
    final rippleProgress = ((t - 0.5) / 0.5).clamp(0.0, 1.0);

    // 4) Draw the drop if still falling
    if (t < 0.5) {
      final dropY = lerpDouble(dropPosition.dy, waterLevel - maxDropRadius, fallProgress)!;
      paint.color = Colors.lightBlueAccent;
      canvas.drawCircle(Offset(dropX, dropY), maxDropRadius, paint);
    }

    // 5) Draw surface with ripple deformation
    final path = Path()..moveTo(0, waterLevel);
    // ripple parameters
    final sigma = w * 0.2;
    final amp0 = 20.0;
    final damping = 3.0;
    final phase = rippleProgress * pi * 4; // two full oscillations
    // Amplitude A(t) = A₀·e^(–d·t)·sin(ωt), creating a damped oscillation.
    final amp = amp0 * exp(-damping * rippleProgress) * sin(phase);

    // Construct a smooth path with a Gaussian bump centered at dropX
    for (double x = 0; x <= w; x += 1) {
      final dx = x - dropX;
      // y(x) = waterLevel + A(t) · exp(–(x–x₀)²/(2σ²))
      final dy = amp * exp(-dx * dx / (2 * sigma * sigma));
      path.lineTo(x, waterLevel + dy);
    }
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    paint.color = Colors.blue;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WaterSurfaceTensionPainter oldDelegate) => oldDelegate.t != t;
}