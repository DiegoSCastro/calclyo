import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

const _angleInputSchema = CalculatorInputSchema(
  fields: [CalculatorInputField(key: 'v', label: 'value', defaultValue: '180')],
  controls: [
    SegmentedToggleControl(
      key: 'unit',
      options: ['deg', 'rad', 'grad', 'turn'],
    ),
  ],
);

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(() async {
    final v = parseField(values['v'] ?? '', key: 'value');
    final u = values['unit'] ?? 'deg';
    // Normalize to degrees.
    final deg = switch (u) {
      'deg' => v,
      'rad' => v * 180 / _pi,
      'grad' => v * 0.9,
      'turn' => v * 360,
      _ => v,
    };
    final rad = deg * _pi / 180;
    final grad = deg / 0.9;
    final turn = deg / 360;
    return CalculatorResult(
      primary: deg,
      primaryLabel: 'Degrees',
      steps: [
        'Input: $v $u',
        'Degrees: ${deg.toStringAsFixed(6)} °',
        'Radians: ${rad.toStringAsFixed(6)} rad',
        'Gradians: ${grad.toStringAsFixed(6)} grad',
        'Turns: ${turn.toStringAsFixed(6)} turn',
      ],
    );
  }, (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()));
}

const _pi = 3.141592653589793;

/// Registry entry for the angle calculator.
const angleDefinition = CalculatorDefinition(
  id: 'angle',
  name: 'Angle',
  subtitle: 'deg, rad, grad, turn',
  icon: IconData(0xe8d5, fontFamily: 'MaterialIcons'),
  accent: Color(0xFF0277BD),
  route: '/angle',
  category: CalculatorCategoryId.converter,
  inputSchema: _angleInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
