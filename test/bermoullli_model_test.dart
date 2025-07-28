import 'package:first_flutter_app/bermoulli_model_types.dart';
import 'package:first_flutter_app/bermoulli_model.dart';
import 'package:first_flutter_app/density.dart';
import 'package:first_flutter_app/pipe_path.dart';
import 'package:first_flutter_app/sigmoid_pipe_path.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final modelInitial = BermoulliModel(
      area: Area(begin: 0.3, end: 0.7),
      levelGround: LevelFromGround(begin: 0.0, end: 0.5),
      beginSpeed: SpeedFlow(begin: 0.0, end: 20.0),
      beginPressure: Pressure(begin: 990.0, end: 1500.0),
      density: Density.water, // [kg/m^3];
      path: SigmoidCurve(xRange: Range(begin: 0.0, end: 10.0), yRange: Range(begin: 0.0, end: 10.0), segments: 10)
  );

  group('BermoulliModel Tests', () {
    test("should correct initialize model", () {
      expect(modelInitial.area.value, 0.3);
      expect(modelInitial.levelGround.value, 0.0);
      expect(modelInitial.beginSpeed.value, 0.0);
      expect(modelInitial.beginPressure.value, 990.0);
      expect(modelInitial.density, Density.water);
      expect(modelInitial.areaPath.areaInPath.length, greaterThan(0.0));
      expect(modelInitial.areaPath.areaInPath.length, modelInitial.path.pathOfPoints.length);
    });

    group("Changes Speed Tests", (){
      test("should correct calculate current speed at end", () {
        final lastIndex = modelInitial.areaPath.areaInPath.length - 1;
        final currSpeed = modelInitial.currentSpeedFlow(lastIndex);
        final expectedSpeed = modelInitial.beginSpeed.value * modelInitial.areaPath.areaInPath.first / modelInitial.areaPath.areaInPath.last;
        expect(currSpeed, equals(expectedSpeed));
      });

      test("should calculate speed though traverse path", () {
        checkValues(BermoulliModel model, bool isIncreasing) {
          var prevSpeed = model.currentSpeedFlow(0);

          for (int i = 1; i < model.areaPath.areaInPath.length; i++) {
            var currentSpeed = model.currentSpeedFlow(i);
            if (isIncreasing) {
              expect(currentSpeed, greaterThanOrEqualTo(prevSpeed));
            } else {
              expect(currentSpeed, lessThanOrEqualTo(prevSpeed));
            }
            prevSpeed = currentSpeed;
          }
        }
        checkValues(modelInitial, modelInitial.areaPath.areaInPath.first < modelInitial.areaPath.areaInPath.last);
      });

      test("should correct calculate current speed after begin speed change", () {
        // TODO: add test
      });
    });

    group("Changes area path Test", () {
      test("should correct generate area path after area ends change", () {
        // TODO: add test
      });

      test("should correct generate area path after level ground ends change", () {
        // TODO: add test
      });

      test("should correct generate area path after level ground ends change", () {
        // TODO: add test
      });
    });

    group("Changes pressure Test", ()
    {
      test("should correct calculate pressure at end", () {
        // TODO: add test
      });

      test("should correct calculate current pressure", () {
        // TODO: add test
      });
    });
  });
}