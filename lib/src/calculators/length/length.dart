import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

/// LengthUnit values.
/// Length units.
enum LengthUnit {
  /// Meters.
  m,

  /// Kilometers.
  km,

  /// Centimeters.
  cm,

  /// Millimeters.
  mm,

  /// Miles.
  mi,

  /// Yards.
  yd,

  /// Feet.
  ft,

  /// Inches.
  inch,
}

const _lengthUnitKey = 'unit';
const _lengthValueKey = 'v';

const _lengthInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(
      key: _lengthValueKey,
      label: 'value',
      defaultValue: '1',
    ),
  ],
  controls: [
    SegmentedToggleControl(
      key: _lengthUnitKey,
      options: ['m', 'km', 'cm', 'mm', 'mi', 'yd', 'ft', 'inch'],
    ),
  ],
);

const _toMeters = <String, double>{
  'm': 1,
  'km': 1000,
  'cm': 0.01,
  'mm': 0.001,
  'mi': 1609.344,
  'yd': 0.9144,
  'ft': 0.3048,
  'inch': 0.0254,
};

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(() async {
    final v = parseField(values[_lengthValueKey] ?? '', key: 'value');
    final u = values[_lengthUnitKey] ?? 'm';
    final m = v * (_toMeters[u] ?? 1);
    final lines = <String>['$v $u = ${m.toStringAsFixed(4)} m'];
    for (final entry in _toMeters.entries) {
      if (entry.key == u) continue;
      final converted = m / entry.value;
      lines.add('  = ${converted.toStringAsFixed(6)} ${entry.key}');
    }
    return CalculatorResult(
      primary: m,
      primaryLabel: '$v $u in m',
      steps: lines,
    );
  }, (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()));
}

/// Registry entry for the length calculator.
const lengthDefinition = CalculatorDefinition(
  id: 'length',
  name: 'Length',
  subtitle: 'm, km, cm, mm, mi, yd, ft, in',
  icon: IconData(0xe8d5, fontFamily: 'MaterialIcons'), // Icons.swap_horiz
  accent: Color(0xFF1565C0),
  route: '/length',
  category: CalculatorCategoryId.converter,
  inputSchema: _lengthInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
