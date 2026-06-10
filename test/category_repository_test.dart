import 'package:flutter_test/flutter_test.dart';

import 'package:calclyo/src/features/category/data/category_repository.dart';
import 'package:calclyo/src/features/category/domain/calculator_category.dart';

void main() {
  group('CategoryRepository', () {
    final repo = CategoryRepository();

    test('loads at least one category', () async {
      final result = await repo.getCategories().run();
      final categories = result.getOrElse((_) => throw StateError('expected right'));
      expect(categories, isNotEmpty);
    });

    test('seed has math category with rule of three', () async {
      final result = await repo.getCategories().run();
      final categories = result.getOrElse((_) => throw StateError('expected right'));
      final math = categories.firstWhere((c) => c.id == CategoryId.math);
      expect(math.calculators, isNotEmpty);
      expect(math.calculators.first.id, 'rule-of-three');
    });
  });
}
