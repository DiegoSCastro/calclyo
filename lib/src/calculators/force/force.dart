import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;

const _forceInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'v', label: 'value', defaultValue: '100'),
  ],
  controls: [
    SegmentedToggleControl(
      key: 'unit',
      options: ['N', 'kN', 'lbf', 'kgf', 'dyne'],
    ),
  ],
);

// All entries are newtons.
const _toNewtons = <String, double>{
  'N': 1,
  'kN': 1000,
  'lbf': 4.4482216152605,
  'kgf': 9.80665,
  'dyne': 0.00001,
};

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final v = parseField(values['v'] ?? '', key: 'value');
      final u = values['unit'] ?? 'N';
      final n = v * (_toNewtons[u] ?? 1);
      final lines = <String>['$v $u = ${n.toStringAsFixed(4)} N'];
      for (final entry in _toNewtons.entries) {
        if (entry.key == u) continue;
        lines.add('  = ${(n / entry.value).toStringAsFixed(6)} ${entry.key}');
      }
      return CalculatorResult(
        primary: n,
        primaryLabel: '$v $u in N',
        steps: lines,
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const forceDefinition = CalculatorDefinition(
  id: 'force',
  name: 'Force',
  subtitle: 'N, kN, lbf, kgf, dyne',
  icon: IconData(0xe8d5, fontFamily: 'MaterialIcons'),
  accent: Color(0xFF004D40),
  route: '/force',
  category: CalculatorCategoryId.converter,
  inputSchema: _forceInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
