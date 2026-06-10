import 'package:calclyo/src/calculators/circle/circle.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('circleDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(circleDefinition.id, 'circle');
      expect(circleDefinition.route, '/circle');
      expect(circleDefinition.name, isNotEmpty);
    });
  });

  group('circleDefinition.compute', () {
    final compute = circleDefinition.compute;

    test('radius 5 → area = 25π', () async {
      final result = await compute({
        'v': '5',
        'mode': 'Radius',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(78.53981633974475, 0.001));
    });

    test('diameter 10 → area = 25π', () async {
      final result = await compute({
        'v': '10',
        'mode': 'Diameter',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(78.53981633974475, 0.001));
    });

  });
}
