import 'package:calclyo/src/core/calculator.dart';
import 'package:flutter/material.dart';

/// Default step renderer — a card showing the primary value and the step
/// list. Used by every calculator that doesn't need a specialised layout.
Widget genericStepRenderer(BuildContext context, CalculatorResult result) {
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

/// Step renderer that shows an additional multi-line text area (used by
/// calculators whose primary answer is a long string, like a roman numeral
/// or a base-conversion).
Widget genericStepRendererWithText(
  BuildContext context,
  CalculatorResult result, {
  required String? extraText,
}) {
  final theme = Theme.of(context);
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (extraText != null) ...[
            Text(
              extraText,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
          ] else ...[
            Text(
              '${result.primaryLabel} = ${result.primary.toStringAsFixed(6)}',
              style: theme.textTheme.headlineSmall,
            ),
            const Divider(),
          ],
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

/// Standard "calculator failed" card. Computations raise
/// [CalculatorFailure] and the form view surfaces the message; this is
/// here for symmetry and to keep `try/catch` out of calculator code.
Widget errorStepRenderer(BuildContext context, CalculatorFailure failure) {
  return Card(
    color: Theme.of(context).colorScheme.errorContainer,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        failure.message,
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      ),
    ),
  );
}
