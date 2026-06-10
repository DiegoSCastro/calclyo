import 'dart:math' as math;

import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;

const _rectangleInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'w', label: 'width', defaultValue: '5'),
    CalculatorInputField(key: 'h', label: 'height', defaultValue: '3'),
  ],
);

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final w = parseField(values['w'] ?? '', key: 'width', allowZero: false);
      final h = parseField(values['h'] ?? '', key: 'height', allowZero: false);
      final area = w * h;
      final perimeter = 2 * (w + h);
      final diagonal = math.sqrt(w * w + h * h);
      return CalculatorResult(
        primary: area,
        primaryLabel: 'Area',
        steps: [
          'Width = $w, Height = $h',
          'Area = w × h = ${area.toStringAsFixed(6)}',
          'Perimeter = 2(w + h) = ${perimeter.toStringAsFixed(6)}',
          'Diagonal = √(w² + h²) = ${diagonal.toStringAsFixed(6)}',
        ],
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const rectangleDefinition = CalculatorDefinition(
  id: 'rectangle',
  name: 'Rectangle',
  subtitle: 'Area, perimeter, and diagonal',
  icon: IconData(0xe1b1, fontFamily: 'MaterialIcons'), // Icons.category
  accent: Color(0xFF004D40),
  route: '/rectangle',
  category: CalculatorCategoryId.geometry,
  inputSchema: _rectangleInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
