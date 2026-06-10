import 'package:calclyo/src/calculators/tip/tip.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tipDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(tipDefinition.id, 'tip');
      expect(tipDefinition.route, '/tip');
      expect(tipDefinition.name, isNotEmpty);
    });
  });

  group('tipDefinition.compute', () {
    final compute = tipDefinition.compute;

    test('\\\$50 at 18% → \\\$9 tip', () async {
      final result = await compute({
        'bill': '50',
        'pct': '18',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(9.0, 1e-06));
    });

    test('\\\$100 at 20% → \\\$20 tip', () async {
      final result = await compute({
        'bill': '100',
        'pct': '20',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(20.0, 1e-06));
    });

  });
}
