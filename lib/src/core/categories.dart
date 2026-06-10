import 'package:equatable/equatable.dart';

import 'package:calclyo/src/core/calculator.dart';

/// Domain id of a calculator category.
enum CalculatorCategoryId {
  math,
  geometry,
  finance,
  health,
  converter,
  everyday,
  science,
}

/// Static metadata for a category — what the home screen renders as the
/// parent tile. The list of calculators that belong to it is looked up from
/// the [CategoryRegistry] at render time.
class CalculatorCategory extends Equatable {
  const CalculatorCategory({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.description,
  });

  final CalculatorCategoryId id;
  final String name;
  final int iconCodePoint;
  final String description;

  @override
  List<Object?> get props => [id, name, iconCodePoint, description];
}

/// Pair of a [CalculatorCategory] with the calculators that belong to it.
class CalculatorCategoryWithCalculators extends Equatable {
  const CalculatorCategoryWithCalculators({
    required this.category,
    required this.calculators,
  });

  final CalculatorCategory category;
  final List<CalculatorDefinition> calculators;

  @override
  List<Object?> get props => [category, calculators];
}

/// Registry of every calculator exposed by the app, grouped by category.
///
/// The single source of truth for: which calculators exist, which category
/// they belong to, and what metadata to render on the home screen. Both the
/// router and the category list view read from here — there is no separate
/// per-calculator route registration step.
class CategoryRegistry {
  const CategoryRegistry(this._calculators);

  /// Build a registry from a literal list of calculator definitions. Most
  /// call sites pass the result of a top-level `const [...]` so the whole
  /// graph is const-constructible.
  // ignore: prefer_constructors_over_static_methods
  static CategoryRegistry of(List<CalculatorDefinition> calculators) =>
      CategoryRegistry(calculators);

  final List<CalculatorDefinition> _calculators;

  /// All registered calculators in declaration order.
  List<CalculatorDefinition> get all => List.unmodifiable(_calculators);

  /// All categories that have at least one registered calculator, in the
  /// declaration order of [CalculatorCategoryId]. Categories with no
  /// calculators are dropped.
  List<CalculatorCategoryWithCalculators> get categoriesWithCalculators {
    final byId = <CalculatorCategoryId, List<CalculatorDefinition>>{};
    for (final c in _calculators) {
      byId.putIfAbsent(c.category, () => []).add(c);
    }
    return CalculatorCategoryId.values
        .where(byId.containsKey)
        .map(
          (id) => CalculatorCategoryWithCalculators(
            category: _metadataFor(id),
            calculators: List.unmodifiable(byId[id]!),
          ),
        )
        .toList(growable: false);
  }

  /// Look up a calculator by its [CalculatorDefinition.id]. Returns `null` if
  /// no calculator is registered with that id.
  CalculatorDefinition? findById(String id) {
    for (final c in _calculators) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Look up a calculator by its [CalculatorDefinition.route]. Returns `null`
  /// if no calculator is registered with that route.
  CalculatorDefinition? findByRoute(String route) {
    for (final c in _calculators) {
      if (c.route == route) return c;
    }
    return null;
  }

  static CalculatorCategory _metadataFor(CalculatorCategoryId id) {
    switch (id) {
      case CalculatorCategoryId.math:
        return const CalculatorCategory(
          id: CalculatorCategoryId.math,
          name: 'Math',
          iconCodePoint: 0xe1ec, // Icons.calculate
          description: 'Algebra, trigonometry, percentages, fractions',
        );
      case CalculatorCategoryId.geometry:
        return const CalculatorCategory(
          id: CalculatorCategoryId.geometry,
          name: 'Geometry',
          iconCodePoint: 0xe1b1, // Icons.category
          description: 'Area, volume, perimeter, triangles, circles',
        );
      case CalculatorCategoryId.finance:
        return const CalculatorCategory(
          id: CalculatorCategoryId.finance,
          name: 'Finance',
          iconCodePoint: 0xe227, // Icons.attach_money
          description: 'Loans, interest, tips, discounts, ROI',
        );
      case CalculatorCategoryId.health:
        return const CalculatorCategory(
          id: CalculatorCategoryId.health,
          name: 'Health',
          iconCodePoint: 0xe87d, // Icons.favorite
          description: 'BMI, BMR, ideal weight — for reference only',
        );
      case CalculatorCategoryId.converter:
        return const CalculatorCategory(
          id: CalculatorCategoryId.converter,
          name: 'Unit Converter',
          iconCodePoint: 0xe8d5, // Icons.swap_horiz
          description: 'Length, weight, temperature, time, currency',
        );
      case CalculatorCategoryId.everyday:
        return const CalculatorCategory(
          id: CalculatorCategoryId.everyday,
          name: 'Everyday',
          iconCodePoint: 0xe865, // Icons.schedule
          description: 'Date math, time zones, countdowns, age',
        );
      case CalculatorCategoryId.science:
        return const CalculatorCategory(
          id: CalculatorCategoryId.science,
          name: 'Science',
          iconCodePoint: 0xea4b, // Icons.science
          description: 'Physics constants, conversions, formulas',
        );
    }
  }
}
