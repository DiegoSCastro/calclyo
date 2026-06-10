import 'package:calclyo/src/calculators/power/power.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('powerDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(powerDefinition.id, 'power');
      expect(powerDefinition.route, '/power');
      expect(powerDefinition.name, isNotEmpty);
    });
  });

  group('powerDefinition.compute', () {
    final compute = powerDefinition.compute;

    test('1 kW = 1000 W', () async {
      final result = await compute({'v': '1', 'unit': 'kW'}).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(1000.0, 1e-06));
    });

    test('1 hp ~ 745.7 W', () async {
      final result = await compute({'v': '1', 'unit': 'hp (mech)'}).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(745.7, 0.01));
    });
  });
}
