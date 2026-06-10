import 'package:calclyo/src/calculators/clothing_size/clothing_size.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('clothingSizeDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(clothingSizeDefinition.id, 'clothing_size');
      expect(clothingSizeDefinition.route, '/clothing-size');
      expect(clothingSizeDefinition.name, isNotEmpty);
    });
  });

  group('clothingSizeDefinition.compute', () {
    final compute = clothingSizeDefinition.compute;

    test('US 38 top → US 38', () async {
      final result = await compute({
        'v': '38',
        'kind': 'Top (US)',
        'sys': 'US',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, 38.0);
    });

    test('EU 38 top → US 8', () async {
      final result = await compute({
        'v': '38',
        'kind': 'Top (US)',
        'sys': 'EU',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, 8.0);
    });

  });
}
