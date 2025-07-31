import 'dart:ui';

import 'package:first_flutter_app/limit_range.dart';

typedef PathOffsets = List<Offset>; // Collection of point from given function
typedef PathInMeters = List<double>;        // Collection distances along the path in meters. Tight together with PathOffsetsInMeters
typedef Range = LimitRange<double>;

abstract class PipePath {
  final Range xRange;
  final Range yRange;
  final int segments;

  double get length;

  PathOffsets get pathOfPoints;
  
  PipePath({required this.xRange, required this.yRange, required this.segments});

  bool isEmpty() {
    return pathOfPoints.isEmpty;
  }

  void generate();

  static double normalizeValue(double current, double begin, double end, Range domainRange) {
    final yNorm = (current - begin) / (end - begin);
    return domainRange.begin + (domainRange.end - domainRange.begin) * yNorm;
  }

  PathOffsets getNormalizedPath(Size size, Offset origin);
}