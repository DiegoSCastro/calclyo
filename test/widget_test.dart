import 'package:calclyo/app/app.dart';
import 'package:calclyo/src/calculator_registry.dart';
import 'package:calclyo/src/calculators/form_view.dart';
import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart';
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

    test('registry returns one entry per registered calculator (v0.2)', () {
      expect(calculatorRegistry.all.length, greaterThanOrEqualTo(35));
    });
  });

  testWidgets('CalclyoApp boots and shows the home screen', (tester) async {
    await tester.pumpWidget(const CalclyoApp());
    await tester.pump();
    // The v0.2 shell shows the algebra category header, not the app title.
    expect(find.text('ALGEBRA'), findsOneWidget);
    expect(find.text('Rule of Three'), findsOneWidget);
  });

  testWidgets('CalculatorFormView renders the rule of three form', (
    tester,
  ) async {
    // Mount the generic form view directly with the const definition.
    const definition = ruleOfThreeDefinition;
    await tester.pumpWidget(
      const MaterialApp(home: CalculatorFormView(definition: definition)),
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
