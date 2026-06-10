import 'package:calclyo/src/calculators/weight/weight.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('weightDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(weightDefinition.id, 'weight');
      expect(weightDefinition.route, '/weight');
      expect(weightDefinition.name, isNotEmpty);
    });
  });

  group('weightDefinition.compute', () {
    final compute = weightDefinition.compute;

    test('1 kg = 1000 g', () async {
      final result = await compute({'v': '1', 'unit': 'kg'}).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(1000.0, 1e-06));
    });

    test('1 lb ~ 453.59 g', () async {
      final result = await compute({'v': '1', 'unit': 'lb'}).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(453.59237, 0.001));
    });
  });
}
