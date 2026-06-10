import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;

const _discountInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'price', label: 'original price', defaultValue: '80'),
    CalculatorInputField(key: 'pct', label: 'discount %', defaultValue: '25'),
  ],
);

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final price = parseField(values['price'] ?? '', key: 'price');
      final pct = parseField(values['pct'] ?? '', key: 'pct');
      final off = price * pct / 100;
      final finalPrice = price - off;
      return CalculatorResult(
        primary: finalPrice,
        primaryLabel: 'Final price',
        steps: [
          'Original: $price',
          'Discount: $pct%',
          'Off = Price × Pct / 100 = ${off.toStringAsFixed(6)}',
          'Final = Price − Off = ${finalPrice.toStringAsFixed(6)}',
        ],
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const discountDefinition = CalculatorDefinition(
  id: 'discount',
  name: 'Discount',
  subtitle: 'Apply a percentage discount to a price',
  icon: IconData(0xe227, fontFamily: 'MaterialIcons'),
  accent: Color(0xFF558B2F),
  route: '/discount',
  category: CalculatorCategoryId.finance,
  inputSchema: _discountInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
