import 'package:calclyo/src/calculators/temperature_converter/temperature_converter.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('temperatureConverterDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(temperatureConverterDefinition.id, 'temperature_converter');
      expect(temperatureConverterDefinition.route, '/temperature');
      expect(temperatureConverterDefinition.name, isNotEmpty);
    });
  });

  group('temperatureConverterDefinition.compute', () {
    final compute = temperatureConverterDefinition.compute;

    test('0 °C = 0 °C', () async {
      final result = await compute({'v': '0', 'unit': 'C'}).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(0.0, 1e-06));
    });

    test('100 °C primary is C', () async {
      final result = await compute({'v': '100', 'unit': 'C'}).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(100.0, 1e-06));
    });
  });
}
