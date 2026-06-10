import 'package:calclyo/src/calculators/length/length.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('lengthDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(lengthDefinition.id, 'length');
      expect(lengthDefinition.route, '/length');
      expect(lengthDefinition.name, isNotEmpty);
    });
  });

  group('lengthDefinition.compute', () {
    final compute = lengthDefinition.compute;

    test('1 km = 1000 m', () async {
      final result = await compute({'v': '1', 'unit': 'km'}).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(1000.0, 1e-06));
    });

    test('1 mi ~ 1609.344 m', () async {
      final result = await compute({'v': '1', 'unit': 'mi'}).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(1609.344, 0.001));
    });
  });
}
