import 'package:calclyo/src/calculators/acceleration/acceleration.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('accelerationDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(accelerationDefinition.id, 'acceleration');
      expect(accelerationDefinition.route, '/acceleration');
      expect(accelerationDefinition.name, isNotEmpty);
    });
  });

  group('accelerationDefinition.compute', () {
    final compute = accelerationDefinition.compute;

    test('1 g = 9.80665 m/s²', () async {
      final result = await compute({
        'v': '1',
        'unit': 'g',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(9.80665, 0.001));
    });

    test('1 ft/s² = 0.3048 m/s²', () async {
      final result = await compute({
        'v': '1',
        'unit': 'ft/s²',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(0.3048, 1e-06));
    });

  });
}
