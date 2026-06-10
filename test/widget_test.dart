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
    test('only algebra is populated in v0.2', () {
      // v0.2 only ships Rule of Three. t_0680951d adds the remaining 34.
      final ids = calculatorRegistry.categoriesWithCalculators
          .map((g) => g.category.id)
          .toSet();
      expect(ids, {CalculatorCategoryId.algebra});
    });
  });

  testWidgets('AppShell home shows the Algebra section header and the '
      'Rule of Three tile', (tester) async {
    await tester.pumpWidget(const CalclyoApp());
    await tester.pumpAndSettle();

    // The avatar header is present.
    expect(find.text('Sign in'), findsOneWidget);

    // The Algebra section header (rendered uppercase).
    expect(find.text('ALGEBRA'), findsOneWidget);

    // The Rule of Three tile is on the home screen.
    expect(find.text('Rule of Three'), findsOneWidget);
  });

  testWidgets('tapping a calculator tile navigates to its form view',
      (tester) async {
    await tester.pumpWidget(const CalclyoApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rule of Three'));
    await tester.pumpAndSettle();

    // CalculatorFormView renders the calc name in the app bar.
    expect(find.text('Rule of Three'), findsWidgets);
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
