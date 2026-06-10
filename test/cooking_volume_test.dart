import 'package:calclyo/src/calculators/cooking_volume/cooking_volume.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cookingVolumeDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(cookingVolumeDefinition.id, 'cooking_volume');
      expect(cookingVolumeDefinition.route, '/cooking-volume');
      expect(cookingVolumeDefinition.name, isNotEmpty);
    });
  });

  group('cookingVolumeDefinition.compute', () {
    final compute = cookingVolumeDefinition.compute;

    test('1 cup = 240 mL', () async {
      final result = await compute({
        'v': '1',
        'unit': 'cup',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(240.0, 1e-06));
    });

    test('1 L = 1000 mL', () async {
      final result = await compute({
        'v': '1',
        'unit': 'L',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(1000.0, 1e-06));
    });

  });
}
