import 'package:calclyo/src/calculators/data_transfer/data_transfer.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dataTransferDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(dataTransferDefinition.id, 'data_transfer');
      expect(dataTransferDefinition.route, '/data-transfer');
      expect(dataTransferDefinition.name, isNotEmpty);
    });
  });

  group('dataTransferDefinition.compute', () {
    final compute = dataTransferDefinition.compute;

    test('1 Mbps = 1000000 bps', () async {
      final result = await compute({
        'v': '1',
        'unit': 'Mbps',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(1000000.0, 1e-06));
    });

    test('1 MB/s = 8000000 bps', () async {
      final result = await compute({
        'v': '1',
        'unit': 'MB/s',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(8000000.0, 1e-06));
    });

  });
}
