import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

const _tempInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'v', label: 'temperature', defaultValue: '100'),
  ],
  controls: [
    SegmentedToggleControl(key: 'unit', options: ['C', 'F', 'K']),
  ],
);

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(() async {
    final v = parseField(values['v'] ?? '', key: 'temperature');
    final u = values['unit'] ?? 'C';
    // First convert to Celsius.
    final c = switch (u) {
      'C' => v,
      'F' => (v - 32) * 5 / 9,
      'K' => v - 273.15,
      _ => v,
    };
    final f = c * 9 / 5 + 32;
    final k = c + 273.15;
    return CalculatorResult(
      primary: c,
      primaryLabel: 'Celsius',
      steps: [
        'Input: $v $u',
        'Celsius: ${c.toStringAsFixed(4)} °C',
        'Fahrenheit: ${f.toStringAsFixed(4)} °F',
        'Kelvin: ${k.toStringAsFixed(4)} K',
      ],
    );
  }, (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()));
}

/// Registry entry for the temperatureConverter calculator.
const temperatureConverterDefinition = CalculatorDefinition(
  id: 'temperature_converter',
  name: 'Temperature',
  subtitle: 'Celsius, Fahrenheit, Kelvin',
  icon: IconData(0xe8d5, fontFamily: 'MaterialIcons'),
  accent: Color(0xFF039BE5),
  route: '/temperature',
  category: CalculatorCategoryId.converter,
  inputSchema: _tempInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
