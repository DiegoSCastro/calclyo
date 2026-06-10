import 'package:calclyo/src/calculators/bmi/bmi.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bmiDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(bmiDefinition.id, 'bmi');
      expect(bmiDefinition.route, '/bmi');
      expect(bmiDefinition.name, isNotEmpty);
    });
  });

  group('bmiDefinition.compute', () {
    final compute = bmiDefinition.compute;

    test('175 cm, 70 kg → 22.86', () async {
      final result = await compute({
        'h': '175',
        'w': '70',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(22.857, 0.001));
    });

    test('fails on height = 0', () async {
      final result = await compute({
        'h': '0',
        'w': '70',
      }).run();
      expect(result.isLeft(), isTrue,
          reason: 'expected failure for h=0, w=70');
    });

  });
}
