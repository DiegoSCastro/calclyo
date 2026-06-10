import 'package:calclyo/src/features/category/domain/calculator_category.dart';
import 'package:calclyo/src/features/category/presentation/cubit/category_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CategoryListView extends StatelessWidget {
  const CategoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calclyo'),
        centerTitle: false,
      ),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          return switch (state) {
            CategoryInitial() || CategoryLoading() =>
              const Center(child: CircularProgressIndicator()),
            CategoryError(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Error: $message'),
                ),
              ),
            CategoryLoaded(:final categories) => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) =>
                    _CategoryTile(category: categories[i]),
              ),
          };
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});
  final CalculatorCategory category;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Icon(IconData(category.iconCodePoint, fontFamily: 'MaterialIcons')),
        title: Text(category.name),
        subtitle: Text(category.description),
        children: category.calculators.map((calc) {
          return ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: Text(calc.name),
            subtitle: Text(calc.subtitle),
            onTap: () => context.go(calc.route),
          );
        }).toList(),
      ),
    );
  }
}
