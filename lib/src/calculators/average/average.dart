import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

const _averageInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(
      key: 'values',
      label: 'Comma-separated numbers (e.g. 2, 4, 6, 8)',
      defaultValue: '2, 4, 6, 8',
      keyboardType: CalculatorKeyboardType.text,
    ),
  ],
);

/// Parse a comma-separated list of numbers and return them. Throws
/// [CalculatorFailure] on bad input.
List<double> parseNumbers(String raw) {
  final parts = raw
      .split(',')
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty);
  final result = <double>[];
  for (final p in parts) {
    final v = double.tryParse(p);
    if (v == null) {
      throw CalculatorFailure('Not a number: "$p"');
    }
    result.add(v);
  }
  if (result.isEmpty) {
    throw const CalculatorFailure('Need at least one number');
  }
  return result;
}

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final raw = values['values'] ?? '';
      final nums = parseNumbers(raw);
      final sum = nums.fold<double>(0, (a, b) => a + b);
      final mean = sum / nums.length;
      return CalculatorResult(
        primary: mean,
        primaryLabel: 'Mean',
        steps: [
          'Numbers: ${nums.map((n) => n.toStringAsFixed(2)).toList()}',
          'Sum = ${sum.toStringAsFixed(6)}',
          'Count = ${nums.length}',
          'Mean = Sum / Count = '
              '${sum.toStringAsFixed(6)} / ${nums.length} = '
              '${mean.toStringAsFixed(6)}',
        ],
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const averageDefinition = CalculatorDefinition(
  id: 'average',
  name: 'Average',
  subtitle: 'Arithmetic mean of a list of numbers',
  icon: IconData(0xe1ec, fontFamily: 'MaterialIcons'), // Icons.calculate
  accent: Color(0xFF006A60),
  route: '/average',
  category: CalculatorCategoryId.algebra,
  inputSchema: _averageInputSchema,
  compute: _compute,
  stepRenderer: _renderer,
);

Widget _renderer(BuildContext context, CalculatorResult result) {
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
