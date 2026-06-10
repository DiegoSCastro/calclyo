import 'package:calclyo/src/calculators/bodies_3d/bodies_3d.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bodies3DDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(bodies3DDefinition.id, 'bodies_3d');
      expect(bodies3DDefinition.route, '/bodies-3d');
      expect(bodies3DDefinition.name, isNotEmpty);
    });
  });

  group('bodies3DDefinition.compute', () {
    final compute = bodies3DDefinition.compute;

    test('cube side 3 → volume 27', () async {
      final result = await compute({
        'r': '1',
        'h': '3',
        'kind': 'Cube',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(27.0, 1e-06));
    });

    test('sphere radius 1 → volume 4π/3', () async {
      final result = await compute({
        'r': '1',
        'h': '1',
        'kind': 'Sphere',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(4.18879, 0.001));
    });

  });
}
