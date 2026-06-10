import 'dart:math' as math;

import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

/// Body kinds supported by the 3D bodies calculator.
enum BodyKind {
  /// Sphere.
  sphere,

  /// Cube.
  cube,

  /// Cylinder.
  cylinder,
}

const _kindKey = 'kind';
const _kindSphere = 'Sphere';
const _kindCube = 'Cube';
const _kindCylinder = 'Cylinder';

const _bodies3DInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(
      key: 'r',
      label: 'radius (sphere / cylinder)',
      defaultValue: '3',
    ),
    CalculatorInputField(
      key: 'h',
      label: 'height (cube / cylinder)',
      defaultValue: '5',
    ),
  ],
  controls: [
    SegmentedToggleControl(
      key: _kindKey,
      options: [_kindSphere, _kindCube, _kindCylinder],
    ),
  ],
);

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(() async {
    final r = parseField(values['r'] ?? '', key: 'r', allowZero: false);
    final h = parseField(values['h'] ?? '', key: 'h', allowZero: false);
    final kind = values[_kindKey] ?? _kindSphere;
    switch (kind) {
      case _kindSphere:
        final v = (4 / 3) * math.pi * r * r * r;
        final s = 4 * math.pi * r * r;
        return CalculatorResult(
          primary: v,
          primaryLabel: 'Volume',
          steps: [
            'Sphere, radius r = $r',
            'Volume = (4/3) π r³ = ${v.toStringAsFixed(6)}',
            'Surface = 4 π r² = ${s.toStringAsFixed(6)}',
          ],
        );
      case _kindCube:
        final v = h * h * h;
        final s = 6 * h * h;
        return CalculatorResult(
          primary: v,
          primaryLabel: 'Volume',
          steps: [
            'Cube, side a = $h',
            'Volume = a³ = ${v.toStringAsFixed(6)}',
            'Surface = 6 a² = ${s.toStringAsFixed(6)}',
          ],
        );
      case _kindCylinder:
        final v = math.pi * r * r * h;
        final s = 2 * math.pi * r * (r + h);
        return CalculatorResult(
          primary: v,
          primaryLabel: 'Volume',
          steps: [
            'Cylinder, radius r = $r, height h = $h',
            'Volume = π r² h = ${v.toStringAsFixed(6)}',
            'Surface = 2π r (r + h) = ${s.toStringAsFixed(6)}',
          ],
        );
      default:
        throw const CalculatorFailure('Unknown body kind');
    }
  }, (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()));
}

/// Registry entry for the bodies3D calculator.
const bodies3DDefinition = CalculatorDefinition(
  id: 'bodies_3d',
  name: '3D Bodies',
  subtitle: 'Volume and surface of sphere, cube, cylinder',
  icon: IconData(0xe1b1, fontFamily: 'MaterialIcons'), // Icons.category
  accent: Color(0xFF00796B),
  route: '/bodies-3d',
  category: CalculatorCategoryId.geometry,
  inputSchema: _bodies3DInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
