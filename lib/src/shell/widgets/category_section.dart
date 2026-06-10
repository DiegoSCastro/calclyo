import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// One section in the home screen: an uppercase header followed by a list
/// of calculator [ListTile]s. Replaces the v0.1 [ExpansionTile] layout.
class CategorySection extends StatelessWidget {
  /// Creates [CategorySection].
  const CategorySection({required this.entry, super.key});

  /// entry.
  final CalculatorCategoryWithCalculators entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            entry.category.name.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.secondary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        for (final calc in entry.calculators) _CalculatorTile(calc: calc),
      ],
    );
  }
}

class _CalculatorTile extends StatelessWidget {
  const _CalculatorTile({required this.calc});

  final CalculatorDefinition calc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(calc.icon, color: calc.accent),
      title: Text(calc.name),
      subtitle: Text(calc.subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(calc.route),
      tileColor: theme.colorScheme.surface,
    );
  }
}
