import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

const _combinationsInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'n', label: 'n (total)', defaultValue: '10'),
    CalculatorInputField(key: 'r', label: 'r (chosen)', defaultValue: '3'),
  ],
);

int _nCr(int n, int r) {
  if (r < 0 || n < 0) {
    throw const CalculatorFailure('n and r must be non-negative');
  }
  if (r > n) {
    throw const CalculatorFailure('r cannot exceed n');
  }
  // Use multiplicative formula to avoid huge intermediate factorials.
  final k = r > n - r ? n - r : r;
  var result = 1;
  for (var i = 0; i < k; i++) {
    result = result * (n - i) ~/ (i + 1);
  }
  return result;
}

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(() async {
    final nRaw = parseField(values['n'] ?? '', key: 'n');
    final rRaw = parseField(values['r'] ?? '', key: 'r');
    final n = nRaw.round();
    final r = rRaw.round();
    if (n != nRaw || r != rRaw || n < 0 || r < 0) {
      throw const CalculatorFailure('n and r must be non-negative integers');
    }
    final c = _nCr(n, r);
    return CalculatorResult(
      primary: c.toDouble(),
      primaryLabel: 'C(n,r)',
      steps: [
        'n = $n, r = $r',
        'C(n, r) = n! / (r! (n − r)!)',
        'C($n, $r) = $c',
      ],
    );
  }, (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()));
}

/// Registry entry for the combinations calculator.
const combinationsDefinition = CalculatorDefinition(
  id: 'combinations',
  name: 'Combinations',
  subtitle: 'C(n, r) — choose r items from n',
  icon: IconData(0xe1ec, fontFamily: 'MaterialIcons'), // Icons.calculate
  accent: Color(0xFF311B92),
  route: '/combinations',
  category: CalculatorCategoryId.algebra,
  inputSchema: _combinationsInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
