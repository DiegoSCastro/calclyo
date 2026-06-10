import 'package:calclyo/app/app.dart';
import 'package:calclyo/src/calculator_registry.dart';
import 'package:calclyo/src/calculators/form_view.dart';
import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalculatorDefinition equality (Equatable)', () {
    test('two const instances of the same calculator are equal', () {
      const a = ruleOfThreeDefinition;
      const b = ruleOfThreeDefinition;
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('registry returns one entry per registered calculator', () {
      expect(calculatorRegistry.all, hasLength(1));
    });
  });

  group('CategoryRegistry.categoriesWithCalculators', () {
    test('drops categories with no calculators', () {
      // Only math has a calculator registered — geometry, finance, etc.
      // should be absent from the grouped list.
      final ids = calculatorRegistry.categoriesWithCalculators
          .map((g) => g.category.id)
          .toSet();
      expect(ids, {CalculatorCategoryId.math});
    });
  });

  testWidgets('CalclyoApp boots and shows the home screen', (tester) async {
    await tester.pumpWidget(const CalclyoApp());
    await tester.pump();
    expect(find.text('Calclyo'), findsOneWidget);
  });

  testWidgets('tapping the math category expands to show its calculators',
      (tester) async {
    await tester.pumpWidget(const CalclyoApp());
    await tester.pump();

    // The Math category tile is rendered; tap to expand.
    expect(find.text('Math'), findsOneWidget);
    await tester.tap(find.text('Math'));
    await tester.pumpAndSettle();

    // The Rule of Three tile is now visible.
    expect(find.text('Rule of Three'), findsOneWidget);
  });

  testWidgets('CalculatorFormView renders the rule of three form',
      (tester) async {
    // Mount the generic form view directly with the const definition.
    const definition = ruleOfThreeDefinition;
    await tester.pumpWidget(
      const MaterialApp(
        home: CalculatorFormView(definition: definition),
      ),
    );
    await tester.pump();

    expect(find.text(definition.name), findsOneWidget);
    // Three numeric input fields labelled a / b / c.
    expect(find.text('a'), findsOneWidget);
    expect(find.text('b'), findsOneWidget);
    expect(find.text('c'), findsOneWidget);
    // Direct / Inverse segmented toggle.
    expect(find.text('Direct'), findsOneWidget);
    expect(find.text('Inverse'), findsOneWidget);
  });
}
