import 'package:first_flutter_app/pipe_path.dart';
import 'package:flutter_test/flutter_test.dart';

// Assuming your SigmoidCurve class is in this path
// Adjust the import path according to your project structure.
import 'package:first_flutter_app/sigmoid_pipe_path.dart';

import 'dart:math' as math;

void main() {
  double sigmoid(double x, double xScale) {
    return 1.0 / (1.0 + math.exp(-x * xScale));
  }

  double average(Range range) {
     return (range.begin + range.end) / 2.0;
  }

  group('SigmoidCurve Tests', () {
    test('generate should produce correct number of points', () {
      final xRange = Range(begin: -1.0, end: 1.0);
      final yRange = Range(begin: 0.0, end: 100.0);
      final int segments = 10;

      final curve = SigmoidCurve(xRange, yRange, segments);
      expect(curve.pathOfPoints.length, equals(segments + 1));
    });

    test('generate should correctly calculate first and last points', () {
      final int segments = 10;
      final xRange = Range(begin: -1.0, end: 1.0);
      final yRange = Range(begin: 0.0, end: 100.0); // yMid will be 50
      final curve = SigmoidCurve(xRange, yRange, segments);

      final points = curve.pathOfPoints;

      final double scaleNorm = 20.0;
      final double expectedFirstX = ((0 / segments) * (xRange.end - xRange.begin) + xRange.begin) * scaleNorm;

      final ySigmoidFirst = sigmoid(expectedFirstX, 1.0);
      final yMid = average(yRange);
      final expectedFirstY = (ySigmoidFirst - 0.5) * yMid;

      expect(points.first.dx, closeTo(expectedFirstX, 0.0001));
      expect(points.first.dy, closeTo(expectedFirstY, 0.0001));

      final expectedLastX = (((points.length - 1) / segments) * (xRange.end - xRange.begin) + xRange.begin) * scaleNorm;
      final ySigmoidLast = sigmoid(expectedLastX, 1.0);

      final expectedLastY = (ySigmoidLast - 0.5) * yMid;

      expect(points.last.dx, closeTo(expectedLastX, 0.0001));
      expect(points.last.dy, closeTo(expectedLastY, 0.0001));
    });

    test('generate should correctly calculate midpoint (xNorm = 0)', () {
      // For midpoint, xRange should be symmetric around 0 for xNorm to be 0 at i=segments/2
      final int segments = 10;
      final xRange = Range(begin: -1.0, end: 1.0); // xLength = 2
      final yRange = Range(begin: 0.0, end: 200.0); // yMid = 100
      final curve = SigmoidCurve(xRange, yRange, segments); // Constructor segments is not used by generate

      final points = curve.pathOfPoints;
      // The internal segments is 100. Midpoint index is 50.
      final midPoint = points[(segments / 2).toInt()];

      // At i = 50:
      // xNorm = (50 / 100) * 2.0 + (-1.0) = 0.5 * 2.0 - 1.0 = 1.0 - 1.0 = 0.0
      // y_sigmoid = 1.0 / (1.0 + math.exp(-0.0 * 20)) = 1.0 / (1.0 + 1.0) = 0.5
      // yInViewportSpace = (0.5 - 0.5) * yMid = 0.0 * 100.0 = 0.0
      final expectedMidX = 0.0;
      final expectedMidY = 0.0;

      expect(midPoint.dx, closeTo(expectedMidX, 0.0001));
      expect(midPoint.dy, closeTo(expectedMidY, 0.0001));
    });

    test('generate should scale y values correctly based on yRange', () {
      final int segments = 10;
      final yRange1 = Range(begin: 0.0, end: 100.0);
      final yMid1 = average(yRange1);

      final yRange2 = Range(begin: 0.0, end: 200.0);
      final yMid2 = average(yRange2);

      // xNorm will be 0 for all points because xRange.begin == xRange.end
      // y_sigmoid = 1.0 / (1.0 + math.exp(-0.0 * 20)) = 0.5
      // For curve1: yInViewportSpace = (0.5 - 0.5) * 50.0 = 0.0
      // For curve2: yInViewportSpace = (0.5 - 0.5) * 100.0 = 0.0
      // This test highlights that if y_sigmoid is 0.5, yInViewportSpace is always 0 before yMid scaling.
      // Let's pick a point where y_sigmoid is not 0.5. For that xNorm should not be 0.
      // Using a different xRange for this specific test might be better.

      final xRangeForScaling = Range(begin: 0.1, end: 0.1); // xNorm = 0.1
      final double scaleNorm = 20.0;
      final curveScaling1 = SigmoidCurve(xRangeForScaling, yRange1, segments); // yMid = 50
      final curveScaling2 = SigmoidCurve(xRangeForScaling, yRange2, segments); // yMid = 100

      // For xNorm = 0.1:
      // y_sigmoid = 1.0 / (1.0 + math.exp(-0.1 * 20)) = 1.0 / (1.0 + math.exp(-2))
      final ySigmoid = sigmoid(xRangeForScaling.begin, scaleNorm);
      final expectedY1 = (ySigmoid - 0.5) * yMid1;
      final expectedY2 = (ySigmoid - 0.5) * yMid2;

      expect(curveScaling1.pathOfPoints.first.dy, closeTo(expectedY1, 0.0001));
      expect(curveScaling2.pathOfPoints.first.dy, closeTo(expectedY2, 0.0001));
      // And because yMid scaling is linear:
      if (expectedY1 != 0) { // Avoid division by zero if ySigmoid happens to be 0.5
        expect(curveScaling2.pathOfPoints.first.dy / curveScaling1.pathOfPoints.first.dy,
            closeTo(2.0, 0.0001));
      } else {
        expect(curveScaling1.pathOfPoints.first.dy, closeTo(0.0, 0.0001));
        expect(curveScaling2.pathOfPoints.first.dy, closeTo(0.0, 0.0001));
      }
    });

    test('generate should handle xRange.begin == xRange.end', () {
      final int segments = 10;
      final xRange = Range(begin: 0.5, end: 0.5); // xLength = 0
      final yRange = Range(begin: 0.0, end: 100.0); // yMid = 50
      final curve = SigmoidCurve(xRange, yRange, segments);

      final points = curve.pathOfPoints;
      expect(points.length, segments + 1);

      // For all points:
      // xNorm = (i / 100) * 0 + 0.5 = 0.5
      // y_sigmoid = 1.0 / (1.0 + math.exp(-0.5 * 20)) = 1.0 / (1.0 + math.exp(-10))
      // yInViewportSpace = (y_sigmoid - 0.5) * 50.0
      final scaleNorm = 20.0;
      final expectedX = xRange.begin * scaleNorm;
      final ySigmoid = sigmoid(expectedX, 1.0);
      final yMid = average(yRange);
      final expectedY = (ySigmoid - 0.5) * yMid;

      for (var point in points) {
        expect(point.dx, closeTo(expectedX, 0.0001));
        expect(point.dy, closeTo(expectedY, 0.0001));
      }
    });

    test('generate should handle yRange.begin == yRange.end', () {
      final int segments = 10;
      final xRange = Range(begin: -1.0, end: 1.0);
      final yRange = Range(begin: 50.0, end: 50.0); // yMid will be 50.0
      final curve = SigmoidCurve(xRange, yRange, segments);

      final points = curve.pathOfPoints;
      final scaleNorm = 20.0;
      // xNorm for first point = -1.0
      final ySigmoidFirst = sigmoid(xRange.begin, scaleNorm);
      // yInViewportSpace = (ySigmoidFirst - 0.5) * 50.0
      final yMid = average(yRange);
      final expectedFirstY = (ySigmoidFirst - 0.5) * yMid;

      expect(points.first.dy, closeTo(expectedFirstY, 0.0001));

      // yInViewportSpace = (0.5 - 0.5) * 50.0 = 0.0
      final ySigmoidLast = 1.0 / (1.0 + math.exp(-xRange.end * scaleNorm));
      final expectedLastY = (ySigmoidLast - 0.5) * yMid;
      expect(points.last.dy, closeTo(expectedLastY, 0.0001));
    });
  // // It's good practice to also test the LimitRange class if you haven't already
  // // to ensure its behavior is correct, as SigmoidCurve depends on it.
  // group('LimitRange Tests (Example - Assuming you have this class)', () {
  //   test('LimitRange basic properties', () {
  //     final range = Range(begin: 1.0, end: 5.0);
  //     expect(range.begin, 1.0);
  //     expect(range.end, 5.0);
  //   });
  //
  //   // Add tests for length or any other methods if they exist in LimitRange
  //   test('LimitRange length calculation', () {
  //     final range = Range(begin: -2.0, end: 3.0);
  //     // Assuming LimitRange has a length method like: T length() => (end - begin).abs();
  //     // And T is constrained to num
  //     // expect(range.length(), 5.0);
  //   });
  });
}
