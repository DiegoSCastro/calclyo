import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;

const _powerInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'v', label: 'value', defaultValue: '100'),
  ],
  controls: [
    SegmentedToggleControl(
      key: 'unit',
      options: ['W', 'kW', 'MW', 'hp (mech)', 'PS'],
    ),
  ],
);

// All entries are watts.
const _toWatts = <String, double>{
  'W': 1,
  'kW': 1000,
  'MW': 1e6,
  'hp (mech)': 745.6998715822702,
  'PS': 735.49875,
};

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final v = parseField(values['v'] ?? '', key: 'value');
      final u = values['unit'] ?? 'W';
      final w = v * (_toWatts[u] ?? 1);
      final lines = <String>['$v $u = ${w.toStringAsFixed(4)} W'];
      for (final entry in _toWatts.entries) {
        if (entry.key == u) continue;
        lines.add('  = ${(w / entry.value).toStringAsFixed(6)} ${entry.key}');
      }
      return CalculatorResult(
        primary: w,
        primaryLabel: '$v $u in W',
        steps: lines,
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const powerDefinition = CalculatorDefinition(
  id: 'power',
  name: 'Power',
  subtitle: 'W, kW, MW, hp, PS',
  icon: IconData(0xe8d5, fontFamily: 'MaterialIcons'),
  accent: Color(0xFF0097A7),
  route: '/power',
  category: CalculatorCategoryId.converter,
  inputSchema: _powerInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
