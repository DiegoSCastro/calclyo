import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;

const _ratioInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'a', label: 'A', defaultValue: '12'),
    CalculatorInputField(key: 'b', label: 'B', defaultValue: '18'),
  ],
);

int _gcd(int a, int b) {
  a = a.abs();
  b = b.abs();
  while (b != 0) {
    final t = b;
    b = a % b;
    a = t;
  }
  return a == 0 ? 1 : a;
}

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final aRaw = parseField(values['a'] ?? '', key: 'A', allowZero: false);
      final bRaw = parseField(values['b'] ?? '', key: 'B', allowZero: false);
      final a = aRaw.round();
      final b = bRaw.round();
      if (a != aRaw || b != bRaw) {
        throw const CalculatorFailure('Ratio inputs must be whole numbers');
      }
      final g = _gcd(a, b);
      final aS = a ~/ g;
      final bS = b ~/ g;
      return CalculatorResult(
        primary: aS.toDouble() / bS,
        primaryLabel: '$aS : $bS',
        steps: [
          'Given: A=$a, B=$b',
          'GCD(A, B) = $g',
          'Simplified: A/GCD = ${a ~/ g}, B/GCD = ${b ~/ g}',
          'Ratio: $a : $b  →  $aS : $bS',
        ],
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const ratioDefinition = CalculatorDefinition(
  id: 'ratio',
  name: 'Ratio',
  subtitle: 'Simplify A:B to lowest terms',
  icon: IconData(0xe1ec, fontFamily: 'MaterialIcons'), // Icons.calculate
  accent: Color(0xFF7B1FA2),
  route: '/ratio',
  category: CalculatorCategoryId.algebra,
  inputSchema: _ratioInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
