import 'package:calclyo/src/calculators/force/force.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('forceDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(forceDefinition.id, 'force');
      expect(forceDefinition.route, '/force');
      expect(forceDefinition.name, isNotEmpty);
    });
  });

  group('forceDefinition.compute', () {
    final compute = forceDefinition.compute;

    test('1 kN = 1000 N', () async {
      final result = await compute({
        'v': '1',
        'unit': 'kN',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(1000.0, 1e-06));
    });

    test('1 lbf ~ 4.448 N', () async {
      final result = await compute({
        'v': '1',
        'unit': 'lbf',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(4.4482216, 0.001));
    });

  });
}
