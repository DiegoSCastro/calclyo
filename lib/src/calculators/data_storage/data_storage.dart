import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;

const _dataStorageInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'v', label: 'value', defaultValue: '1'),
  ],
  controls: [
    SegmentedToggleControl(
      key: 'unit',
      options: ['bit', 'B', 'KB', 'MB', 'GB', 'TB'],
    ),
  ],
);

// All entries are bytes.
const _toBytes = <String, double>{
  'bit': 0.125,
  'B': 1,
  'KB': 1024,
  'MB': 1024 * 1024,
  'GB': 1024 * 1024 * 1024,
  'TB': 1024 * 1024 * 1024 * 1024,
};

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final v = parseField(values['v'] ?? '', key: 'value');
      final u = values['unit'] ?? 'B';
      final b = v * (_toBytes[u] ?? 1);
      final lines = <String>['$v $u = ${b.toStringAsFixed(4)} B'];
      for (final entry in _toBytes.entries) {
        if (entry.key == u) continue;
        lines.add('  = ${(b / entry.value).toStringAsFixed(6)} ${entry.key}');
      }
      return CalculatorResult(
        primary: b,
        primaryLabel: '$v $u in B',
        steps: lines,
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const dataStorageDefinition = CalculatorDefinition(
  id: 'data_storage',
  name: 'Data Storage',
  subtitle: 'bit, B, KB, MB, GB, TB (binary)',
  icon: IconData(0xe8d5, fontFamily: 'MaterialIcons'),
  accent: Color(0xFF0097A7),
  route: '/data-storage',
  category: CalculatorCategoryId.converter,
  inputSchema: _dataStorageInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
