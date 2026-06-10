import 'dart:math' as math;

import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;

const _triangleInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'a', label: 'side a', defaultValue: '3'),
    CalculatorInputField(key: 'b', label: 'side b', defaultValue: '4'),
    CalculatorInputField(key: 'c', label: 'side c', defaultValue: '5'),
  ],
);

double _areaHeron(double a, double b, double c) {
  final s = (a + b + c) / 2;
  final inner = s * (s - a) * (s - b) * (s - c);
  if (inner < 0) {
    throw const CalculatorFailure('Not a valid triangle (negative area²)');
  }
  return math.sqrt(inner);
}

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final a = parseField(values['a'] ?? '', key: 'a', allowZero: false);
      final b = parseField(values['b'] ?? '', key: 'b', allowZero: false);
      final c = parseField(values['c'] ?? '', key: 'c', allowZero: false);
      if (a + b <= c || a + c <= b || b + c <= a) {
        throw const CalculatorFailure(
          'Triangle inequality violated: a + b > c, etc.',
        );
      }
      final area = _areaHeron(a, b, c);
      final perimeter = a + b + c;
      // angles via law of cosines
      final angleA = math.acos((b * b + c * c - a * a) / (2 * b * c)) *
          180 /
          math.pi;
      final angleB = math.acos((a * a + c * c - b * b) / (2 * a * c)) *
          180 /
          math.pi;
      final angleC = 180 - angleA - angleB;
      return CalculatorResult(
        primary: area,
        primaryLabel: 'Area',
        steps: [
          'Sides: a=$a, b=$b, c=$c',
          'Perimeter = a + b + c = ${perimeter.toStringAsFixed(4)}',
          'Semi-perimeter s = ${(perimeter / 2).toStringAsFixed(4)}',
          'Area = √(s(s−a)(s−b)(s−c)) = ${area.toStringAsFixed(6)}',
          'Angles (degrees): A=${angleA.toStringAsFixed(2)}°, '
              'B=${angleB.toStringAsFixed(2)}°, '
              'C=${angleC.toStringAsFixed(2)}°',
        ],
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const triangleDefinition = CalculatorDefinition(
  id: 'triangle',
  name: 'Triangle',
  subtitle: 'Area, perimeter, and angles from three sides',
  icon: IconData(0xe1b1, fontFamily: 'MaterialIcons'), // Icons.category
  accent: Color(0xFF00838F),
  route: '/triangle',
  category: CalculatorCategoryId.geometry,
  inputSchema: _triangleInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
