import 'package:calclyo/src/calculators/unit_price/unit_price.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('unitPriceDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(unitPriceDefinition.id, 'unit_price');
      expect(unitPriceDefinition.route, '/unit-price');
      expect(unitPriceDefinition.name, isNotEmpty);
    });
  });

  group('unitPriceDefinition.compute', () {
    final compute = unitPriceDefinition.compute;

    test(r'\$9.99 / 3 ~ 3.33', () async {
      final result = await compute({'price': '9.99', 'units': '3'}).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(3.33, 0.01));
    });

    test('fails when units = 0', () async {
      final result = await compute({'price': '10', 'units': '0'}).run();
      expect(
        result.isLeft(),
        isTrue,
        reason: 'expected failure for price=10, units=0',
      );
    });
  });
}
