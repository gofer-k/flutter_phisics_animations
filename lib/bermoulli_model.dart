
import 'limit_range.dart';
import "density.dart"'

class BermoulliModel {
  typedef Area = LimitRange<double>;  // [m]
  typedef LevelFromGround = LimitRange<double>; // [m]
  typedef SpeedFlow = LimitRange<double>;  // [m /2]
  typedef Pressure = LimitRange<double>;  // [kPa]
  typedef Length = LimitRange<double>;    // [m]
  typedef Time = LimitRange<double>;      // [s]

  static final Length _length = 10.0; // [m]
  get length => _length;

  Area _areaConstrains = Area(start: 0.3, end: 0.7);
  LevelFromGround _levelConstrains = LevelFromGround(start: 0.0, end: 0.5);
  SpeedFlow _speedConstrains = SpeedFlow(start: 0.0, end: 20.0);
  Pressure _pressureConstrains = Pressure(start: 990.0, end: 1500.0);
  final double _accelerationEarth = 9.81; // [m/s^2]
  final Density _density = Density.water; // [kg/m^3];
  final PipePath path;

  BermoulliModel({
    this._areaConstrains,
    this._levelConstrains,
    this._speedConstrains,
    this._pressureConstrains,
    this._density,
    required this.path});

  double currentSpeed(double time) {
    double startLength = 0.0;

  }
}