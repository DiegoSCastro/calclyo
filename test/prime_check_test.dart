import 'package:calclyo/src/calculators/prime_check/prime_check.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('primeCheckDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(primeCheckDefinition.id, 'prime_check');
      expect(primeCheckDefinition.route, '/prime-check');
      expect(primeCheckDefinition.name, isNotEmpty);
    });
  });

  group('primeCheckDefinition.compute', () {
    final compute = primeCheckDefinition.compute;

    test('17 is prime', () async {
      final result = await compute({
        'n': '17',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, 1.0);
    });

    test('18 is not prime', () async {
      final result = await compute({
        'n': '18',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, 0.0);
    });

  });
}
