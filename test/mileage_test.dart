import 'package:calclyo/src/calculators/mileage/mileage.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mileageDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(mileageDefinition.id, 'mileage');
      expect(mileageDefinition.route, '/mileage');
      expect(mileageDefinition.name, isNotEmpty);
    });
  });

  group('mileageDefinition.compute', () {
    final compute = mileageDefinition.compute;

    test('500 km / 40 L = 12.5 km/L', () async {
      final result = await compute({
        'km': '500',
        'l': '40',
        'price': '1.50',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(12.5, 1e-06));
    });

    test('fails when fuel = 0', () async {
      final result = await compute({
        'km': '500',
        'l': '0',
        'price': '1.50',
      }).run();
      expect(
        result.isLeft(),
        isTrue,
        reason: 'expected failure for km=500, l=0, price=1.50',
      );
    });
  });
}
