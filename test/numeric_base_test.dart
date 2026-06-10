import 'package:calclyo/src/calculators/numeric_base/numeric_base.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('numericBaseDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(numericBaseDefinition.id, 'numeric_base');
      expect(numericBaseDefinition.route, '/numeric-base');
      expect(numericBaseDefinition.name, isNotEmpty);
    });
  });

  group('numericBaseDefinition.compute', () {
    final compute = numericBaseDefinition.compute;

    test('255 dec → ff hex', () async {
      final result = await compute({'v': '255', 'dir': 'Dec → Hex'}).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, 255.0);
    });

    test('ff hex → 255 dec', () async {
      final result = await compute({'v': 'FF', 'dir': 'Hex → Dec'}).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, 255.0);
    });
  });
}
