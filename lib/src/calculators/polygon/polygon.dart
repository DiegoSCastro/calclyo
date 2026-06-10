import 'dart:math' as math;

import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;

const _polygonInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'n', label: 'n (sides)', defaultValue: '6'),
    CalculatorInputField(key: 's', label: 'side length', defaultValue: '5'),
  ],
);

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final nRaw = parseField(values['n'] ?? '', key: 'n', allowZero: false);
      final s = parseField(values['s'] ?? '', key: 'side', allowZero: false);
      final n = nRaw.round();
      if (n != nRaw || n < 3) {
        throw const CalculatorFailure(
          'A polygon must have at least 3 sides',
        );
      }
      final perimeter = n * s;
      // Area of a regular n-gon with side s:  n·s² / (4·tan(π/n))
      final area = (n * s * s) / (4 * math.tan(math.pi / n));
      final apothem = s / (2 * math.tan(math.pi / n));
      return CalculatorResult(
        primary: area,
        primaryLabel: 'Area',
        steps: [
          'Sides: n = $n, side s = $s',
          'Perimeter = n × s = ${perimeter.toStringAsFixed(6)}',
          'Apothem = s / (2 tan(π/n)) = ${apothem.toStringAsFixed(6)}',
          'Area = n·s² / (4·tan(π/n)) = ${area.toStringAsFixed(6)}',
        ],
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const polygonDefinition = CalculatorDefinition(
  id: 'polygon',
  name: 'Regular Polygon',
  subtitle: 'Area, perimeter, and apothem of a regular n-gon',
  icon: IconData(0xe1b1, fontFamily: 'MaterialIcons'), // Icons.category
  accent: Color(0xFF00695C),
  route: '/polygon',
  category: CalculatorCategoryId.geometry,
  inputSchema: _polygonInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
