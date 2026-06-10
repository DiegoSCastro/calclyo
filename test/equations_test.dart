import 'package:calclyo/src/calculators/equations/equations.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('equationsDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(equationsDefinition.id, 'equations');
      expect(equationsDefinition.route, '/equations');
      expect(equationsDefinition.name, isNotEmpty);
    });
  });

  group('equationsDefinition.compute', () {
    final compute = equationsDefinition.compute;

    test('solves linear ax + b = c', () async {
      final result = await compute({
        'a': '2',
        'b': '3',
        'c': '7',
        'kind': 'Linear (ax + b = c)',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(2.0, 1e-09));
    });

    test('fails when a is zero in linear mode', () async {
      final result = await compute({
        'a': '0',
        'b': '1',
        'c': '2',
        'kind': 'Linear (ax + b = c)',
      }).run();
      expect(result.isLeft(), isTrue,
          reason: 'expected failure for a=0, b=1, c=2, kind=Linear (ax + b = c)');
    });

  });
}
