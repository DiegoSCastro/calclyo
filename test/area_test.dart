import 'package:calclyo/src/calculators/area/area.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('areaDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(areaDefinition.id, 'area');
      expect(areaDefinition.route, '/area');
      expect(areaDefinition.name, isNotEmpty);
    });
  });

  group('areaDefinition.compute', () {
    final compute = areaDefinition.compute;

    test('1 ha = 10000 m²', () async {
      final result = await compute({
        'v': '1',
        'unit': 'ha',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(10000.0, 1e-06));
    });

    test('1 acre ~ 4046.86 m²', () async {
      final result = await compute({
        'v': '1',
        'unit': 'acre',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(4046.8564224, 0.001));
    });

  });
}
