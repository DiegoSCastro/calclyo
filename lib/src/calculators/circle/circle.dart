import 'dart:math' as math;

import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;

enum CircleMode { fromRadius, fromDiameter, fromCircumference }

const _modeKey = 'mode';
const _modeRadius = 'Radius';
const _modeDiameter = 'Diameter';
const _modeCircumference = 'Circumference';

const _circleInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'v', label: 'value', defaultValue: '5'),
  ],
  controls: [
    SegmentedToggleControl(
      key: _modeKey,
      options: [_modeRadius, _modeDiameter, _modeCircumference],
    ),
  ],
);

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final v = parseField(values['v'] ?? '', key: 'value', allowZero: false);
      final mode = values[_modeKey] ?? _modeRadius;
      final r = switch (mode) {
        _modeRadius => v,
        _modeDiameter => v / 2,
        _modeCircumference => v / (2 * math.pi),
        _ => v,
      };
      final area = math.pi * r * r;
      final circumference = 2 * math.pi * r;
      return CalculatorResult(
        primary: area,
        primaryLabel: 'Area',
        steps: [
          'Mode: $mode, value = $v',
          'Radius r = ${r.toStringAsFixed(6)}',
          'Area = π r² = ${area.toStringAsFixed(6)}',
          'Circumference = 2π r = ${circumference.toStringAsFixed(6)}',
        ],
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const circleDefinition = CalculatorDefinition(
  id: 'circle',
  name: 'Circle',
  subtitle: 'Area and circumference from radius, diameter, or perimeter',
  icon: IconData(0xe1b1, fontFamily: 'MaterialIcons'), // Icons.category
  accent: Color(0xFF006064),
  route: '/circle',
  category: CalculatorCategoryId.geometry,
  inputSchema: _circleInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
