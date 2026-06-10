import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;

const _speedInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'v', label: 'value', defaultValue: '60'),
  ],
  controls: [
    SegmentedToggleControl(
      key: 'unit',
      options: ['m/s', 'km/h', 'mph', 'knot', 'ft/s'],
    ),
  ],
);

// All entries are m/s.
const _toMps = <String, double>{
  'm/s': 1,
  'km/h': 0.2777777778,
  'mph': 0.44704,
  'knot': 0.5144444444,
  'ft/s': 0.3048,
};

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final v = parseField(values['v'] ?? '', key: 'value');
      final u = values['unit'] ?? 'km/h';
      final mps = v * (_toMps[u] ?? 1);
      final lines = <String>['$v $u = ${mps.toStringAsFixed(4)} m/s'];
      for (final entry in _toMps.entries) {
        if (entry.key == u) continue;
        lines.add('  = ${(mps / entry.value).toStringAsFixed(6)} ${entry.key}');
      }
      return CalculatorResult(
        primary: mps,
        primaryLabel: '$v $u in m/s',
        steps: lines,
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const speedDefinition = CalculatorDefinition(
  id: 'speed',
  name: 'Speed',
  subtitle: 'm/s, km/h, mph, knot, ft/s',
  icon: IconData(0xe8d5, fontFamily: 'MaterialIcons'),
  accent: Color(0xFF00838F),
  route: '/speed',
  category: CalculatorCategoryId.converter,
  inputSchema: _speedInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
