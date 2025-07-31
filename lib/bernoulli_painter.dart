import 'dart:math' as math;
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'bermoulli_model.dart';

class BernoulliPainter extends CustomPainter {
  final Cubic curve;
  final double animationProgress;
  final Color originalCurveColor;
  final Color offsetCurveColor;
  final double strokeWidth;
  final List<double> dashPattern;
  final BermoulliModel model;
  
  BernoulliPainter({
    required this.curve,
    required this.animationProgress,
    this.originalCurveColor = Colors.blue,
    this.offsetCurveColor = Colors.grey,
    this.strokeWidth = 2.0,
    required this.dashPattern,
    required this.model,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    _drawArrow(canvas,size);

    final Paint originPaint = Paint()
      ..color = originalCurveColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // --- 1. Define and get the full original path ---
    final Path path = Path();
    final points = model.path.getNormalizedPath(size, Offset(0.0, 0.0));

    path.moveTo(points.first.dx, points.first.dy);
    for (Offset p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, originPaint);

    Path animatedOriginalPath = Path();
    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      animatedOriginalPath.addPath(
          pathMetric.extractPath(
              0.0, pathMetric.length * animationProgress.clamp(0.0, 1.0)),
          Offset.zero);
    }

    // Calculate and draw parallel paths (only if there's something to draw) ---
    List<Offset> leftBorderPoints = _generateBoardPaths(size, path.computeMetrics(), true); // For one side
    List<Offset> rightBorderPoints = _generateBoardPaths(size, path.computeMetrics(), false); // For the other side

    // --- Draw the Flow Path (Animated Segment) ---
    if (animationProgress > 0) { // Only start drawing flow after animation begins
      _drawFlowPath(
          canvas,
          leftBorderPoints,
          rightBorderPoints,
          originalCurveColor.withValues(alpha: 0.5), // Example color
          0.10 // Draw a 10% segment
      );
    }

    final Paint bordersPaint = Paint()
      ..color = offsetCurveColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    _drawPipeBorder(canvas, bordersPaint, leftBorderPoints);
    _drawPipeBorder(canvas, bordersPaint, rightBorderPoints);
  }

  void _drawArrow(Canvas canvas, Size size) {
    final Paint axisPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;

    final xStart = size.width * 0.25;
    final xEnd = size.width * 0.75;
    final yPos = size.height - 20.0;

    canvas.drawLine(Offset(xStart, yPos), Offset(xEnd, yPos), axisPaint);
    // Arrow
    canvas.drawLine(
        Offset(xEnd - 15.0, yPos - 5.0),
        Offset(xEnd, yPos), axisPaint);
    canvas.drawLine(
        Offset(xEnd - 15.0, yPos + 5.0),
        Offset(xEnd, yPos), axisPaint);
  }

  void _drawFlowPath(Canvas canvas,
      List<Offset> offsetPointsBorderLeft,
      List<Offset> offsetPointsBorderRight,
      Color flowColor, double flowSegmentPercentage) {

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

    // Calculate the number of segments for the 10% (or flowSegmentPercentage) window
    // Ensure at least 1 segment if totalSegments is small and percentage is also small
    final int windowSizeInSegments =
    (totalSegments * flowSegmentPercentage).ceil().clamp(1, totalSegments);

    // Calculate the starting segment index for the window based on animationProgress
    // This makes the window slide along the path.
    // (totalSegments - windowSizeInSegments) is the maximum starting index
    // to ensure the window doesn't go out of bounds at the end.
    final int maxStartSegment = totalSegments - windowSizeInSegments;

    // If maxStartSegment is negative (e.g. window is larger than total),
    // it means we draw the whole thing from the start.
    // This can happen if flowSegmentPercentage is 1.0 or very close with few totalSegments.
    final int currentStartSegment = (maxStartSegment > 0)
        ? (animationProgress * maxStartSegment).floor().clamp(0, maxStartSegment)
        : 0;

    // Calculate the ending segment index for the window
    final int currentEndSegment =
    (currentStartSegment + windowSizeInSegments).clamp(0, totalSegments);

    // If the window has no actual width to draw (can happen with clamping and small numbers)
    if (currentStartSegment >= currentEndSegment && !(currentStartSegment == 0 && currentEndSegment == 0 && totalSegments == 0) ) {

      // Check an edge case: if start and end are 0 because totalSegments is 0, we already returned.
      // If start and end are same but not 0 (e.g. start=5, end=5), then it's an empty window.
      // However, if the intent is to draw a "single point" segment (which is visually nothing for a fill),
      // and currentStartSegment = currentEndSegment = totalSegments, it means we are at the very end.
      // To simplify, if window has no span, just return.
      if (totalSegments > 0 && currentStartSegment == currentEndSegment && currentStartSegment < totalSegments) {
        // This condition means the window is of zero length before the end.
        return;
      }
        // If currentStartSegment == currentEndSegment == totalSegments, it implies the animation is at the very end
        // and the window is meant to be at the last segment. Let it proceed if it makes sense for your logic.
        // For now, if no span, we return.
        if (currentStartSegment == currentEndSegment && currentStartSegment < totalSegments) return;
    }

    final Path flowPath = Path();

    // We need at least two points on each side to form a quadrilateral.
    // The points are indexed from 0 to totalSegments.
    // A segment `s` uses points `s` and `s+1`.

    // Start the path at the `currentStartSegment` point of the left border
    if (currentStartSegment < offsetPointsBorderLeft.length) {
      flowPath.moveTo(offsetPointsBorderLeft[currentStartSegment].dx,
          offsetPointsBorderLeft[currentStartSegment].dy);
    } else if (offsetPointsBorderLeft.isNotEmpty) {
      // Fallback if currentStartSegment is somehow out of direct bounds but list is not empty
      flowPath.moveTo(offsetPointsBorderLeft.last.dx, offsetPointsBorderLeft.last.dy);
    } else {
      return; // Cannot start path
    }

    // Add points for the left border within the window
    // Iterate from currentStartSegment + 1 up to currentEndSegment
    for (int i = currentStartSegment + 1; i <= currentEndSegment; i++) {
      if (i < offsetPointsBorderLeft.length) {
        flowPath.lineTo(offsetPointsBorderLeft[i].dx, offsetPointsBorderLeft[i].dy);
      } else if (offsetPointsBorderLeft.isNotEmpty) {
        // If 'i' goes out of bounds, use the last available point of the left border
        // This can happen if currentEndSegment reaches the very end.
        flowPath.lineTo(offsetPointsBorderLeft.last.dx, offsetPointsBorderLeft.last.dy);
        break; // Stop adding points from left if we've hit the end
      }
    }

    // Now, add points for the right border within the window, in reverse order
    // Iterate from currentEndSegment down to currentStartSegment
    for (int i = currentEndSegment; i >= currentStartSegment; i--) {
      if (i < offsetPointsBorderRight.length) {
        flowPath.lineTo(offsetPointsBorderRight[i].dx, offsetPointsBorderRight[i].dy);
      } else if (offsetPointsBorderRight.isNotEmpty) {
        // If 'i' goes out of bounds, use the last available point of the right border
        flowPath.lineTo(offsetPointsBorderRight.last.dx, offsetPointsBorderRight.last.dy);
        // We don't break here as we need to try and connect back to currentStartSegment
      }
    }

    flowPath.close(); // Close the path to form the polygon for the segment

    if (!flowPath.getBounds().isEmpty) { // Only draw if the path is not empty
      canvas.drawPath(flowPath, flowPaint);
    }
  }

  void _drawPipeBorder(Canvas canvas, Paint offsetPaint, final List<Offset> offsetPoints) {
    if (offsetPoints.length > 1) {
      Path parallelPath1 = Path();
      parallelPath1.moveTo(offsetPoints.first.dx, offsetPoints.first.dy);
      for (int i = 1; i < offsetPoints.length; i++) {
        parallelPath1.lineTo(offsetPoints[i].dx, offsetPoints[i].dy);
      }
      canvas.drawPath(parallelPath1, offsetPaint);
    }
  }

  List<Offset> _generateBoardPaths(Size size, PathMetrics originPath, bool leftSide) {
    List<Offset> pathPoints = [];
    final normAreaUnit = (model.path.xRange.end - model.path.xRange.begin).abs();
    for (ui.PathMetric pathMetric in originPath) {
      final double totalLength = pathMetric.length;
      if (totalLength <= 0) continue;

      for (int i = 0; i <= model.path.segments; i++) {
        double t = i / model.path.segments; // Parameter along the current length
        double currentDistanceOnPath = t * totalLength;

        final ui.Tangent? tangent = pathMetric.getTangentForOffset(
            currentDistanceOnPath);
        if (tangent != null) {
          Offset point = tangent.position;
          Offset normal = (leftSide ?
            Offset(-tangent.vector.dy, tangent.vector.dx) :
            Offset(tangent.vector.dy, -tangent.vector.dx)).normalized(); // Normal vector

          double offsetDistance = (model.area.begin + t * (model.area.end - model.area.begin)) * normAreaUnit;
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
        oldDelegate.dashPattern != dashPattern ||
        oldDelegate.model != model;
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