import 'package:calclyo/src/calculators/body_fat/body_fat.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bodyFatDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(bodyFatDefinition.id, 'body_fat');
      expect(bodyFatDefinition.route, '/body-fat');
      expect(bodyFatDefinition.name, isNotEmpty);
    });
  });

  group('bodyFatDefinition.compute', () {
    final compute = bodyFatDefinition.compute;

    test('male 175/70/38/85', () async {
      final result = await compute({
        'gender': '1',
        'h': '175',
        'w': '70',
        'n': '38',
        'waist': '85',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(23.5, 1.0));
    });

    test('fails when waist <= neck', () async {
      final result = await compute({
        'gender': '1',
        'h': '175',
        'w': '70',
        'n': '85',
        'waist': '80',
      }).run();
      expect(
        result.isLeft(),
        isTrue,
        reason: 'expected failure for gender=1, h=175, w=70, n=85, waist=80',
      );
    });
  });
}
