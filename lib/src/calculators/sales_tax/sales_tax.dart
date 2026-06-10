import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;

const _salesTaxInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'price', label: 'pre-tax price', defaultValue: '100'),
    CalculatorInputField(key: 'rate', label: 'tax rate (%)', defaultValue: '8.5'),
  ],
);

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final price = parseField(values['price'] ?? '', key: 'price');
      final rate = parseField(values['rate'] ?? '', key: 'rate');
      final tax = price * rate / 100;
      final total = price + tax;
      return CalculatorResult(
        primary: total,
        primaryLabel: 'Total',
        steps: [
          'Price: $price',
          'Rate: $rate%',
          'Tax = Price × Rate / 100 = ${tax.toStringAsFixed(6)}',
          'Total = Price + Tax = ${total.toStringAsFixed(6)}',
        ],
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const salesTaxDefinition = CalculatorDefinition(
  id: 'sales_tax',
  name: 'Sales Tax',
  subtitle: 'Add tax to a pre-tax price',
  icon: IconData(0xe227, fontFamily: 'MaterialIcons'),
  accent: Color(0xFF388E3C),
  route: '/sales-tax',
  category: CalculatorCategoryId.finance,
  inputSchema: _salesTaxInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
