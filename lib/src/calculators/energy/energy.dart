import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

const _energyInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'v', label: 'value', defaultValue: '1000'),
  ],
  controls: [
    SegmentedToggleControl(
      key: 'unit',
      options: ['J', 'kJ', 'cal', 'kcal', 'Wh', 'kWh'],
    ),
  ],
);

// All entries are joules.
const _toJoules = <String, double>{
  'J': 1,
  'kJ': 1000,
  'cal': 4.184,
  'kcal': 4184,
  'Wh': 3600,
  'kWh': 3600 * 1000,
};

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(() async {
    final v = parseField(values['v'] ?? '', key: 'value');
    final u = values['unit'] ?? 'J';
    final j = v * (_toJoules[u] ?? 1);
    final lines = <String>['$v $u = ${j.toStringAsFixed(4)} J'];
    for (final entry in _toJoules.entries) {
      if (entry.key == u) continue;
      lines.add('  = ${(j / entry.value).toStringAsFixed(6)} ${entry.key}');
    }
    return CalculatorResult(
      primary: j,
      primaryLabel: '$v $u in J',
      steps: lines,
    );
  }, (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()));
}

/// Registry entry for the energy calculator.
const energyDefinition = CalculatorDefinition(
  id: 'energy',
  name: 'Energy',
  subtitle: 'J, kJ, cal, kcal, Wh, kWh',
  icon: IconData(0xe8d5, fontFamily: 'MaterialIcons'),
  accent: Color(0xFF006064),
  route: '/energy',
  category: CalculatorCategoryId.converter,
  inputSchema: _energyInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
