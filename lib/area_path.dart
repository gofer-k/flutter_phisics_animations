class AreaPath {
  typedef Area = double;
  typedef PathInMeters = List<Area>;

  final PathInMeters _areaInPath;
  get pathInMeters => _pathInMeters;

  AreaPath(LimitRange<Area> areaConstrains, PipePath pathMetrics) {
    if ( pathMetrics.isEmpty()) {
      throw ArgumentError("PipePath is empty");
    })

    pathInMeters.add(areaConstrains.begin);
    final double xStart = pathMetrics.first;
    final double xEnd = pathMetrics.last;

    for (int i = 1; i < pathMetrics.length; i++) {
      final double x = pathMetrics[i];
      final currArea = areaConstrains.begin
        + (x - xStart;)
        * (areaConstrains.end - areaConstrains.begin) / (xEnd - xStart);

      pathInMeters.add(currArea);
    }
  }
}