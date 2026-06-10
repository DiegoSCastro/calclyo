import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

/// AddUnit values.
/// Date add/subtract units.
enum AddUnit {
  /// Days.
  days,

  /// Weeks.
  weeks,

  /// Months.
  months,
}

const _addInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(
      key: 'start',
      label: 'start date (YYYY-MM-DD)',
      defaultValue: '2026-06-10',
      keyboardType: CalculatorKeyboardType.text,
    ),
    CalculatorInputField(key: 'n', label: 'amount', defaultValue: '30'),
  ],
  controls: [
    SegmentedToggleControl(key: 'unit', options: ['days', 'weeks', 'months']),
  ],
);

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(() async {
    final startRaw = (values['start'] ?? '').trim();
    if (startRaw.isEmpty) {
      throw const CalculatorFailure('Start date is required');
    }
    final start = DateTime.tryParse(startRaw);
    if (start == null) {
      throw CalculatorFailure('Invalid date: "$startRaw" (use YYYY-MM-DD)');
    }
    final n = parseField(values['n'] ?? '', key: 'amount');
    final unit = values['unit'] ?? 'days';
    final ni = n.round();
    if (ni != n) {
      throw const CalculatorFailure('Amount must be a whole number');
    }
    DateTime end;
    switch (unit) {
      case 'days':
        end = start.add(Duration(days: ni));
      case 'weeks':
        end = start.add(Duration(days: ni * 7));
      case 'months':
        end = DateTime(start.year, start.month + ni, start.day);
      default:
        end = start;
    }
    return CalculatorResult(
      primary: end.difference(start).inDays.toDouble(),
      primaryLabel: 'Days diff',
      steps: [
        'Start: $startRaw',
        'Add: $ni $unit',
        'Result: ${end.toIso8601String().substring(0, 10)}',
        'Day diff: ${end.difference(start).inDays}',
      ],
    );
  }, (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()));
}

/// Registry entry for the dateAddSubtract calculator.
const dateAddSubtractDefinition = CalculatorDefinition(
  id: 'date_add_subtract',
  name: 'Date Math',
  subtitle: 'Add or subtract days, weeks, or months from a date',
  icon: IconData(0xe425, fontFamily: 'MaterialIcons'),
  accent: Color(0xFFC2185B),
  route: '/date-math',
  category: CalculatorCategoryId.dateTime,
  inputSchema: _addInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
