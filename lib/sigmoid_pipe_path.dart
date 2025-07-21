import 'dart:math' as math;
import 'dart:ui';

import 'package:first_flutter_app/pipe_path.dart';

class SigmoidCurve extends PipePath {
  PathOffsetsInMeters _pathOfPoints = PathOffsetsInMeters.empty();
  @override
  PathOffsetsInMeters get pathOfPoints => _pathOfPoints;

  SigmoidCurve(super.xRange, super.yRange, super.segments) {
    generate();
  }

  @override
  void generate() {
    final double yMid = (yRange.begin + yRange.end) / 2.0;
    final double xLength = xRange.end - xRange.begin;
    final double scaleNorm = 20.0;

    _pathOfPoints = List.generate(segments + 1, (i) {
      final double xNorm = ((i / segments) * xLength + xRange.begin) * scaleNorm;
      final double y = 1.0 / (1.0 + math.exp(-xNorm));
      // final double yInViewportSpace = (y - yMid) * yMid;
      final double yInViewportSpace = (y - 0.5) * yMid;
      // Translate to viewport center
      return Offset(xNorm, yInViewportSpace);
    });

    _length = 0.0;
    for (int i = 0; i < _pathOfPoints.length - 1; i++) {
      final double dx = _pathOfPoints[i + 1].dx - _pathOfPoints[i].dx;
      final double dy = _pathOfPoints[i + 1].dy - _pathOfPoints[i].dy;
      _length += math.sqrt(dx * dx + dy * dy);
    }
  }

  double _length = 0.0;
  @override
  double get length => _length;
}