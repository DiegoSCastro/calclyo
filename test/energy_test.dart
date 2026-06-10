import 'package:calclyo/src/calculators/energy/energy.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('energyDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(energyDefinition.id, 'energy');
      expect(energyDefinition.route, '/energy');
      expect(energyDefinition.name, isNotEmpty);
    });
  });

  group('energyDefinition.compute', () {
    final compute = energyDefinition.compute;

    test('1 kJ = 1000 J', () async {
      final result = await compute({'v': '1', 'unit': 'kJ'}).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(1000.0, 1e-06));
    });

    test('1 kcal = 4184 J', () async {
      final result = await compute({'v': '1', 'unit': 'kcal'}).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(4184.0, 1e-06));
    });
  });
}
