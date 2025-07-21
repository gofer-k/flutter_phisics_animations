import 'dart:ui';

import 'package:first_flutter_app/limit_range.dart';

typedef PathOffsetsInMeters = List<Offset>; // Collection of point from given function
typedef PathInMeters = List<double>;        // Collection distances along the path in meters. Tight together with PathOffsetsInMeters
typedef Range = LimitRange<double>;

abstract class PipePath {
  final Range _xRange;
  Range get xRange => _xRange;

  final Range _yRange;
  Range get yRange => _yRange;

  final int _segments;
  int get segments => _segments;

  double get length;

  PathOffsetsInMeters get pathOfPoints;
  
  PipePath(this._xRange, this._yRange, this._segments);

  bool isEmpty() {
    return pathOfPoints.isEmpty;
  }

  void generate();
}