import 'package:calclyo/src/calculators/discount/discount.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('discountDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(discountDefinition.id, 'discount');
      expect(discountDefinition.route, '/discount');
      expect(discountDefinition.name, isNotEmpty);
    });
  });

  group('discountDefinition.compute', () {
    final compute = discountDefinition.compute;

    test('\\\$80 at 25% → \\\$60', () async {
      final result = await compute({
        'price': '80',
        'pct': '25',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(60.0, 1e-06));
    });

    test('\\\$100 at 0% → \\\$100', () async {
      final result = await compute({
        'price': '100',
        'pct': '0',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(100.0, 1e-06));
    });

  });
}
