import 'package:calclyo/src/calculators/angle/angle.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('angleDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(angleDefinition.id, 'angle');
      expect(angleDefinition.route, '/angle');
      expect(angleDefinition.name, isNotEmpty);
    });
  });

  group('angleDefinition.compute', () {
    final compute = angleDefinition.compute;

    test('180° = 180°', () async {
      final result = await compute({'v': '180', 'unit': 'deg'}).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(180.0, 1e-06));
    });

    test('π rad = 180°', () async {
      final result = await compute({'v': '3.14159265', 'unit': 'rad'}).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(180.0, 0.001));
    });
  });
}
