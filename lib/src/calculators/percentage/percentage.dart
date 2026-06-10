import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

/// PercentageMode values.
/// Percentage calculation modes.
enum PercentageMode {
  /// X is what percent of Y.
  ofWhat,

  /// X is Y percent of what.
  isWhatPercentOf,

  /// Percent change from A to B.
  change,
}

const _modeKey = 'mode';
const _modeOfWhat = 'A% of B';
const _modeIsWhatPercent = 'A is % of B';
const _modeChange = 'A→B change';

const _percentageInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'a', label: 'A', defaultValue: '10'),
    CalculatorInputField(key: 'b', label: 'B', defaultValue: '200'),
  ],
  controls: [
    SegmentedToggleControl(
      key: _modeKey,
      options: [_modeOfWhat, _modeIsWhatPercent, _modeChange],
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
  final a = parseField(values['a'] ?? '', key: 'A');
  final b = parseField(values['b'] ?? '', key: 'B');
  final modeRaw = values[_modeKey] ?? _modeOfWhat;

  final mode = switch (modeRaw) {
    _modeIsWhatPercent => PercentageMode.isWhatPercentOf,
    _modeChange => PercentageMode.change,
    _ => PercentageMode.ofWhat,
  };

  switch (mode) {
    case PercentageMode.ofWhat:
      if (a == 0) {
        throw const CalculatorFailure('Percentage A cannot be zero');
      }
      final result = (a / 100) * b;
      return CalculatorResult(
        primary: result,
        primaryLabel: 'A% of B',
        steps: [
          'Mode: A% of B',
          'Formula: result = (A / 100) × B',
          '= (${a.toStringAsFixed(2)} / 100) × ${b.toStringAsFixed(2)}',
          '= ${result.toStringAsFixed(6)}',
        ],
      );
    case PercentageMode.isWhatPercentOf:
      if (b == 0) {
        throw const CalculatorFailure('B cannot be zero');
      }
      final result = (a / b) * 100;
      return CalculatorResult(
        primary: result,
        primaryLabel: 'A is what % of B',
        steps: [
          'Mode: A is what % of B',
          'Formula: result = (A / B) × 100',
          '= (${a.toStringAsFixed(2)} / ${b.toStringAsFixed(2)}) × 100',
          '= ${result.toStringAsFixed(6)}%',
        ],
      );
    case PercentageMode.change:
      if (a == 0) {
        throw const CalculatorFailure('Original value A cannot be zero');
      }
      final diff = b - a;
      final pct = (diff / a) * 100;
      return CalculatorResult(
        primary: pct,
        primaryLabel: 'Change A→B (%)',
        steps: [
          'Mode: A→B percent change',
          'Formula: ((B − A) / A) × 100',
          '= ((${b.toStringAsFixed(2)} − ${a.toStringAsFixed(2)}) / ${a.toStringAsFixed(2)}) × 100',
          '= ${pct.toStringAsFixed(6)}%',
        ],
      );
  }
}

/// Registry entry for the percentage calculator.
const percentageDefinition = CalculatorDefinition(
  id: 'percentage',
  name: 'Percentage',
  subtitle: 'A% of B, A as % of B, % change',
  icon: IconData(0xe1ec, fontFamily: 'MaterialIcons'), // Icons.percent variant
  accent: Color(0xFF6750A4),
  route: '/percentage',
  category: CalculatorCategoryId.algebra,
  inputSchema: _percentageInputSchema,
  compute: _compute,
  stepRenderer: _genericRenderer,
);

Widget _genericRenderer(BuildContext context, CalculatorResult result) {
  final theme = Theme.of(context);
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${result.primaryLabel} = ${result.primary.toStringAsFixed(6)}',
            style: theme.textTheme.headlineSmall,
          ),
          const Divider(),
          for (final step in result.steps)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(step),
            ),
        ],
      ),
    ),
  );
}
