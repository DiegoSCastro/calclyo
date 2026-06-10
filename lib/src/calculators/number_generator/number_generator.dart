import 'dart:math' as math;

import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;

enum GeneratorKind { randomInt, arithmeticSeq, geometricSeq }

const _kindKey = 'kind';
const _kindRandom = 'Random int';
const _kindArith = 'Arithmetic sequence';
const _kindGeom = 'Geometric sequence';

const _numberGeneratorInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'min', label: 'min', defaultValue: '1'),
    CalculatorInputField(key: 'max', label: 'max', defaultValue: '100'),
    CalculatorInputField(key: 'first', label: 'first term', defaultValue: '1'),
    CalculatorInputField(key: 'step', label: 'step / ratio', defaultValue: '2'),
    CalculatorInputField(key: 'count', label: 'count', defaultValue: '5'),
  ],
  controls: [
    SegmentedToggleControl(
      key: _kindKey,
      options: [_kindRandom, _kindArith, _kindGeom],
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
  final min = parseField(values['min'] ?? '', key: 'min');
  final max = parseField(values['max'] ?? '', key: 'max');
  final first = parseField(values['first'] ?? '', key: 'first');
  final step = parseField(values['step'] ?? '', key: 'step');
  final countRaw = parseField(values['count'] ?? '', key: 'count');
  final count = countRaw.round();
  if (count != countRaw || count <= 0 || count > 50) {
    throw const CalculatorFailure('count must be a positive integer ≤ 50');
  }
  final kind = values[_kindKey] ?? _kindRandom;

  switch (kind) {
    case _kindRandom:
      if (min > max) {
        throw const CalculatorFailure('min must be ≤ max');
      }
      final lo = min.round();
      final hi = max.round();
      final r = lo + math.Random().nextInt(hi - lo + 1);
      return CalculatorResult(
        primary: r.toDouble(),
        primaryLabel: 'Random',
        steps: [
          'Range: [$lo, $hi]',
          'Picked: $r',
        ],
      );
    case _kindArith:
      final terms = <double>[];
      for (var i = 0; i < count; i++) {
        terms.add(first + step * i);
      }
      return CalculatorResult(
        primary: terms.last,
        primaryLabel: 'Last term',
        steps: [
          'a₁ = $first, d = $step',
          for (var i = 0; i < count; i++)
            'a${i + 1} = ${terms[i].toStringAsFixed(4)}',
          'Last: ${terms.last.toStringAsFixed(4)}',
        ],
      );
    case _kindGeom:
      if (step == 0) {
        throw const CalculatorFailure('Geometric ratio cannot be zero');
      }
      final terms = <double>[];
      for (var i = 0; i < count; i++) {
        terms.add(first * math.pow(step, i).toDouble());
      }
      return CalculatorResult(
        primary: terms.last,
        primaryLabel: 'Last term',
        steps: [
          'a₁ = $first, r = $step',
          for (var i = 0; i < count; i++)
            'a${i + 1} = ${terms[i].toStringAsFixed(4)}',
          'Last: ${terms.last.toStringAsFixed(4)}',
        ],
      );
    default:
      throw const CalculatorFailure('Unknown generator kind');
  }
}

const numberGeneratorDefinition = CalculatorDefinition(
  id: 'number_generator',
  name: 'Number Generator',
  subtitle: 'Random int, arithmetic or geometric sequences',
  icon: IconData(0xe1ec, fontFamily: 'MaterialIcons'), // Icons.calculate
  accent: Color(0xFF1A237E),
  route: '/number-generator',
  category: CalculatorCategoryId.algebra,
  inputSchema: _numberGeneratorInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
