import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

const _intervalInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(
      key: 'a',
      label: 'start (HH:MM or HH:MM:SS)',
      defaultValue: '09:15',
      keyboardType: CalculatorKeyboardType.text,
    ),
    CalculatorInputField(
      key: 'b',
      label: 'end (HH:MM or HH:MM:SS)',
      defaultValue: '17:45',
      keyboardType: CalculatorKeyboardType.text,
    ),
  ],
);

int? _parseTime(String s) {
  final parts = s.trim().split(':');
  if (parts.length < 2 || parts.length > 3) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  if (h < 0 || h > 23 || m < 0 || m > 59) return null;
  var sec = 0;
  if (parts.length == 3) {
    final sv = int.tryParse(parts[2]);
    if (sv == null || sv < 0 || sv > 59) return null;
    sec = sv;
  }
  return h * 3600 + m * 60 + sec;
}

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(() async {
    final a = _parseTime(values['a'] ?? '');
    final b = _parseTime(values['b'] ?? '');
    if (a == null) {
      throw const CalculatorFailure('Invalid start time (use HH:MM)');
    }
    if (b == null) {
      throw const CalculatorFailure('Invalid end time (use HH:MM)');
    }
    var diff = b - a;
    if (diff < 0) {
      diff += 24 * 3600; // wrap around midnight
    }
    final h = diff ~/ 3600;
    final m = (diff % 3600) ~/ 60;
    final s = diff % 60;
    final interval = '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
    return CalculatorResult(
      primary: diff / 3600,
      primaryLabel: 'Hours',
      steps: [
        'Start: ${values['a']}',
        'End: ${values['b']}',
        'Interval: $interval',
        'Total: $diff seconds (${(diff / 3600).toStringAsFixed(4)} h)',
      ],
    );
  }, (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()));
}

/// Registry entry for the timeInterval calculator.
const timeIntervalDefinition = CalculatorDefinition(
  id: 'time_interval',
  name: 'Time Interval',
  subtitle: 'Difference between two HH:MM times',
  icon: IconData(0xe425, fontFamily: 'MaterialIcons'),
  accent: Color(0xFFD81B60),
  route: '/time-interval',
  category: CalculatorCategoryId.dateTime,
  inputSchema: _intervalInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
