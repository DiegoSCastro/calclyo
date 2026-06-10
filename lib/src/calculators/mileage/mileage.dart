import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

const _mileageInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(
      key: 'km',
      label: 'distance (km)',
      defaultValue: '500',
    ),
    CalculatorInputField(key: 'l', label: 'fuel used (L)', defaultValue: '40'),
    CalculatorInputField(
      key: 'price',
      label: 'fuel price (/L)',
      defaultValue: '1.50',
    ),
  ],
);

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(() async {
    final km = parseField(values['km'] ?? '', key: 'km', allowZero: false);
    final l = parseField(values['l'] ?? '', key: 'L', allowZero: false);
    final price = parseField(values['price'] ?? '', key: 'price');
    final kmPerL = km / l;
    final lPer100 = l / km * 100;
    final mpgUs = kmPerL / 0.425143707;
    final costPerKm = price * lPer100 / 100;
    return CalculatorResult(
      primary: kmPerL,
      primaryLabel: 'km/L',
      steps: [
        'Distance: $km km',
        'Fuel: $l L',
        'km/L = ${kmPerL.toStringAsFixed(4)}',
        'L/100km = ${lPer100.toStringAsFixed(4)}',
        'mpg (US) = ${mpgUs.toStringAsFixed(4)}',
        'Cost/km = $price × L/100km / 100 = ${costPerKm.toStringAsFixed(4)}',
      ],
    );
  }, (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()));
}

/// Registry entry for the mileage calculator.
const mileageDefinition = CalculatorDefinition(
  id: 'mileage',
  name: 'Mileage Cost',
  subtitle: 'km/L, mpg, L/100km, and cost per km',
  icon: IconData(0xea4b, fontFamily: 'MaterialIcons'),
  accent: Color(0xFF4527A0),
  route: '/mileage',
  category: CalculatorCategoryId.science,
  inputSchema: _mileageInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
