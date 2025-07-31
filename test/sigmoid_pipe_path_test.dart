import 'dart:ui';

import 'package:first_flutter_app/pipe_path.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:first_flutter_app/sigmoid_pipe_path.dart';

import 'dart:math' as math;

void main() {
  double sigmoid(double x) {
    return 1.0 / (1.0 + math.exp(-x));
  }

  Offset normalizePoint(Offset point, Size size, Range xRange, Range yRange) {
    final xLength = xRange.end - xRange.begin;
    final dx = (point.dx - xRange.begin) / xLength * size.width;
    final dy = size.height * (1 - point.dy);

    return Offset(dx, dy);
  }

  group('SigmoidCurve Tests', () {
    test('generate should produce correct number of points', () {
      final xRange = Range(begin: -1.0, end: 1.0);
      final yRange = Range(begin: 0.0, end: 100.0);
      final int segments = 10;

      final curve = SigmoidCurve(xRange: xRange, yRange: yRange, segments: segments);
      expect(curve.pathOfPoints.length, equals(segments + 1));
    });

    test('generate should correctly calculate first and last points', () {
      final int segments = 10;
      final xRange = Range(begin: -1.0, end: 1.0);
      final yRange = Range(begin: 0.0, end: 1.0); // yMid will be 50
      final curve = SigmoidCurve(xRange: xRange, yRange: yRange, segments: segments);

      final points = curve.pathOfPoints;
      final double expectedFirstX = ((0 / segments) * (xRange.end - xRange.begin) + xRange.begin);

      final expectedFirstY = sigmoid(expectedFirstX);

      expect(points.first.dx, closeTo(expectedFirstX, 0.0001));
      expect(points.first.dy, closeTo(expectedFirstY, 0.0001));

      final expectedLastX = ((points.length - 1) / segments) * (xRange.end - xRange.begin) + xRange.begin;
      final expectedLastY = sigmoid(expectedLastX);

      expect(points.last.dx, closeTo(expectedLastX, 0.0001));
      expect(points.last.dy, closeTo(expectedLastY, 0.0001));
    });

    test('generate should correctly calculate midpoint', () {
      // For midpoint, xRange should be symmetric around 0 for xNorm to be 0 at i=segments/2
      final int segments = 10;
      final xRange = Range(begin: -1.0, end: 1.0); // xLength = 2
      final yRange = Range(begin: 0.0, end: 1.0); // yMid = 100
      final curve = SigmoidCurve(xRange: xRange, yRange: yRange, segments: segments); // Constructor segments is not used by generate

      final points = curve.pathOfPoints;
      // The internal segments is 100. Midpoint index is 50.
      final midPoint = points[(segments / 2).toInt()];

      final expectedMidX = (xRange.end + xRange.begin) / 2.0;
      final expectedMidY = sigmoid(expectedMidX);

      expect(midPoint.dx, closeTo(expectedMidX, 0.0001));
      expect(midPoint.dy, closeTo(expectedMidY, 0.0001));
    });

    test('generate should scale y values correctly based on yRange', () {
      final int segments = 10;
      final yRange1 = Range(begin: 0.0, end: 100.0);
      final yRange2 = Range(begin: 0.0, end: 200.0);

      final xRange = Range(begin: -1.0, end: 1.0);
      final curveScaling1 = SigmoidCurve(xRange: xRange, yRange: yRange1, segments: segments); // yMid = 50
      final curveScaling2 = SigmoidCurve(xRange: xRange, yRange: yRange2, segments: segments); // yMid = 100

      final expectedY1 = sigmoid(xRange.begin);
      final expectedY2 = sigmoid(xRange.begin);

      expect(curveScaling1.pathOfPoints.first.dy, closeTo(expectedY1, 0.0001));
      expect(curveScaling2.pathOfPoints.first.dy, closeTo(expectedY2, 0.0001));
    });

    test('generate should handle xRange.begin == xRange.end', () {
      final int segments = 10;
      final xRange = Range(begin: 0.5, end: 0.5);
      final yRange = Range(begin: 0.0, end: 100.0); // yMid = 50
      final curve = SigmoidCurve(xRange: xRange, yRange: yRange, segments: segments);

      final points = curve.pathOfPoints;
      expect(points.length, segments + 1);

      final expectedX = xRange.begin;
      final expectedY = sigmoid(expectedX);

      for (var point in points) {
        expect(point.dx, closeTo(expectedX, 0.0001));
        expect(point.dy, closeTo(expectedY, 0.0001));
      }
    });

    test('generate normalized values', () {
      final int segments = 10;
      final xRange = Range(begin: -1.0, end: 1.0);
      final yRange = Range(begin: 0.0, end: 1.0);
      final size = Size(300, 200);

      final curve = SigmoidCurve(xRange: xRange, yRange: yRange, segments: segments);
      final normalizedPath = curve.getNormalizedPath(size, Offset(0.0, 0.0));

      expect(normalizedPath.length, segments + 1);

      {
        final expectedOffset = normalizePoint(curve.pathOfPoints.first, size, xRange, yRange);
        expect(normalizedPath.first.dx, closeTo(expectedOffset.dx, 0.0001));
        expect(normalizedPath.first.dy, closeTo(expectedOffset.dy, 0.0001));
      }
      {
        final midIndex= (segments / 2).toInt();
        final expectedOffset = normalizePoint(curve.pathOfPoints[midIndex], size, xRange, yRange);
        expect(normalizedPath[midIndex].dx, closeTo(expectedOffset.dx, 0.0001));
        expect(normalizedPath[midIndex].dy, closeTo(expectedOffset.dy, 0.0001));
      }
      {
        final expectedOffset = normalizePoint(curve.pathOfPoints.last, size, xRange, yRange);
        expect(normalizedPath.last.dx, closeTo(expectedOffset.dx, 0.0001));
        expect(normalizedPath.last.dy, closeTo(expectedOffset.dy, 0.0001));
      }
    });
  });
}
