import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;

const _unitPriceInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'price', label: 'total price', defaultValue: '9.99'),
    CalculatorInputField(key: 'units', label: 'units', defaultValue: '3'),
  ],
);

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final price = parseField(values['price'] ?? '', key: 'price');
      final units = parseField(values['units'] ?? '', key: 'units');
      if (units == 0) {
        throw const CalculatorFailure('Units cannot be zero');
      }
      final per = price / units;
      return CalculatorResult(
        primary: per,
        primaryLabel: 'Per unit',
        steps: [
          'Total: $price',
          'Units: $units',
          'Per unit = Total / Units = ${per.toStringAsFixed(6)}',
        ],
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const unitPriceDefinition = CalculatorDefinition(
  id: 'unit_price',
  name: 'Unit Price',
  subtitle: 'Price per unit given total and count',
  icon: IconData(0xe227, fontFamily: 'MaterialIcons'), // attach_money
  accent: Color(0xFF2E7D32),
  route: '/unit-price',
  category: CalculatorCategoryId.finance,
  inputSchema: _unitPriceInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
