import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

const _weightInputSchema = CalculatorInputSchema(
  fields: [CalculatorInputField(key: 'v', label: 'value', defaultValue: '1')],
  controls: [
    SegmentedToggleControl(
      key: 'unit',
      options: ['g', 'kg', 'mg', 'lb', 'oz', 'ton (metric)'],
    ),
  ],
);

// All entries are grams.
const _toGrams = <String, double>{
  'g': 1,
  'kg': 1000,
  'mg': 0.001,
  'lb': 453.59237,
  'oz': 28.349523125,
  'ton (metric)': 1e6,
};

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(() async {
    final v = parseField(values['v'] ?? '', key: 'value');
    final u = values['unit'] ?? 'g';
    final g = v * (_toGrams[u] ?? 1);
    final lines = <String>['$v $u = ${g.toStringAsFixed(4)} g'];
    for (final entry in _toGrams.entries) {
      if (entry.key == u) continue;
      lines.add('  = ${(g / entry.value).toStringAsFixed(6)} ${entry.key}');
    }
    return CalculatorResult(
      primary: g,
      primaryLabel: '$v $u in g',
      steps: lines,
    );
  }, (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()));
}

/// Registry entry for the weight calculator.
const weightDefinition = CalculatorDefinition(
  id: 'weight',
  name: 'Weight',
  subtitle: 'g, kg, mg, lb, oz, metric ton',
  icon: IconData(0xe8d5, fontFamily: 'MaterialIcons'),
  accent: Color(0xFF01579B),
  route: '/weight',
  category: CalculatorCategoryId.converter,
  inputSchema: _weightInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
