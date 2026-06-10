import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

const _dataTransferInputSchema = CalculatorInputSchema(
  fields: [CalculatorInputField(key: 'v', label: 'value', defaultValue: '100')],
  controls: [
    SegmentedToggleControl(
      key: 'unit',
      options: ['bps', 'kbps', 'Mbps', 'Gbps', 'B/s', 'KB/s', 'MB/s'],
    ),
  ],
);

// All entries are bits per second.
const _toBps = <String, double>{
  'bps': 1,
  'kbps': 1000,
  'Mbps': 1000 * 1000,
  'Gbps': 1000 * 1000 * 1000,
  'B/s': 8,
  'KB/s': 8 * 1000,
  'MB/s': 8 * 1000 * 1000,
};

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(() async {
    final v = parseField(values['v'] ?? '', key: 'value');
    final u = values['unit'] ?? 'Mbps';
    final bps = v * (_toBps[u] ?? 1);
    final lines = <String>['$v $u = ${bps.toStringAsFixed(4)} bps'];
    for (final entry in _toBps.entries) {
      if (entry.key == u) continue;
      lines.add('  = ${(bps / entry.value).toStringAsFixed(6)} ${entry.key}');
    }
    return CalculatorResult(
      primary: bps,
      primaryLabel: '$v $u in bps',
      steps: lines,
    );
  }, (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()));
}

/// Registry entry for the dataTransfer calculator.
const dataTransferDefinition = CalculatorDefinition(
  id: 'data_transfer',
  name: 'Data Transfer',
  subtitle: 'bps, kbps, Mbps, Gbps, B/s, KB/s, MB/s',
  icon: IconData(0xe8d5, fontFamily: 'MaterialIcons'),
  accent: Color(0xFF00838F),
  route: '/data-transfer',
  category: CalculatorCategoryId.converter,
  inputSchema: _dataTransferInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
