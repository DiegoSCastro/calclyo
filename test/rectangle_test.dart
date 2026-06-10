import 'package:calclyo/src/calculators/rectangle/rectangle.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('rectangleDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(rectangleDefinition.id, 'rectangle');
      expect(rectangleDefinition.route, '/rectangle');
      expect(rectangleDefinition.name, isNotEmpty);
    });
  });

  group('rectangleDefinition.compute', () {
    final compute = rectangleDefinition.compute;

    test('5x3 → area 15', () async {
      final result = await compute({
        'w': '5',
        'h': '3',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(15.0, 1e-09));
    });

    test('3x4 area = 12', () async {
      final result = await compute({
        'w': '3',
        'h': '4',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(12.0, 1e-09));
    });

  });
}
