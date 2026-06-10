import 'package:calclyo/src/calculators/triangle/triangle.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('triangleDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(triangleDefinition.id, 'triangle');
      expect(triangleDefinition.route, '/triangle');
      expect(triangleDefinition.name, isNotEmpty);
    });
  });

  group('triangleDefinition.compute', () {
    final compute = triangleDefinition.compute;

    test('3-4-5 right triangle area = 6', () async {
      final result = await compute({
        'a': '3',
        'b': '4',
        'c': '5',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(6.0, 1e-06));
    });

    test('fails on triangle inequality', () async {
      final result = await compute({
        'a': '1',
        'b': '1',
        'c': '3',
      }).run();
      expect(result.isLeft(), isTrue,
          reason: 'expected failure for a=1, b=1, c=3');
    });

  });
}
