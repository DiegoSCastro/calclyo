import 'package:calclyo/src/calculators/combinations/combinations.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('combinationsDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(combinationsDefinition.id, 'combinations');
      expect(combinationsDefinition.route, '/combinations');
      expect(combinationsDefinition.name, isNotEmpty);
    });
  });

  group('combinationsDefinition.compute', () {
    final compute = combinationsDefinition.compute;

    test('C(10, 3) = 120', () async {
      final result = await compute({
        'n': '10',
        'r': '3',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(120.0, 1e-09));
    });

    test('C(5, 0) = 1', () async {
      final result = await compute({
        'n': '5',
        'r': '0',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(1.0, 1e-09));
    });

  });
}
