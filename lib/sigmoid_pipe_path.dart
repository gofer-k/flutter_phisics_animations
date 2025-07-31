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
    final double xLength = (xRange.end - xRange.begin).abs();

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

  @override
  PathOffsets getNormalizedPath(
    Size size,
    Offset origin) {

    if(_pathOfPoints.isEmpty) {
      return List.empty();
    }

    final xMin = xRange.begin;
    final xMax = xRange.end;
    final halfWidth = size.width / 2;
    final halfHeight = size.height / 2;

    return List.generate(_pathOfPoints.length, (i) {
        double x = ((_pathOfPoints[i].dx - xMin) / (xMax - xMin)) * size.width - halfWidth;
        final midY = (0.5 - _pathOfPoints[i].dy);
        double y = midY * halfHeight;

        // TODO: use PipePath.normalitizeValue
        return Offset(x + halfWidth, y + halfHeight);
      });
  }

  double _length = 0.0;
  @override
  double get length => _length;
}