import 'limit_range.dart';

typedef Area = LimitRange<double>;  // [m]
typedef LevelFromGround = LimitRange<double>; // [m]
typedef SpeedFlow = LimitRange<double>;  // [m /2]
typedef Pressure = LimitRange<double>;  // [kPa]
typedef Length = LimitRange<double>;    // [m]
typedef Time = LimitRange<double>;      // [s]