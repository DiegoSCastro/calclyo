import 'package:calclyo/src/calculators/roman_numerals/roman_numerals.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('romanNumeralsDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(romanNumeralsDefinition.id, 'roman_numerals');
      expect(romanNumeralsDefinition.route, '/roman-numerals');
      expect(romanNumeralsDefinition.name, isNotEmpty);
    });
  });

  group('romanNumeralsDefinition.compute', () {
    final compute = romanNumeralsDefinition.compute;

    test('1994 → MCMXCIV', () async {
      final result = await compute({
        'v': '1994',
        'dir': 'Number → Roman',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, 1994.0);
    });

    test('MCMXCIV → 1994', () async {
      final result = await compute({
        'v': 'MCMXCIV',
        'dir': 'Roman → Number',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, 1994.0);
    });
  });
}
