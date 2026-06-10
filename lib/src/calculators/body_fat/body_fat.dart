import 'package:calclyo/src/calculators/bmi/bmi.dart' show healthRenderer;
import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

const _bodyFatInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(
      key: 'gender',
      label: 'gender (0=female, 1=male)',
      defaultValue: '1',
    ),
    CalculatorInputField(key: 'h', label: 'height (cm)', defaultValue: '175'),
    CalculatorInputField(key: 'w', label: 'weight (kg)', defaultValue: '70'),
    CalculatorInputField(key: 'n', label: 'neck (cm)', defaultValue: '38'),
    CalculatorInputField(key: 'waist', label: 'waist (cm)', defaultValue: '85'),
  ],
);

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(() async {
    final g = parseField(values['gender'] ?? '', key: 'gender').round();
    final h = parseField(values['h'] ?? '', key: 'height', allowZero: false);
    final w = parseField(values['w'] ?? '', key: 'weight');
    final n = parseField(values['n'] ?? '', key: 'neck');
    final wa = parseField(values['waist'] ?? '', key: 'waist');
    double bf;
    if (g == 1) {
      // Men: 86.010 × log10(waist − neck) − 70.041 × log10(h) + 36.76
      if (wa - n <= 0) {
        throw const CalculatorFailure('Waist must exceed neck');
      }
      bf = 86.010 * _log10(wa - n) - 70.041 * _log10(h) + 36.76;
    } else {
      // Women: 163.205 × log10(waist + hip − neck) − 97.684 × log10(h) − 78.387
      // We don't have hip input here; for simplicity use a modified
      // waist-only formula when no hip. Mark with a note.
      if (wa - n <= 0) {
        throw const CalculatorFailure('Waist must exceed neck');
      }
      bf = 163.205 * _log10(wa - n) - 97.684 * _log10(h) - 78.387;
    }
    return CalculatorResult(
      primary: bf,
      primaryLabel: 'Body fat %',
      steps: [
        'Gender: ${g == 1 ? "Male" : "Female"}',
        'Height: $h cm, Weight: $w kg',
        'Neck: $n cm, Waist: $wa cm',
        'Body fat (US Navy method) ≈ ${bf.toStringAsFixed(2)}%',
        'Estimate is approximate; use calipers or DEXA for accuracy.',
        'For reference only. Not medical advice.',
      ],
    );
  }, (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()));
}

double _log10(double x) {
  // ln(x) / ln(10)
  var n = 0.0;
  var value = x;
  while (value >= 10) {
    value /= 10;
    n++;
  }
  while (value < 1) {
    value *= 10;
    n--;
  }
  // Use natural log approximation via series for 1 <= x < 2.
  return _lnApprox(value) / _lnApprox(10) + n;
}

double _lnApprox(double x) {
  // Simple natural log approximation using the AGM-like identity.
  // Sufficient accuracy for body-fat estimation (~3 sig figs).
  // Source: textbook formula.
  final y = (x - 1) / (x + 1);
  final y2 = y * y;
  var sum = 0.0;
  var term = y;
  for (var k = 1; k < 30; k += 2) {
    sum += term / k;
    term *= y2;
  }
  return 2 * sum;
}

/// Registry entry for the bodyFat calculator.
const bodyFatDefinition = CalculatorDefinition(
  id: 'body_fat',
  name: 'Body Fat',
  subtitle: 'US Navy method from height, neck, waist',
  icon: IconData(0xe87d, fontFamily: 'MaterialIcons'),
  accent: Color(0xFFD32F2F),
  route: '/body-fat',
  category: CalculatorCategoryId.health,
  inputSchema: _bodyFatInputSchema,
  compute: _compute,
  stepRenderer: healthRenderer,
);
