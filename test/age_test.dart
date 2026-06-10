import 'package:calclyo/src/calculators/age/age.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ageDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(ageDefinition.id, 'age');
      expect(ageDefinition.route, '/age');
      expect(ageDefinition.name, isNotEmpty);
    });
  });

  group('ageDefinition.compute', () {
    final compute = ageDefinition.compute;

    test('2000-01-15 → 2026-06-10', () async {
      final result = await compute({
        'dob': '2000-01-15',
        'ref': '2026-06-10',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, 26.0);
    });

    test('fails on bad DOB', () async {
      final result = await compute({
        'dob': 'not-a-date',
        'ref': '2026-06-10',
      }).run();
      expect(
        result.isLeft(),
        isTrue,
        reason: 'expected failure for dob=not-a-date, ref=2026-06-10',
      );
    });
  });
}
