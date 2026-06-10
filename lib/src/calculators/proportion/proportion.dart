import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;

const _proportionInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'a', label: 'A', defaultValue: '2'),
    CalculatorInputField(key: 'b', label: 'B', defaultValue: '10'),
    CalculatorInputField(key: 'c', label: 'C', defaultValue: '7'),
  ],
);

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final a = parseField(values['a'] ?? '', key: 'A', allowZero: false);
      final b = parseField(values['b'] ?? '', key: 'B', allowZero: false);
      final c = parseField(values['c'] ?? '', key: 'C');
      // A:B :: C:D → D = B * C / A
      final d = (b * c) / a;
      return CalculatorResult(
        primary: d,
        primaryLabel: 'D',
        steps: [
          'Proportion: A:B = C:D',
          'Given: A=$a, B=$b, C=$c',
          'Formula: D = (B × C) / A',
          'Computation: D = (${b.toStringAsFixed(2)} × '
              '${c.toStringAsFixed(2)}) / ${a.toStringAsFixed(2)}',
          '= ${d.toStringAsFixed(6)}',
        ],
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const proportionDefinition = CalculatorDefinition(
  id: 'proportion',
  name: 'Proportion',
  subtitle: 'Solve A:B = C:D for the missing value',
  icon: IconData(0xe1ec, fontFamily: 'MaterialIcons'), // Icons.calculate
  accent: Color(0xFF8E24AA),
  route: '/proportion',
  category: CalculatorCategoryId.algebra,
  inputSchema: _proportionInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
