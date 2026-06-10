import 'package:calclyo/src/calculators/data_storage/data_storage.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dataStorageDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(dataStorageDefinition.id, 'data_storage');
      expect(dataStorageDefinition.route, '/data-storage');
      expect(dataStorageDefinition.name, isNotEmpty);
    });
  });

  group('dataStorageDefinition.compute', () {
    final compute = dataStorageDefinition.compute;

    test('1 MB = 1048576 B', () async {
      final result = await compute({
        'v': '1',
        'unit': 'MB',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(1048576, 1e-06));
    });

    test('1024 B = 1 KB', () async {
      final result = await compute({
        'v': '1024',
        'unit': 'B',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(1024.0, 1e-06));
    });

  });
}
