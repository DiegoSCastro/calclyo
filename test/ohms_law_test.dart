import 'package:calclyo/src/calculators/ohms_law/ohms_law.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ohmsLawDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(ohmsLawDefinition.id, 'ohms_law');
      expect(ohmsLawDefinition.route, '/ohms-law');
      expect(ohmsLawDefinition.name, isNotEmpty);
    });
  });

  group('ohmsLawDefinition.compute', () {
    final compute = ohmsLawDefinition.compute;

    test('V = I × R: 2 × 6 = 12', () async {
      final result = await compute({
        'v': '12',
        'i': '2',
        'r': '6',
        'mode': 'V = I × R',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(12.0, 1e-09));
    });

    test('I = V / R: 12 / 6 = 2', () async {
      final result = await compute({
        'v': '12',
        'i': '0',
        'r': '6',
        'mode': 'I = V / R',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(2.0, 1e-09));
    });
  });
}
