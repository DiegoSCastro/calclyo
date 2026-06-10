import 'package:calclyo/src/calculators/time_interval/time_interval.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('timeIntervalDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(timeIntervalDefinition.id, 'time_interval');
      expect(timeIntervalDefinition.route, '/time-interval');
      expect(timeIntervalDefinition.name, isNotEmpty);
    });
  });

  group('timeIntervalDefinition.compute', () {
    final compute = timeIntervalDefinition.compute;

    test('09:15 → 17:45 = 8.5h', () async {
      final result = await compute({'a': '09:15', 'b': '17:45'}).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError(r'expected right, got failure: $f'),
      );
      expect(value.primary, closeTo(8.5, 1e-06));
    });

    test('fails on bad time', () async {
      final result = await compute({'a': 'not-a-time', 'b': '17:45'}).run();
      expect(
        result.isLeft(),
        isTrue,
        reason: 'expected failure for a=not-a-time, b=17:45',
      );
    });
  });
}
