import 'package:calclyo/src/calculators/caloric_burn/caloric_burn.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('caloricBurnDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(caloricBurnDefinition.id, 'caloric_burn');
      expect(caloricBurnDefinition.route, '/caloric-burn');
      expect(caloricBurnDefinition.name, isNotEmpty);
    });
  });

  group('caloricBurnDefinition.compute', () {
    final compute = caloricBurnDefinition.compute;

    test('male 30y 175/70 sedentary', () async {
      final result = await compute({
        'gender': '1',
        'age': '30',
        'h': '175',
        'w': '70',
        'act': '1',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(1900, 200));
    });

    test('female 25y 165/60 active', () async {
      final result = await compute({
        'gender': '0',
        'age': '25',
        'h': '165',
        'w': '60',
        'act': '4',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(2200, 300));
    });

  });
}
