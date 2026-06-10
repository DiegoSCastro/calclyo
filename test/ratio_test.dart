import 'package:calclyo/src/calculators/ratio/ratio.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ratioDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(ratioDefinition.id, 'ratio');
      expect(ratioDefinition.route, '/ratio');
      expect(ratioDefinition.name, isNotEmpty);
    });
  });

  group('ratioDefinition.compute', () {
    final compute = ratioDefinition.compute;

    test('simplifies 12:18 to 2:3', () async {
      final result = await compute({'a': '12', 'b': '18'}).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(0.6666666666666666, 1e-09));
    });

    test('simplifies 8:8 to 1:1', () async {
      final result = await compute({'a': '8', 'b': '8'}).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(1.0, 1e-09));
    });
  });
}
