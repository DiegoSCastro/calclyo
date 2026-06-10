import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;

const _volumeInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'v', label: 'value', defaultValue: '1'),
  ],
  controls: [
    SegmentedToggleControl(
      key: 'unit',
      options: ['cup', 'tbsp', 'tsp', 'mL', 'L', 'fl oz (US)', 'pt (US)'],
    ),
  ],
);

// All entries are mL.
const _toMilliliters = <String, double>{
  'cup': 240, // US legal cup
  'tbsp': 14.7867647,
  'tsp': 4.92892159,
  'mL': 1,
  'L': 1000,
  'fl oz (US)': 29.5735296,
  'pt (US)': 473.176473,
};

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final v = parseField(values['v'] ?? '', key: 'value');
      final u = values['unit'] ?? 'mL';
      final ml = v * (_toMilliliters[u] ?? 1);
      final lines = <String>['$v $u = ${ml.toStringAsFixed(4)} mL'];
      for (final entry in _toMilliliters.entries) {
        if (entry.key == u) continue;
        final converted = ml / entry.value;
        lines.add('  = ${converted.toStringAsFixed(6)} ${entry.key}');
      }
      return CalculatorResult(
        primary: ml,
        primaryLabel: '$v $u in mL',
        steps: lines,
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const cookingVolumeDefinition = CalculatorDefinition(
  id: 'cooking_volume',
  name: 'Cooking Volume',
  subtitle: 'cup, tbsp, tsp, mL, L, fl oz, pint',
  icon: IconData(0xe8d5, fontFamily: 'MaterialIcons'),
  accent: Color(0xFF1E88E5),
  route: '/cooking-volume',
  category: CalculatorCategoryId.converter,
  inputSchema: _volumeInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
