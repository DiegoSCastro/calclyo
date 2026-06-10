import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;

enum AreaUnit {
  m2,
  km2,
  cm2,
  mm2,
  ha,
  acre,
  ft2,
  yd2,
  mi2,
}

const _areaInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'v', label: 'value', defaultValue: '1'),
  ],
  controls: [
    SegmentedToggleControl(
      key: 'unit',
      options: [
        'm²', 'km²', 'cm²', 'mm²', 'ha', 'acre', 'ft²', 'yd²', 'mi²',
      ],
    ),
  ],
);

// All entries are m².
const _toSquareMeters = <String, double>{
  'm²': 1,
  'km²': 1e6,
  'cm²': 1e-4,
  'mm²': 1e-6,
  'ha': 1e4,
  'acre': 4046.8564224,
  'ft²': 0.09290304,
  'yd²': 0.83612736,
  'mi²': 2589988.110336,
};

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final v = parseField(values['v'] ?? '', key: 'value');
      final u = values['unit'] ?? 'm²';
      final m2 = v * (_toSquareMeters[u] ?? 1);
      final lines = <String>['$v $u = ${m2.toStringAsFixed(4)} m²'];
      for (final entry in _toSquareMeters.entries) {
        if (entry.key == u) continue;
        final converted = m2 / entry.value;
        lines.add('  = ${converted.toStringAsFixed(6)} ${entry.key}');
      }
      return CalculatorResult(
        primary: m2,
        primaryLabel: '$v $u in m²',
        steps: lines,
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const areaDefinition = CalculatorDefinition(
  id: 'area',
  name: 'Area',
  subtitle: 'm², km², cm², ha, acre, ft², yd², mi²',
  icon: IconData(0xe8d5, fontFamily: 'MaterialIcons'),
  accent: Color(0xFF1976D2),
  route: '/area',
  category: CalculatorCategoryId.converter,
  inputSchema: _areaInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
