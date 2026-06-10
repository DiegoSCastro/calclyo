import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

/// Mode toggle exposed by the Rule of Three. Kept here (not in core) because
/// it's a calculator-specific concern.
/// Rule-of-three kinds.
enum RuleOfThreeKind {
  /// Direct proportion.
  direct,

  /// Inverse proportion.
  inverse,
}

const _kindKey = 'kind';
const _kindDirect = 'Direct';
const _kindInverse = 'Inverse';

const _ruleOfThreeInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'a', label: 'a', defaultValue: '2'),
    CalculatorInputField(key: 'b', label: 'b', defaultValue: '10'),
    CalculatorInputField(key: 'c', label: 'c', defaultValue: '7'),
  ],
  controls: [
    SegmentedToggleControl(key: _kindKey, options: [_kindDirect, _kindInverse]),
  ],
);

/// Parse a numeric form field, returning a [CalculatorFailure] for blank or
/// non-numeric input. Kept here so each calculator doesn't reinvent it.
double parseField(String raw, {required String key, bool allowZero = true}) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    throw CalculatorFailure('"$key" is required');
  }
  final v = double.tryParse(trimmed);
  if (v == null) {
    throw CalculatorFailure('"$key" is not a valid number');
  }
  if (!allowZero && v == 0) {
    throw CalculatorFailure('"$key" must be non-zero');
  }
  return v;
}

/// Pure rule-of-three compute function. Reads the three operands and the
/// kind toggle from the values map, returns the result wrapped in
/// [TaskEither] so the generic form view can render failures uniformly.
TaskEither<CalculatorFailure, CalculatorResult> _ruleOfThreeCompute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async => _solveOrThrow(values),
    (error, _) => error is CalculatorFailure
        ? error
        : CalculatorFailure(error.toString()),
  );
}

CalculatorResult _solveOrThrow(Map<String, String> values) {
  final a = parseField(values['a'] ?? '', key: 'a', allowZero: false);
  final b = parseField(values['b'] ?? '', key: 'b');
  final c = parseField(values['c'] ?? '', key: 'c');
  return _solve(a, b, c, values[_kindKey] ?? _kindDirect);
}

CalculatorResult _solve(double a, double b, double c, String kindRaw) {
  final kind = kindRaw == _kindInverse
      ? RuleOfThreeKind.inverse
      : RuleOfThreeKind.direct;

  final x = switch (kind) {
    RuleOfThreeKind.direct => (b * c) / a,
    RuleOfThreeKind.inverse => (a * b) / c,
  };

  final kindLabel = kind == RuleOfThreeKind.direct ? 'Direct' : 'Inverse';
  final steps = <String>[
    'Proportion: $kindLabel rule of three',
    'Given: a=$a, b=$b, c=$c',
    if (kind == RuleOfThreeKind.direct)
      'Formula: x = (b × c) / a'
    else
      'Formula: x = (a × b) / c',
    'Computation: x = ${x.toStringAsFixed(6)}',
  ];

  return CalculatorResult(primary: x, primaryLabel: 'x', steps: steps);
}

/// The Rule of Three calculator, exposed as a single [CalculatorDefinition].
///
/// This file owns everything: the input schema, the compute logic, the
/// step renderer, and the route. Adding a new calculator = new file, new
/// const instance, drop into the registry. Nothing else changes.
const ruleOfThreeDefinition = CalculatorDefinition(
  id: 'rule-of-three',
  name: 'Rule of Three',
  subtitle: 'Solve direct and inverse proportions',
  icon: IconData(0xe1ec, fontFamily: 'MaterialIcons'), // Icons.calculate
  accent: Color(0xFF1E88E5),
  route: '/rule-of-three',
  category: CalculatorCategoryId.algebra,
  inputSchema: _ruleOfThreeInputSchema,
  compute: _ruleOfThreeCompute,
  stepRenderer: _ruleOfThreeStepRenderer,
);

/// Default step renderer — a card showing the primary value and the step
/// list. Used unless the calculator overrides it for a specialised layout.
Widget _ruleOfThreeStepRenderer(BuildContext context, CalculatorResult result) {
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
