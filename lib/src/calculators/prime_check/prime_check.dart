import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

const _primeCheckInputSchema = CalculatorInputSchema(
  fields: [CalculatorInputField(key: 'n', label: 'n', defaultValue: '17')],
);

({bool prime, int? divisor}) _checkPrime(int n) {
  if (n < 2) return (prime: false, divisor: null);
  if (n == 2) return (prime: true, divisor: null);
  if (n.isEven) return (prime: false, divisor: 2);
  for (var i = 3; i * i <= n; i += 2) {
    if (n % i == 0) {
      return (prime: false, divisor: i);
    }
  }
  return (prime: true, divisor: null);
}

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(() async {
    final nRaw = parseField(values['n'] ?? '', key: 'n');
    final n = nRaw.round();
    if (n != nRaw || n < 0) {
      throw const CalculatorFailure('n must be a non-negative integer');
    }
    final result = _checkPrime(n);
    final steps = <String>[
      'n = $n',
      if (!result.prime && n >= 2)
        if (result.divisor != null)
          'Found divisor: ${result.divisor} × ${n ~/ result.divisor!} = $n'
        else
          '$n is even → divisible by 2',
      if (result.prime) '$n is prime' else '$n is not prime',
    ];
    return CalculatorResult(
      primary: result.prime ? 1 : 0,
      primaryLabel: result.prime ? 'Prime' : 'Not prime',
      steps: steps,
    );
  }, (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()));
}

/// Registry entry for the primeCheck calculator.
const primeCheckDefinition = CalculatorDefinition(
  id: 'prime_check',
  name: 'Prime Check',
  subtitle: 'Is n a prime number?',
  icon: IconData(0xe1ec, fontFamily: 'MaterialIcons'), // Icons.calculate
  accent: Color(0xFF283593),
  route: '/prime-check',
  category: CalculatorCategoryId.algebra,
  inputSchema: _primeCheckInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
