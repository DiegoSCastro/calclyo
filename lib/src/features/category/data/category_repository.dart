import 'package:fpdart/fpdart.dart';

import '../domain/calculator_category.dart';

class CategoryRepositoryFailure implements Exception {
  const CategoryRepositoryFailure(this.message);
  final String message;
  @override
  String toString() => 'CategoryRepositoryFailure: $message';
}

class CategoryRepository {
  const CategoryRepository();

  TaskEither<CategoryRepositoryFailure, List<CalculatorCategory>>
      getCategories() {
    return TaskEither.tryCatch(
      () async => _seed(),
      (error, _) => CategoryRepositoryFailure(error.toString()),
    );
  }

  List<CalculatorCategory> _seed() {
    return const [
      CalculatorCategory(
        id: CategoryId.math,
        name: 'Math',
        iconCodePoint: 0xe1ec, // Icons.calculate
        description: 'Algebra, trigonometry, percentages, fractions',
        calculators: [
          CalculatorEntry(
            id: 'rule-of-three',
            name: 'Rule of Three',
            subtitle: 'Solve direct and inverse proportions',
            route: '/rule-of-three',
          ),
        ],
      ),
      CalculatorCategory(
        id: CategoryId.geometry,
        name: 'Geometry',
        iconCodePoint: 0xe1b1, // Icons.category
        description: 'Area, volume, perimeter, triangles, circles',
        calculators: [],
      ),
      CalculatorCategory(
        id: CategoryId.finance,
        name: 'Finance',
        iconCodePoint: 0xe227, // Icons.attach_money
        description: 'Loans, interest, tips, discounts, ROI',
        calculators: [],
      ),
      CalculatorCategory(
        id: CategoryId.health,
        name: 'Health',
        iconCodePoint: 0xe87d, // Icons.favorite
        description: 'BMI, BMR, ideal weight — for reference only',
        calculators: [],
      ),
      CalculatorCategory(
        id: CategoryId.converter,
        name: 'Unit Converter',
        iconCodePoint: 0xe8d5, // Icons.swap_horiz
        description: 'Length, weight, temperature, time, currency',
        calculators: [],
      ),
      CalculatorCategory(
        id: CategoryId.everyday,
        name: 'Everyday',
        iconCodePoint: 0xe865, // Icons.schedule
        description: 'Date math, time zones, countdowns, age',
        calculators: [],
      ),
      CalculatorCategory(
        id: CategoryId.science,
        name: 'Science',
        iconCodePoint: 0xea4b, // Icons.science
        description: 'Physics constants, conversions, formulas',
        calculators: [],
      ),
    ];
  }
}
