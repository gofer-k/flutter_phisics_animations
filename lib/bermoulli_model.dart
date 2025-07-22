
import 'package:first_flutter_app/area_path.dart';
import 'package:first_flutter_app/pipe_path.dart';
import 'package:flutter/foundation.dart';

import 'BermoulliModelTypes.dart';
import 'density.dart';

class BermoulliModel {
  static final Length _length = Length(begin: 0.0, end: 10.0); // [m]
  get length => _length;

  Area area = Area(begin: 0.3, end: 0.7);
  LevelFromGround levelGround = LevelFromGround(begin: 0.0, end: 0.5);
  SpeedFlow beginSpeed = SpeedFlow(begin: 0.0, end: 20.0);
  Pressure beginPressure = Pressure(begin: 990.0, end: 1500.0);
  Density density = Density.water; // [kg/m^3];
  final PipePath path;
  late AreaPath areaPath;

  BermoulliModel({
    required this.area,
    required this.levelGround,
    required this.beginSpeed,
    required this.beginPressure,
    required this.density,
    required this.path}) {
    _generate();
  }

  double currentSpeedFlow(int indexPath) {
    if (indexPath >= 0 && indexPath < areaPath.areaInPath.length) {
      // Current speed a stationary flow of liquid or gas in a pipe
      // V1 / V2 = S1 / S2;
      return beginSpeed.value * areaPath.areaInPath.first /
          areaPath.areaInPath.last;
    }
    if (kDebugMode) {
      print("Incorrect indexPath: $indexPath");
    }
    return 0.0;
  }

  void changeArea(Area newArea) {
    area = newArea;
    _generate();
  }

  void changeLevelGround(LevelFromGround levelFromGround) {
    levelFromGround = levelFromGround;
    _generate();
  }

  void _generate() {
    areaPath = AreaPath(pipe: path, areaConstrains: area);
  }

  void regenerateAll(Area newArea,
      LevelFromGround newLevelGround,
      SpeedFlow newBeginSpeed,
      Pressure newBeginPressure) {
    area = newArea;
    levelGround = newLevelGround;
    beginSpeed = newBeginSpeed;
    beginPressure = newBeginPressure;
    _generate();
  }
}
