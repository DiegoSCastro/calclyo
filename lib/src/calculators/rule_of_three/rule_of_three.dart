import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

/// Mode toggle exposed by the Rule of Three. Kept here (not in core) because
/// it's a calculator-specific concern.
enum RuleOfThreeKind { direct, inverse }

const _kindKey = 'kind';

const _ruleOfThreeInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'a', label: 'a', defaultValue: '2'),
    CalculatorInputField(key: 'b', label: 'b', defaultValue: '10'),
    CalculatorInputField(key: 'c', label: 'c', defaultValue: '7'),
  ],
  controls: [
    SegmentedToggleControl(
      key: _kindKey,
      options: ['Direct', 'Inverse'],
    ),
  ],
);

/// Pure rule-of-three compute function. Reads the three operands and the
/// kind toggle from the values map, returns the result wrapped in
/// [TaskEither] so the generic form view can render failures uniformly.
TaskEither<CalculatorFailure, CalculatorResult> _ruleOfThreeCompute(
  Map<String, double> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async => _solveOrThrow(values),
    (error, _) => error is CalculatorFailure
        ? error
        : CalculatorFailure(error.toString()),
  );
}

CalculatorResult _solveOrThrow(Map<String, double> values) {
  final a = values['a'];
  final b = values['b'];
  final c = values['c'];
  if (a == null || b == null || c == null) {
    throw const CalculatorFailure('All three values (a, b, c) are required');
  }
  if (a == 0) {
    throw const CalculatorFailure('Value "a" must be non-zero');
  }
  return _solve(values);
}

CalculatorResult _solve(Map<String, double> values) {
  final a = values['a']!;
  final b = values['b']!;
  final c = values['c']!;
  final kind = (values[_kindKey] ?? 0) < 0.5
      ? RuleOfThreeKind.direct
      : RuleOfThreeKind.inverse;

  final x = switch (kind) {
    RuleOfThreeKind.direct => (b * c) / a,
    RuleOfThreeKind.inverse => (a * b) / c,
  };

  final kindLabel =
      kind == RuleOfThreeKind.direct ? 'Direct' : 'Inverse';
  final steps = <String>[
    'Proportion: $kindLabel rule of three',
    'Given: a=$a, b=$b, c=$c',
    if (kind == RuleOfThreeKind.direct)
      'Formula: x = (b × c) / a'
    else
      'Formula: x = (a × b) / c',
    'Computation: x = ${x.toStringAsFixed(6)}',
  ];

  return CalculatorResult(
    primary: x,
    primaryLabel: 'x',
    steps: steps,
  );
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
  icon: const IconData(0xe1ec, fontFamily: 'MaterialIcons'), // Icons.calculate
  accent: const Color(0xFF1E88E5),
  route: '/rule-of-three',
  category: CalculatorCategoryId.math,
  inputSchema: _ruleOfThreeInputSchema,
  compute: _ruleOfThreeCompute,
  stepRenderer: _ruleOfThreeStepRenderer,
);

/// Default step renderer — a card showing the primary value and the step
/// list. Used unless the calculator overrides it for a specialised layout.
Widget _ruleOfThreeStepRenderer(
  BuildContext context,
  CalculatorResult result,
) {
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
