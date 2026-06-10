import 'package:calclyo/src/calculators/average/average.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('averageDefinition', () {
    test('exposes the expected id, name, route, and category', () {
      expect(averageDefinition.id, 'average');
      expect(averageDefinition.route, '/average');
      expect(averageDefinition.name, 'Average');
    });
  });

  group('averageDefinition.compute', () {
    final compute = averageDefinition.compute;

    test('mean of 2, 4, 6, 8 = 5', () async {
      final result = await compute({'values': '2, 4, 6, 8'}).run();
      final v = result.getOrElse(
        (f) => throw StateError('expected right, got failure: $f'),
      );
      expect(v.primary, closeTo(5, 1e-9));
    });

    test('mean of single value 7 = 7', () async {
      final result = await compute({'values': '7'}).run();
      final v = result.getOrElse(
        (f) => throw StateError('expected right, got failure: $f'),
      );
      expect(v.primary, closeTo(7, 1e-9));
    });

    test('fails on non-numeric input', () async {
      final result = await compute({'values': '2, banana, 6'}).run();
      expect(result.isLeft(), isTrue);
    });

    test('fails on empty input', () async {
      final result = await compute({'values': ''}).run();
      expect(result.isLeft(), isTrue);
    });
  });
}
