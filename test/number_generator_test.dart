import 'package:calclyo/src/calculators/number_generator/number_generator.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('numberGeneratorDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(numberGeneratorDefinition.id, 'number_generator');
      expect(numberGeneratorDefinition.route, '/number-generator');
      expect(numberGeneratorDefinition.name, isNotEmpty);
    });
  });

  group('numberGeneratorDefinition.compute', () {
    final compute = numberGeneratorDefinition.compute;

    test('arithmetic sequence step=2', () async {
      final result = await compute({
        'min': '1',
        'max': '10',
        'first': '1',
        'step': '2',
        'count': '4',
        'kind': 'Arithmetic sequence',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(7.0, 1e-09));
    });

    test('fails when count is too large', () async {
      final result = await compute({
        'min': '1',
        'max': '10',
        'first': '1',
        'step': '2',
        'count': '100',
        'kind': 'Arithmetic sequence',
      }).run();
      expect(result.isLeft(), isTrue,
          reason: 'expected failure for min=1, max=10, first=1, step=2, count=100, kind=Arithmetic sequence');
    });

  });
}
