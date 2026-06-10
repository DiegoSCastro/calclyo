import 'dart:math' as math;

import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;

enum EquationKind { linear, quadratic, system2x2 }

const _kindKey = 'kind';
const _kindLinear = 'Linear (ax + b = c)';
const _kindQuadratic = 'Quadratic (ax² + bx + c = 0)';
const _kindSystem = '2×2 System';

const _equationsInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'a', label: 'a', defaultValue: '2'),
    CalculatorInputField(key: 'b', label: 'b', defaultValue: '3'),
    CalculatorInputField(key: 'c', label: 'c', defaultValue: '7'),
    CalculatorInputField(key: 'd', label: 'd (system only)', defaultValue: '1'),
    CalculatorInputField(key: 'e', label: 'e (system only)', defaultValue: '5'),
    CalculatorInputField(key: 'f', label: 'f (system only)', defaultValue: '8'),
  ],
  controls: [
    SegmentedToggleControl(
      key: _kindKey,
      options: [_kindLinear, _kindQuadratic, _kindSystem],
    ),
  ],
);

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async => _solve(values),
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

CalculatorResult _solve(Map<String, String> values) {
  final a = parseField(values['a'] ?? '', key: 'a');
  final b = parseField(values['b'] ?? '', key: 'b');
  final c = parseField(values['c'] ?? '', key: 'c');
  // d/e/f are only required for the 2×2 system mode. For other modes
  // they're allowed to be blank.
  final kind = values[_kindKey] ?? _kindLinear;

  switch (kind) {
    case _kindLinear:
      // ax + b = c  →  x = (c − b) / a
      if (a == 0) {
        throw const CalculatorFailure('Coefficient a must be non-zero');
      }
      final x = (c - b) / a;
      return CalculatorResult(
        primary: x,
        primaryLabel: 'x',
        steps: [
          'Linear: a·x + b = c',
          'Given: a=$a, b=$b, c=$c',
          'Formula: x = (c − b) / a',
          '= (${c.toStringAsFixed(2)} − ${b.toStringAsFixed(2)}) / '
              '${a.toStringAsFixed(2)}',
          'x = ${x.toStringAsFixed(6)}',
        ],
      );
    case _kindQuadratic:
      // ax² + bx + c = 0
      if (a == 0) {
        throw const CalculatorFailure('Coefficient a must be non-zero');
      }
      final disc = b * b - 4 * a * c;
      if (disc < 0) {
        throw CalculatorFailure(
          'No real roots (discriminant = ${disc.toStringAsFixed(4)})',
        );
      }
      final sqrtD = math.sqrt(disc);
      final x1 = (-b + sqrtD) / (2 * a);
      final x2 = (-b - sqrtD) / (2 * a);
      final primary = disc == 0 ? x1 : math.max(x1.abs(), x2.abs());
      return CalculatorResult(
        primary: primary,
        primaryLabel: disc == 0 ? 'x' : '|x|',
        steps: [
          'Quadratic: a·x² + b·x + c = 0',
          'Given: a=$a, b=$b, c=$c',
          'Discriminant: Δ = b² − 4ac = '
              '${b.toStringAsFixed(2)}² − 4·${a.toStringAsFixed(2)}·'
              '${c.toStringAsFixed(2)} = ${disc.toStringAsFixed(4)}',
          if (disc == 0) 'Δ = 0 → one real root'
          else 'Δ > 0 → two real roots',
          'x = (−b ± √Δ) / 2a',
          'x₁ = ${x1.toStringAsFixed(6)}',
          'x₂ = ${x2.toStringAsFixed(6)}',
        ],
      );
    case _kindSystem:
      final d = parseField(values['d'] ?? '', key: 'd');
      final e = parseField(values['e'] ?? '', key: 'e');
      final f = parseField(values['f'] ?? '', key: 'f');
      // ax + by = c ; dx + ey = f
      final det = a * e - b * d;
      if (det == 0) {
        throw const CalculatorFailure(
          'No unique solution (determinant is zero)',
        );
      }
      final x = (c * e - b * f) / det;
      final y = (a * f - c * d) / det;
      return CalculatorResult(
        primary: x,
        primaryLabel: 'x',
        steps: [
          '2×2 system:',
          '  ${a.toStringAsFixed(2)}x + ${b.toStringAsFixed(2)}y = '
              '${c.toStringAsFixed(2)}',
          '  ${d.toStringAsFixed(2)}x + ${e.toStringAsFixed(2)}y = '
              '${f.toStringAsFixed(2)}',
          'Determinant: D = a·e − b·d = '
              '${(a * e).toStringAsFixed(4)} − ${(b * d).toStringAsFixed(4)} '
              '= ${det.toStringAsFixed(4)}',
          'x = (c·e − b·f) / D = ${x.toStringAsFixed(6)}',
          'y = (a·f − c·d) / D = ${y.toStringAsFixed(6)}',
        ],
      );
    default:
      throw const CalculatorFailure('Unknown equation kind');
  }
}

const equationsDefinition = CalculatorDefinition(
  id: 'equations',
  name: 'Equations',
  subtitle: 'Linear, quadratic, and 2×2 systems',
  icon: IconData(0xe1ec, fontFamily: 'MaterialIcons'), // Icons.calculate
  accent: Color(0xFF512DA8),
  route: '/equations',
  category: CalculatorCategoryId.algebra,
  inputSchema: _equationsInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
