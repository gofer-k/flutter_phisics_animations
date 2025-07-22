import 'package:first_flutter_app/pipe_path.dart';

import 'BermoulliModelTypes.dart';

class AreaPath {
  PathInMeters _areaInPath = PathInMeters.empty();
  PathInMeters get areaInPath => _areaInPath;

  AreaPath({required Area areaConstrains, required PipePath pipe}) {
    if (pipe.pathOfPoints.isEmpty) {
      throw ArgumentError("PipePath is empty");
    }

    // _areaInPath.add(areaConstrains.begin);
    _areaInPath = List.generate(pipe.segments + 1, (i) {
      double t = i / pipe.segments; // Parameter along the current length
      return areaConstrains.begin + t * (areaConstrains.end - areaConstrains.begin);
    });
  }
}