import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

const _tipInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'bill', label: 'bill', defaultValue: '50'),
    CalculatorInputField(key: 'pct', label: 'tip %', defaultValue: '18'),
  ],
);

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(() async {
    final bill = parseField(values['bill'] ?? '', key: 'bill');
    final pct = parseField(values['pct'] ?? '', key: 'pct');
    final tip = bill * pct / 100;
    final total = bill + tip;
    return CalculatorResult(
      primary: tip,
      primaryLabel: 'Tip',
      steps: [
        'Bill: $bill',
        'Tip %: $pct',
        'Tip = Bill × Pct / 100 = ${tip.toStringAsFixed(6)}',
        'Total = Bill + Tip = ${total.toStringAsFixed(6)}',
      ],
    );
  }, (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()));
}

/// Registry entry for the tip calculator.
const tipDefinition = CalculatorDefinition(
  id: 'tip',
  name: 'Tip',
  subtitle: 'Tip amount and total from bill and percentage',
  icon: IconData(0xe227, fontFamily: 'MaterialIcons'),
  accent: Color(0xFF43A047),
  route: '/tip',
  category: CalculatorCategoryId.finance,
  inputSchema: _tipInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
