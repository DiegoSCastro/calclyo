import 'package:calclyo/src/calculators/loan_pmt/loan_pmt.dart';
import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('loanPmtDefinition', () {
    test('exposes the expected id, name, and route', () {
      expect(loanPmtDefinition.id, 'loan_pmt');
      expect(loanPmtDefinition.route, '/loan-pmt');
      expect(loanPmtDefinition.name, isNotEmpty);
    });
  });

  group('loanPmtDefinition.compute', () {
    final compute = loanPmtDefinition.compute;

    test('\\\$200k @ 5% over 360 mo', () async {
      final result = await compute({
        'p': '200000',
        'r': '5',
        'n': '360',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(1073.64, 0.1));
    });

    test('\\\$0 loan → 0', () async {
      final result = await compute({
        'p': '0',
        'r': '5',
        'n': '12',
      }).run();
      final value = result.getOrElse(
        (CalculatorFailure f) =>
            throw StateError('expected right, got failure: \$f'),
      );
      expect(value.primary, closeTo(0.0, 1e-06));
    });

  });
}
