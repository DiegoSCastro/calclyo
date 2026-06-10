import 'package:calclyo/src/calculators/shoe_size/shoe_size.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shoeSizeDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(shoeSizeDefinition.id, 'shoe_size');
      expect(shoeSizeDefinition.route, '/shoe-size');
      expect(shoeSizeDefinition.name, isNotEmpty);
    });
  });

  group('shoeSizeDefinition.compute', () {
    final compute = shoeSizeDefinition.compute;

    test('US 10 → cm ~ 28', () async {
      final result = await compute({
        'v': '10',
        'sys': 'US',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(28.0, 0.01));
    });

    test('EU 42 → cm ~ 26', () async {
      final result = await compute({
        'v': '42',
        'sys': 'EU',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(26.0, 0.01));
    });

  });
}
