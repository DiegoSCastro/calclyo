import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;

const _accelerationInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'v', label: 'value', defaultValue: '9.80665'),
  ],
  controls: [
    SegmentedToggleControl(
      key: 'unit',
      options: ['m/s²', 'g', 'ft/s²', 'km/h/s', 'mph/s'],
    ),
  ],
);

const _toMps2 = <String, double>{
  'm/s²': 1,
  'g': 9.80665,
  'ft/s²': 0.3048,
  'km/h/s': 0.2777777778, // 1 km/h per second = 1/3.6 m/s²
  'mph/s': 0.44704,
};

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final v = parseField(values['v'] ?? '', key: 'value');
      final u = values['unit'] ?? 'm/s²';
      final mps2 = v * (_toMps2[u] ?? 1);
      final lines = <String>['$v $u = ${mps2.toStringAsFixed(4)} m/s²'];
      for (final entry in _toMps2.entries) {
        if (entry.key == u) continue;
        lines.add('  = ${(mps2 / entry.value).toStringAsFixed(6)} ${entry.key}');
      }
      return CalculatorResult(
        primary: mps2,
        primaryLabel: '$v $u in m/s²',
        steps: lines,
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const accelerationDefinition = CalculatorDefinition(
  id: 'acceleration',
  name: 'Acceleration',
  subtitle: 'm/s², g, ft/s², km/h/s, mph/s',
  icon: IconData(0xe8d5, fontFamily: 'MaterialIcons'),
  accent: Color(0xFF0288D1),
  route: '/acceleration',
  category: CalculatorCategoryId.converter,
  inputSchema: _accelerationInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
