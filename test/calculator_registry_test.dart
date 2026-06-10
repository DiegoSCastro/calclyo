import 'package:calclyo/src/calculator_registry.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryRegistry', () {
    test('starts with the rule of three in the math category', () {
      expect(calculatorRegistry.all, isNotEmpty);
      expect(calculatorRegistry.findById('rule-of-three'), isNotNull);
    });

    test('findByRoute resolves /rule-of-three to the same definition', () {
      final byId = calculatorRegistry.findById('rule-of-three');
      final byRoute = calculatorRegistry.findByRoute('/rule-of-three');
      expect(byRoute, isNotNull);
      expect(byRoute, same(byId));
    });

    test('findById returns null for unknown calculators', () {
      expect(calculatorRegistry.findById('not-a-calc'), isNull);
      expect(calculatorRegistry.findByRoute('/nope'), isNull);
    });

    test('groups by category in CalculatorCategoryId declaration order', () {
      final groups = calculatorRegistry.categoriesWithCalculators;
      expect(groups, isNotEmpty);
      // First group with calculators must be algebra (lowest id with content).
      expect(groups.first.category.id, CalculatorCategoryId.algebra);
      expect(
        groups.first.calculators.map((c) => c.id),
        contains('rule-of-three'),
      );
    });

    test('every calculator has a unique id and a unique route', () {
      final ids = calculatorRegistry.all.map((c) => c.id).toList();
      final routes = calculatorRegistry.all.map((c) => c.route).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate ids');
      expect(routes.toSet().length, routes.length, reason: 'duplicate routes');
    });

    test('every calculator lists itself in its own category group', () {
      for (final calc in calculatorRegistry.all) {
        final group = calculatorRegistry.categoriesWithCalculators.firstWhere(
          (g) => g.category.id == calc.category,
        );
        expect(
          group.calculators.map((c) => c.id),
          contains(calc.id),
        );
      }
    });
  });
}
