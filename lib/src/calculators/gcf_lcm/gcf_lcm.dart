import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;

const _gcfLcmInputSchema = CalculatorInputSchema(
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
  return a;
}

int _lcm(int a, int b) {
  if (a == 0 || b == 0) return 0;
  return (a * b).abs() ~/ _gcd(a, b);
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
        throw const CalculatorFailure('Inputs must be whole numbers');
      }
      final g = _gcd(a, b);
      final l = _lcm(a, b);
      return CalculatorResult(
        primary: g.toDouble(),
        primaryLabel: 'GCF',
        steps: [
          'Given: A=$a, B=$b',
          'GCD via Euclidean algorithm',
          'LCM = |A × B| / GCD',
          'GCD = $g',
          'LCM = $l',
        ],
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const gcfLcmDefinition = CalculatorDefinition(
  id: 'gcf_lcm',
  name: 'GCF & LCM',
  subtitle: 'Greatest common factor and least common multiple',
  icon: IconData(0xe1ec, fontFamily: 'MaterialIcons'), // Icons.calculate
  accent: Color(0xFF4527A0),
  route: '/gcf-lcm',
  category: CalculatorCategoryId.algebra,
  inputSchema: _gcfLcmInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
