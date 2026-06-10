import 'package:calclyo/src/calculators/polygon/polygon.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('polygonDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(polygonDefinition.id, 'polygon');
      expect(polygonDefinition.route, '/polygon');
      expect(polygonDefinition.name, isNotEmpty);
    });
  });

  group('polygonDefinition.compute', () {
    final compute = polygonDefinition.compute;

    test('regular hexagon side 5', () async {
      final result = await compute({
        'n': '6',
        's': '5',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(64.9519052838329, 1e-06));
    });

    test('square side 4', () async {
      final result = await compute({
        'n': '4',
        's': '4',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(16.0, 1e-06));
    });

  });
}
