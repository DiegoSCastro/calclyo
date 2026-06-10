import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;

const _shoeInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'v', label: 'value', defaultValue: '10'),
  ],
  controls: [
    SegmentedToggleControl(
      key: 'sys',
      options: ['US', 'EU', 'UK', 'cm', 'inch'],
    ),
  ],
);

/// US men's size → foot length in cm.
double _usToCm(double us) => 0.8467 * us + 19.53;

/// EU size → foot length in cm.
double _euToCm(double eu) => (eu / 1.5) - 2;

double _round1(double v) => (v * 10).round() / 10;

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final v = parseField(values['v'] ?? '', key: 'value', allowZero: false);
      final sys = values['sys'] ?? 'US';
      final cm = switch (sys) {
        'US' => _usToCm(v),
        'EU' => _euToCm(v),
        'UK' => _usToCm(v + 0.5),
        'cm' => v,
        'inch' => v * 2.54,
        _ => v,
      };
      final us = _round1((cm - 19.53) / 0.8467);
      final eu = _round1(1.5 * (cm + 2));
      final uk = _round1(us - 0.5);
      final inch = _round1(cm / 2.54);
      return CalculatorResult(
        primary: cm,
        primaryLabel: 'cm',
        steps: [
          'Input: $v $sys',
          'Length: ${cm.toStringAsFixed(2)} cm',
          'US: ${us.toStringAsFixed(1)}',
          'EU: ${eu.toStringAsFixed(1)}',
          'UK: ${uk.toStringAsFixed(1)}',
          'inch: ${inch.toStringAsFixed(2)}',
          'Note: shoe sizing varies by brand; values are approximate.',
        ],
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const shoeSizeDefinition = CalculatorDefinition(
  id: 'shoe_size',
  name: 'Shoe Size',
  subtitle: 'US / EU / UK / cm / inch (approximate)',
  icon: IconData(0xe865, fontFamily: 'MaterialIcons'),
  accent: Color(0xFFAD1457),
  route: '/shoe-size',
  category: CalculatorCategoryId.lifestyle,
  inputSchema: _shoeInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
