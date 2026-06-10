import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

const _fuelInputSchema = CalculatorInputSchema(
  fields: [CalculatorInputField(key: 'v', label: 'value', defaultValue: '8.5')],
  controls: [
    SegmentedToggleControl(
      key: 'unit',
      options: ['km/L', 'mpg (US)', 'mpg (UK)', 'L/100km'],
    ),
  ],
);

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(() async {
    final v = parseField(values['v'] ?? '', key: 'value', allowZero: false);
    final u = values['unit'] ?? 'km/L';
    // Normalize to km/L.
    final kmPerL = switch (u) {
      'km/L' => v,
      'mpg (US)' => v * 0.425143707,
      'mpg (UK)' => v * 0.354006,
      'L/100km' => 100 / v,
      _ => v,
    };
    final mpgUs = kmPerL / 0.425143707;
    final mpgUk = kmPerL / 0.354006;
    final l100 = 100 / kmPerL;
    return CalculatorResult(
      primary: kmPerL,
      primaryLabel: 'km/L',
      steps: [
        'Input: $v $u',
        'km/L: ${kmPerL.toStringAsFixed(4)}',
        'mpg (US): ${mpgUs.toStringAsFixed(4)}',
        'mpg (UK): ${mpgUk.toStringAsFixed(4)}',
        'L/100km: ${l100.toStringAsFixed(4)}',
      ],
    );
  }, (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()));
}

/// Registry entry for the fuel calculator.
const fuelDefinition = CalculatorDefinition(
  id: 'fuel',
  name: 'Fuel Economy',
  subtitle: 'km/L, mpg (US/UK), L/100km',
  icon: IconData(0xe8d5, fontFamily: 'MaterialIcons'),
  accent: Color(0xFF00695C),
  route: '/fuel',
  category: CalculatorCategoryId.converter,
  inputSchema: _fuelInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
