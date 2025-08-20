
import 'package:first_flutter_app/area_path.dart';
import 'package:first_flutter_app/pipe_path.dart';
import 'package:flutter/foundation.dart';

import 'bermoulli_model_types.dart';
import 'density.dart';

class BermoulliModel {
  static final Length _length = Length(begin: 0.0, end: 10.0); // [m]
  Length get length => _length;

  Area area = Area(begin: 0.1, end: 0.7); // [m]
  LevelFromGround levelGround = LevelFromGround(begin: 0.0, end: 0.5);  // [m]
  SpeedFlow beginSpeed = SpeedFlow(begin: 0.0, end: 20.0);  // [m/s]
  Pressure beginPressure = Pressure(begin: 990.0, end: 1500.0); // [kPa]
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

  int indexPath(double relativePosition) {
    return (relativePosition * areaPath.areaInPath.length).toInt();
  }

  double currentSpeedFlow(int indexPath) {
    if (indexPath >= 0 && indexPath < areaPath.areaInPath.length) {
      // Current speed a stationary flow of liquid or gas in a pipe
      // V1 / V2 = S1 / S2;
      return beginSpeed.value * areaPath.areaInPath.first /
          areaPath.areaInPath[indexPath];
    }
    return 0.0;
  }

  double endSpeedFlow() {
    return currentSpeedFlow(areaPath.areaInPath.length - 1);
  }

  double currentLevelGround(int indexPath) {
    if (indexPath >= 0 && indexPath < areaPath.areaInPath.length) {
      final yFirst = path.pathOfPoints.first.dy;
      final yLast = path.pathOfPoints.last.dy;
      return PipePath.normalizeValue(path.pathOfPoints[indexPath].dy, yFirst, yLast, levelGround);
    }
    return 0.0;
  }

  double currentPressure(int indexPath) {
    // TODO: Fxx calculation is not correct:
    if (indexPath >= 0 && indexPath < areaPath.areaInPath.length) {
      final v1 = beginSpeed.value;
      final v2 = currentSpeedFlow(indexPath);
      final h1 = levelGround.begin;
      final h2 = currentLevelGround(indexPath);
      final p1 = beginPressure.value;
      final rho = density.value;
      final g = 9.81;
      // p1 + rho * g * h1 + rho * v1^2 / 2 = p2 + rho * g * h2 + rho * v2^2 / 2
      return p1 +
          rho * (0.5 * (v1 * v1 - v2 * v2) + g * (h1 - h2));
    }
    return 0.0;
  }

  double endPressure() {
    return currentPressure(areaPath.areaInPath.length - 1);
  }

  void changeArea(Area newArea) {
    area = newArea;
    _generate();
  }

  void changeLevelGround(LevelFromGround levelFromGround) {
    levelFromGround = levelFromGround;
    _generate();
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

  void _generate() {
    areaPath = AreaPath(pipe: path, areaConstrains: area);
  }
}