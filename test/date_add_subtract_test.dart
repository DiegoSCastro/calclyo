import 'package:calclyo/src/calculators/date_add_subtract/date_add_subtract.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dateAddSubtractDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(dateAddSubtractDefinition.id, 'date_add_subtract');
      expect(dateAddSubtractDefinition.route, '/date-math');
      expect(dateAddSubtractDefinition.name, isNotEmpty);
    });
  });

  group('dateAddSubtractDefinition.compute', () {
    final compute = dateAddSubtractDefinition.compute;

    test('2026-06-10 +30 days', () async {
      final result = await compute({
        'start': '2026-06-10',
        'n': '30',
        'unit': 'days',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, 30.0);
    });

    test('fails on bad date', () async {
      final result = await compute({
        'start': 'bad',
        'n': '1',
        'unit': 'days',
      }).run();
      expect(
        result.isLeft(),
        isTrue,
        reason: 'expected failure for start=bad, n=1, unit=days',
      );
    });
  });
}
