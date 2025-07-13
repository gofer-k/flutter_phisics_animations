import 'dart:math' as math;
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class BernoulliPainter extends CustomPainter {
  final Cubic curve;
  final double animationProgress;
  final Color originalCurveColor;
  final Color offsetCurveColor;
  final double strokeWidth;
  final double startPipeRadius; // How far to offset the parallel curves
  final double endPipeRadius; // How far to offset the parallel curves
  final int segments; // Number of segments to approximate the parallel curve
  final List<double> dashPattern;

  BernoulliPainter({
    required this.curve,
    required this.animationProgress,
    this.originalCurveColor = Colors.blue,
    this.offsetCurveColor = Colors.green,
    this.strokeWidth = 2.0,
    required this.startPipeRadius,
    required this.endPipeRadius,
    this.segments = 50, // More segments = smoother, but more computation
    required this.dashPattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint offsetPaint = Paint()
      ..color = offsetCurveColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // --- 1. Define and get the full original path ---
    final Path fullPath = Path();
    final Offset p0 = Offset(0, size.height);
    final Offset p3 = Offset(size.width, 0);
    final Offset cp1 = Offset(
        curve.b * size.width, size.height - (curve.a * size.height));
    final Offset cp2 = Offset(
        curve.d * size.width, size.height - (curve.c * size.height));

    fullPath.moveTo(p0.dx, p0.dy);
    fullPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p3.dx, p3.dy);

    Path animatedOriginalPath = Path();
    for (ui.PathMetric pathMetric in fullPath.computeMetrics()) {
      animatedOriginalPath.addPath(
          pathMetric.extractPath(
              0.0, pathMetric.length * animationProgress.clamp(0.0, 1.0)),
          Offset.zero);
    }

    // Calculate and draw parallel paths (only if there's something to draw) ---
    List<Offset> leftBorderPoints = _generateBoardPaths(fullPath.computeMetrics(), true); // For one side
    List<Offset> rightBorderPoints = _generateBoardPaths(fullPath.computeMetrics(), false); // For the other side

    if (animationProgress <= 0) return;

    // Use the helper to draw the original path
    _drawFlowPath(canvas, leftBorderPoints, rightBorderPoints, originalCurveColor.withValues(alpha: 0.5));

    _drawDashedPath(canvas, animatedOriginalPath, dashPattern, originalCurveColor);

    _drawPipeBorder(canvas, offsetPaint, leftBorderPoints);
    _drawPipeBorder(canvas, offsetPaint, rightBorderPoints);
  }

  // Helper method to draw a path with a dash pattern
  void _drawDashedPath(Canvas canvas, Path path, List<double> dashArray, Color dashColor) {
    // Use the paint's color if dashColor is not provided, otherwise override
    final Paint dashPaint = Paint()
      ..color = dashColor // Use specific dash color or fallback
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke // Dashes are always strokes
      ..strokeCap = StrokeCap.square;

    double distance = 0.0;
    bool draw = true;
    int dashIndex = 0;

    for (ui.PathMetric metric in path.computeMetrics()) {
      while (distance < metric.length) {
        double dashLength = dashArray[dashIndex % dashArray.length];
        if (draw) {
          canvas.drawPath(
            metric.extractPath(distance, math.min(distance + dashLength, metric.length)),
            dashPaint, // Use the potentially overridden dashPaint
          );
        }
        distance += dashLength;
        draw = !draw;
        dashIndex++;
      }
      distance = 0; // Reset for next metric if path has multiple contours (unlikely for simple Bezier)
      draw = true;
      dashIndex = 0;
    }
    canvas.drawPath(path, dashPaint);
  }

  void _drawFlowPath(Canvas canvas,
      List<Offset> offsetPointsBorderLeft,
      List<Offset> offsetPointsBorderRight,
      Color flowColor) {

    if (offsetPointsBorderLeft.isEmpty || offsetPointsBorderRight.isEmpty) {
      return; // Nothing to draw
    }

    // Ensure we have a consistent number of points to form segments.
    // The lists should ideally be the same length, as they are generated
    // with the same number of segments.
    final int numSegmentsLeft = offsetPointsBorderLeft.length - 1;
    final int numSegmentsRight = offsetPointsBorderRight.length - 1;

    // Use the minimum number of segments if lengths are somehow different,
    // though they should be the same from _generateBoardPaths.
    // final int totalSegments = math.min(math.min(numSegmentsLeft, numSegmentsRight), 10);
    final int totalSegments = math.min(numSegmentsLeft, numSegmentsRight);

    if (totalSegments < 0) return; // Need at least one segment (2 points per list)

    final Paint flowPaint = Paint()
      ..color = flowColor
      ..style = PaintingStyle.fill; // We want to fill the shape

    // Calculate how many segments to draw based on animationProgress
    // Multiply by totalSegments because each "segment" connects two points.
    // Add 1 because if animationProgress is > 0, we want at least one quad.
    final int segmentsToDraw = (animationProgress * totalSegments).ceil().clamp(0, totalSegments);

    if (segmentsToDraw <= 0) {
      return; // Nothing to draw yet based on animation progress
    }

    final Path flowPath = Path();

    // Start the path at the first point of the left border
    flowPath.moveTo(offsetPointsBorderLeft[0].dx, offsetPointsBorderLeft[0].dy);

    // Add points for the left border up to the animated segment
    for (int i = 1; i <= segmentsToDraw; i++) {
      // Ensure we don't go out of bounds if offsetPointsBorderLeft has fewer points than segmentsToDraw+1
      if (i < offsetPointsBorderLeft.length) {
        flowPath.lineTo(offsetPointsBorderLeft[i].dx, offsetPointsBorderLeft[i].dy);
      } else if (offsetPointsBorderLeft.isNotEmpty) {
        // If out of bounds but list is not empty, use the last point
        flowPath.lineTo(offsetPointsBorderLeft.last.dx, offsetPointsBorderLeft.last.dy);
      }
    }

    // Now, add points for the right border in reverse order to close the polygon
    // The last point connected on the right border should correspond to the
    // last point connected on the left border (index `segmentsToDraw`)
    for (int i = segmentsToDraw; i >= 0; i--) {
      // Ensure we don't go out of bounds
      if (i < offsetPointsBorderRight.length) {
        flowPath.lineTo(offsetPointsBorderRight[i].dx, offsetPointsBorderRight[i].dy);
      } else if (offsetPointsBorderRight.isNotEmpty) {
        flowPath.lineTo(offsetPointsBorderRight.last.dx, offsetPointsBorderRight.last.dy);
      }
    }

    // Close the path to form a polygon (connects the last point of right border back to the first point of left border)
    flowPath.close();

    canvas.drawPath(flowPath, flowPaint);
  }

  void _drawPipeBorder(Canvas canvas, Paint offsetPaint, final List<Offset> offsetPoints1) {
    if (offsetPoints1.length > 1) {
      Path parallelPath1 = Path();
      parallelPath1.moveTo(offsetPoints1.first.dx, offsetPoints1.first.dy);
      for (int i = 1; i < offsetPoints1.length; i++) {
        parallelPath1.lineTo(offsetPoints1[i].dx, offsetPoints1[i].dy);
      }
      canvas.drawPath(parallelPath1, offsetPaint);
    }
  }

  List<Offset> _generateBoardPaths(PathMetrics originPath, bool leftSide) {
    List<Offset> pathPoints = [];

    for (ui.PathMetric pathMetric in originPath) {
      final double totalLength = pathMetric.length;
      if (totalLength <= 0) continue;

      for (int i = 0; i <= segments; i++) {
        double t = i / segments; // Parameter along the current length
        double currentDistanceOnPath = t * totalLength;

        final ui.Tangent? tangent = pathMetric.getTangentForOffset(
            currentDistanceOnPath);
        if (tangent != null) {
          Offset point = tangent.position;
          Offset normal = (leftSide ?
            Offset(-tangent.vector.dy, tangent.vector.dx) :
            Offset(tangent.vector.dy, -tangent.vector.dx)).normalized(); // Normal vector

          double offsetDistance = startPipeRadius + t * (endPipeRadius - startPipeRadius);
          pathPoints.add(point + normal * offsetDistance);
        }
      }
      break;
    }
    return pathPoints;
  }

  void paintPoint(Canvas canvas, Color color, Offset offset) {
    final pointPaint = Paint()
      ..color = color
      ..strokeWidth = 15.0 // Define a strokeWidth to make points visible
      ..strokeCap = StrokeCap.round; // Makes the points circular

    // Example 1: Drawing individual points
    canvas.drawPoints(PointMode.points, [offset], pointPaint);
  }

  @override
  bool shouldRepaint(BernoulliPainter oldDelegate) {
    return oldDelegate.curve != curve ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.originalCurveColor != originalCurveColor ||
        oldDelegate.offsetCurveColor != offsetCurveColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.startPipeRadius != startPipeRadius ||
        oldDelegate.endPipeRadius != endPipeRadius ||
        oldDelegate.segments != segments ||
        oldDelegate.dashPattern != dashPattern;
  }
}

// Helper extension for normalizing Offset (making its length 1)
extension OffsetUtils on Offset {
  Offset normalized() {
    final double d = distance;
    if (d == 0) return Offset.zero;
    return this / d;
  }
}