import 'package:calclyo/src/calculators/proportion/proportion.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('proportionDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(proportionDefinition.id, 'proportion');
      expect(proportionDefinition.route, '/proportion');
      expect(proportionDefinition.name, isNotEmpty);
    });
  });

  group('proportionDefinition.compute', () {
    final compute = proportionDefinition.compute;

    test('solves the proportion D = B*C/A', () async {
      final result = await compute({
        'a': '3',
        'b': '12',
        'c': '5',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(20.0, 1e-09));
    });

    test('fails when a is zero', () async {
      final result = await compute({
        'a': '0',
        'b': '12',
        'c': '5',
      }).run();
      expect(result.isLeft(), isTrue,
          reason: 'expected failure for a=0, b=12, c=5');
    });

  });
}
