import 'package:calclyo/src/calculators/speed/speed.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('speedDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(speedDefinition.id, 'speed');
      expect(speedDefinition.route, '/speed');
      expect(speedDefinition.name, isNotEmpty);
    });
  });

  group('speedDefinition.compute', () {
    final compute = speedDefinition.compute;

    test('60 km/h ~ 16.667 m/s', () async {
      final result = await compute({
        'v': '60',
        'unit': 'km/h',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(16.6666666, 0.001));
    });

    test('1 mph ~ 0.447 m/s', () async {
      final result = await compute({
        'v': '1',
        'unit': 'mph',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(0.44704, 1e-06));
    });

  });
}
