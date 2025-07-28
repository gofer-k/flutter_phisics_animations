import 'dart:math' as math;
import 'dart:ui';

import 'package:first_flutter_app/pipe_path.dart';

class SigmoidCurve extends PipePath {
  PathOffsets _pathOfPoints = PathOffsets.empty();
  @override
  PathOffsets get pathOfPoints => _pathOfPoints;

  double scale = 1.0;

  SigmoidCurve({required super.xRange, required super.yRange, required super.segments}) {
    generate();
  }

  @override
  void generate() {
    final double xLength = xRange.end - xRange.begin;

    _pathOfPoints = List.generate(segments + 1, (i) {
      final double x = (i / segments) * xLength + xRange.begin;
      final double y = 1.0 / (1.0 + math.exp(-x));
      return Offset(x, y);
    });

    _length = 0.0;
    for (int i = 0; i < _pathOfPoints.length - 1; i++) {
      final double dx = _pathOfPoints[i + 1].dx - _pathOfPoints[i].dx;
      final double dy = _pathOfPoints[i + 1].dy - _pathOfPoints[i].dy;
      _length += math.sqrt(dx * dx + dy * dy);
    }
  }

  PathOffsets getNormalizedPath(Size size) {
    PathOffsets normalizedPath = PathOffsets.empty(growable: true);
    final xLength = xRange.end - xRange.begin;

    for (Offset point in pathOfPoints) {
      // Normalize x to canvas width
      double dx = (point.dx - xRange.begin) / xLength * size.width;

      // Normalize y (inverted for canvas coordinate system)
      double dy = size.height * (1 - point.dy);

      normalizedPath.add(Offset(dx, dy));
    }
    return normalizedPath;
  }

  double _length = 0.0;
  @override
  double get length => _length;
}