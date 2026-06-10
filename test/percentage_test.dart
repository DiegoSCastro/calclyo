import 'package:calclyo/src/calculators/percentage/percentage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('percentageDefinition', () {
    test('exposes the expected id, name, route, and category', () {
      expect(percentageDefinition.id, 'percentage');
      expect(percentageDefinition.route, '/percentage');
      expect(percentageDefinition.name, 'Percentage');
    });
  });

  group('percentageDefinition.compute', () {
    final compute = percentageDefinition.compute;

    test('computes 10% of 200 = 20', () async {
      final result = await compute({
        'a': '10',
        'b': '200',
        'mode': 'A% of B',
      }).run();
      final v = result.getOrElse(
        (f) => throw StateError('expected right, got failure: $f'),
      );
      expect(v.primary, closeTo(20, 1e-9));
    });

    test('computes 50 is what % of 200 = 25', () async {
      final result = await compute({
        'a': '50',
        'b': '200',
        'mode': 'A is % of B',
      }).run();
      final v = result.getOrElse(
        (f) => throw StateError('expected right, got failure: $f'),
      );
      expect(v.primary, closeTo(25, 1e-9));
    });

    test('computes 100 → 150 percent change = 50%', () async {
      final result = await compute({
        'a': '100',
        'b': '150',
        'mode': 'A→B change',
      }).run();
      final v = result.getOrElse(
        (f) => throw StateError('expected right, got failure: $f'),
      );
      expect(v.primary, closeTo(50, 1e-9));
    });
  });
}
