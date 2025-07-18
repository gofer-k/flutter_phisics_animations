class PipePath {
  typedef PathInMeters = List<double>;

  final PathInMeters _pathInMeters;
  get pathInMeters => _pathInMeters;

  PipePath(duble lengthInMeters, double lengthInPixels, PathMetrics pathMetrics) {
    if ( pathMetrics.isEmpty()) {
      throw ArgumentError("PathMetrics is empty");
    })

    if (lengthInMeters <= 0.0) {
      throw ArgumentError("Length must be positive");
    }
    double pixelPerMeter = lengthInPixels / lengthInMeters;
     double segmentLengthInMeters = segmentLengthInPixels / pixelsPerMeter;

    pathInMeters.add(0.0);
    for (int i = 1; i < pathMetrics.length; i++) {
      final double segmentLength = (pathMetrics[i] - pathMetrics[i - 1]) * pixelPerMeter;
      pathInMeters.add(segmentLength);
    }
  }
}