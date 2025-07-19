import 'dart:math' as math;
import 'dart:ui';

import 'package:first_flutter_app/pipe_path.dart';

class SigmoidCurve extends PipePath {

  PathInMeters _pathInMeters = PathInMeters.empty();
  @override
  PathInMeters get pathInMeters => _pathInMeters;

  PathOffsetsInMeters _pathOffsetsInMeters = PathOffsetsInMeters.empty();
  @override
  PathOffsetsInMeters get pathOffsetsInMeters => _pathOffsetsInMeters;

  SigmoidCurve(super.xRange, super.yRange, super.segments) {
    generate();
  }

  @override
  void generate() {
    final double yMid = (yRange.begin + yRange.end) / 2.0;
    final double xLength = xRange.end - xRange.begin;
    final double scaleNorm = 20.0;

    _pathOffsetsInMeters = List.generate(segments + 1, (i) {
      final double xNorm = ((i / segments) * xLength + xRange.begin) * scaleNorm;
      final double y = 1.0 / (1.0 + math.exp(-xNorm));
      // final double yInViewportSpace = (y - yMid) * yMid;
      final double yInViewportSpace = (y - 0.5) * yMid;
      // Translate to viewport center
      return Offset(xNorm, yInViewportSpace);
    });
  }
}