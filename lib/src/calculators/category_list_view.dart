import 'package:calclyo/src/calculator_registry.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Home screen — the category-driven list of calculators. Reads directly
/// from [calculatorRegistry] (no async load, no cubit, no repository).
class CategoryListView extends StatelessWidget {
  const CategoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = calculatorRegistry.categoriesWithCalculators;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calclyo'),
        centerTitle: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _CategoryTile(entry: categories[i]),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.entry});
  final CalculatorCategoryWithCalculators entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Icon(
          IconData(entry.category.iconCodePoint, fontFamily: 'MaterialIcons'),
        ),
        title: Text(entry.category.name),
        subtitle: Text(entry.category.description),
        children: entry.calculators.map((calc) {
          return ListTile(
            leading: Icon(calc.icon),
            title: Text(calc.name),
            subtitle: Text(calc.subtitle),
            onTap: () => context.go(calc.route),
          );
        }).toList(),
      ),
    );
  }
}
