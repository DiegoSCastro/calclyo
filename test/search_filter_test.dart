import 'package:calclyo/src/calculator_registry.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:calclyo/src/features/search/search_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Build a tiny, deterministic group fixture instead of leaning on the full
  // 46-calculator registry — keeps the test fast and the assertions
  // obviously correct.
  const algebra = CalculatorCategory(
    id: CalculatorCategoryId.algebra,
    name: 'Algebra',
    iconCodePoint: 0xe1ec,
    description: '',
  );
  const finance = CalculatorCategory(
    id: CalculatorCategoryId.finance,
    name: 'Finance',
    iconCodePoint: 0xe227,
    description: '',
  );
  const health = CalculatorCategory(
    id: CalculatorCategoryId.health,
    name: 'Health',
    iconCodePoint: 0xe87d,
    description: '',
  );

  CalculatorDefinition def({
    required String id,
    required String name,
    required String subtitle,
    required CalculatorCategoryId cat,
  }) {
    return CalculatorDefinition(
      id: id,
      name: name,
      subtitle: subtitle,
      icon: Icons.calculate,
      accent: Colors.blue,
      route: '/$id',
      category: cat,
      inputSchema: const CalculatorInputSchema(),
      compute: (_) => throw UnimplementedError(),
      stepRenderer: (_, __) => const SizedBox.shrink(),
    );
  }

  final groups = <CalculatorCategoryWithCalculators>[
    CalculatorCategoryWithCalculators(
      category: algebra,
      calculators: [
        def(
          id: 'bmi',
          name: 'BMI',
          subtitle: 'Body mass index',
          cat: CalculatorCategoryId.algebra,
        ),
        def(
          id: 'percentage',
          name: 'Percentage',
          subtitle: 'x% of y',
          cat: CalculatorCategoryId.algebra,
        ),
      ],
    ),
    CalculatorCategoryWithCalculators(
      category: finance,
      calculators: [
        def(
          id: 'tip',
          name: 'Tip',
          subtitle: 'Restaurant gratuity',
          cat: CalculatorCategoryId.finance,
        ),
      ],
    ),
    CalculatorCategoryWithCalculators(
      category: health,
      calculators: [
        def(
          id: 'bmi2',
          name: 'Body Fat',
          subtitle: 'Body composition',
          cat: CalculatorCategoryId.health,
        ),
      ],
    ),
  ];

  group('filterCalculators', () {
    test('empty query returns no groups (recents UX, not "show all")', () {
      final result = filterCalculators(query: '', groups: groups);
      expect(result, isEmpty);
    });

    test('case-insensitive substring match on name and subtitle', () {
      // Query "fat" matches:
      //   - Body Fat (name contains "fat", case-insensitive)
      // It must NOT match "BMI" or "Percentage" or "Tip".
      final result = filterCalculators(query: 'fat', groups: groups);
      final ids = result.expand((g) => g.calculators.map((c) => c.id)).toList();
      expect(ids, ['bmi2']);
    });

    test('lowercases both sides for comparison', () {
      final result = filterCalculators(query: 'PERCENT', groups: groups);
      expect(result, hasLength(1));
      expect(result.first.calculators.single.id, 'percentage');
    });

    test('subtitle match works independently of name', () {
      // "mass" appears only in the subtitle of the algebra "BMI"
      // calculator ("Body mass index") — not in the name of "Body Fat".
      final result = filterCalculators(query: 'mass', groups: groups);
      final ids = result.expand((g) => g.calculators.map((c) => c.id)).toList();
      expect(ids, ['bmi']);
    });

    test('drops empty groups from the result', () {
      final result = filterCalculators(query: 'tip', groups: groups);
      expect(result, hasLength(1));
      expect(result.first.category.id, CalculatorCategoryId.finance);
    });

    test('whitespace-only query is treated as empty', () {
      final result = filterCalculators(query: '   ', groups: groups);
      expect(result, isEmpty);
    });

    test('trims surrounding whitespace from query', () {
      final result = filterCalculators(query: '  tip  ', groups: groups);
      expect(result.single.calculators.single.id, 'tip');
    });

    test('no match yields empty result list', () {
      final result = filterCalculators(query: 'zzz', groups: groups);
      expect(result, isEmpty);
    });
  });

  // Sanity check: the live registry must produce results for a real query.
  test('live registry filter for "tip" finds the tip calculator', () {
    final result = filterCalculators(
      query: 'tip',
      groups: calculatorRegistry.categoriesWithCalculators,
    );
    final ids = result.expand((g) => g.calculators.map((c) => c.id)).toList();
    expect(ids, contains('tip'));
  });
}
