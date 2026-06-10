import 'package:calclyo/src/calculators/fuel/fuel.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fuelDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(fuelDefinition.id, 'fuel');
      expect(fuelDefinition.route, '/fuel');
      expect(fuelDefinition.name, isNotEmpty);
    });
  });

  group('fuelDefinition.compute', () {
    final compute = fuelDefinition.compute;

    test('10 km/L round-trip', () async {
      final result = await compute({
        'v': '10',
        'unit': 'km/L',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(10.0, 1e-06));
    });

    test('L/100km = 8 → 12.5 km/L', () async {
      final result = await compute({
        'v': '8',
        'unit': 'L/100km',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(12.5, 1e-06));
    });

  });
}
