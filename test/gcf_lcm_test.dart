import 'package:calclyo/src/calculators/gcf_lcm/gcf_lcm.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('gcfLcmDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(gcfLcmDefinition.id, 'gcf_lcm');
      expect(gcfLcmDefinition.route, '/gcf-lcm');
      expect(gcfLcmDefinition.name, isNotEmpty);
    });
  });

  group('gcfLcmDefinition.compute', () {
    final compute = gcfLcmDefinition.compute;

    test('computes GCD(12, 18) = 6', () async {
      final result = await compute({'a': '12', 'b': '18'}).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(6.0, 1e-09));
    });

    test('computes GCD(100, 75) = 25', () async {
      final result = await compute({'a': '100', 'b': '75'}).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(25.0, 1e-09));
    });
  });
}
