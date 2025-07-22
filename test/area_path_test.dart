import 'package:first_flutter_app/BermoulliModelTypes.dart';
import 'package:first_flutter_app/area_path.dart';
import 'package:first_flutter_app/pipe_path.dart';
import 'package:first_flutter_app/sigmoid_pipe_path.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final int segments = 10;
  final xRange = Range(begin: 0.0, end: 10.0); // [m]
  final yRange = Range(begin: 0.0, end: 10.0);
  final path = SigmoidCurve(xRange, yRange, segments);

  group('AreaPath Tests', () {
    test('generate should produce correct number of points', () {
      final areaPath = AreaPath(Area(begin: 1.0, end: 1.0), path);
      expect(areaPath.areaInPath.length, equals(path.pathOfPoints.length));
    });

    test('generate should correctly calculate first and last points', () {
      final Area constrainedArea = Area(begin: 2.0, end: 10.0);
      final areaPath = AreaPath(constrainedArea, path);
      expect(constrainedArea.begin, equals(areaPath.areaInPath.first));
      expect(constrainedArea.end, equals(areaPath.areaInPath.last));
    });

    test('generate should correctly calculate mid point area', () {
      final Area constrainedArea = Area(begin: 10.0, end: 20.0);
      final expectedMidArea = (constrainedArea.begin + constrainedArea.end) / 2.0;
      final areaPath = AreaPath(constrainedArea, path);

      final midIndex = areaPath.areaInPath.length ~/ 2;
      final calculatedMidArea = areaPath.areaInPath[midIndex];
      expect(expectedMidArea, equals(calculatedMidArea));
    });

    test('generate should correctly calculate all points', () {
      checkValues(AreaPath areaPath, bool isIncreasing) {
        var prevArea = areaPath.areaInPath.first;
        for (int i = 1; i < areaPath.areaInPath.length; i++) {
          var currentArea = areaPath.areaInPath[i];
          if (isIncreasing) {
            expect(currentArea, greaterThanOrEqualTo(prevArea));
          } else {
            expect(currentArea, lessThanOrEqualTo(prevArea));
          }
          prevArea = currentArea;
        }
      }

      final isIncreasing = true;
      final Area increasingAreas = Area(begin: 10.0, end: 20.0);
      checkValues(AreaPath(increasingAreas, path), isIncreasing);

      final Area decreasingAreas = Area(begin: 20.0, end: 10.0);
      checkValues(AreaPath(decreasingAreas, path), !isIncreasing);
    });
  });
}