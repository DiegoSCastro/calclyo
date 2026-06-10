import 'package:calclyo/src/calculators/sales_tax/sales_tax.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('salesTaxDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(salesTaxDefinition.id, 'sales_tax');
      expect(salesTaxDefinition.route, '/sales-tax');
      expect(salesTaxDefinition.name, isNotEmpty);
    });
  });

  group('salesTaxDefinition.compute', () {
    final compute = salesTaxDefinition.compute;

    test('\\\$100 at 8.5% → \\\$108.50', () async {
      final result = await compute({
        'price': '100',
        'rate': '8.5',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(108.5, 1e-06));
    });

    test('\\\$0 at 10% → 0', () async {
      final result = await compute({
        'price': '0',
        'rate': '10',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(0.0, 1e-06));
    });

  });
}
