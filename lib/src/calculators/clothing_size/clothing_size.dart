import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;

const _clothingInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'v', label: 'value', defaultValue: '38'),
  ],
  controls: [
    SegmentedToggleControl(
      key: 'kind',
      options: ['Top (US)', 'Dress (US)'],
    ),
    SegmentedToggleControl(
      key: 'sys',
      options: ['US', 'EU', 'UK'],
    ),
  ],
);

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final v = parseField(values['v'] ?? '', key: 'value', allowZero: false);
      final kind = values['kind'] ?? 'Top (US)';
      final sys = values['sys'] ?? 'US';
      // Convert to US numeric, then to other systems.
      // Tops: US is the same as numeric, EU = US + 30, UK = US + 4.
      // Dress: US dress uses even numbers; EU dress = US + 30; UK = US + 4.
      int us;
      if (sys == 'US') {
        us = v.round();
      } else if (sys == 'EU') {
        us = v.round() - 30;
      } else {
        us = v.round() - 4;
      }
      final eu = us + 30;
      final uk = us + 4;
      return CalculatorResult(
        primary: us.toDouble(),
        primaryLabel: 'US',
        steps: [
          'Kind: $kind',
          'Input: $v $sys',
          'US: $us',
          'EU: $eu',
          'UK: $uk',
          'Note: clothing sizes vary by brand; values are approximate.',
        ],
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const clothingSizeDefinition = CalculatorDefinition(
  id: 'clothing_size',
  name: 'Clothing Size',
  subtitle: 'US / EU / UK tops and dresses (approximate)',
  icon: IconData(0xe865, fontFamily: 'MaterialIcons'),
  accent: Color(0xFFC2185B),
  route: '/clothing-size',
  category: CalculatorCategoryId.lifestyle,
  inputSchema: _clothingInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
