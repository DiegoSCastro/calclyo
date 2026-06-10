import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;
import 'package:calclyo/src/calculators/bmi/bmi.dart' show healthRenderer;

const _caloricInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'gender', label: 'gender (0=female, 1=male)', defaultValue: '1'),
    CalculatorInputField(key: 'age', label: 'age (years)', defaultValue: '30'),
    CalculatorInputField(key: 'h', label: 'height (cm)', defaultValue: '175'),
    CalculatorInputField(key: 'w', label: 'weight (kg)', defaultValue: '70'),
    CalculatorInputField(key: 'act', label: 'activity (1-5)', defaultValue: '3'),
  ],
);

const _activityFactors = <String, double>{
  '1': 1.2, // sedentary
  '2': 1.375, // light
  '3': 1.55, // moderate
  '4': 1.725, // active
  '5': 1.9, // very active
};

const _activityLabels = <String, String>{
  '1': 'Sedentary (desk job)',
  '2': 'Light (1-3 days/wk)',
  '3': 'Moderate (3-5 days/wk)',
  '4': 'Active (6-7 days/wk)',
  '5': 'Very active (athlete)',
};

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final g = parseField(values['gender'] ?? '', key: 'gender').round();
      final age = parseField(values['age'] ?? '', key: 'age');
      final h = parseField(values['h'] ?? '', key: 'height');
      final w = parseField(values['w'] ?? '', key: 'weight');
      final a = parseField(values['act'] ?? '', key: 'activity').round();
      // Harris-Benedict (revised 1984).
      double bmr;
      if (g == 1) {
        bmr = 88.362 + 13.397 * w + 4.799 * h - 5.677 * age;
      } else {
        bmr = 447.593 + 9.247 * w + 3.098 * h - 4.330 * age;
      }
      final factor = _activityFactors['$a'] ?? 1.2;
      final tdee = bmr * factor;
      return CalculatorResult(
        primary: tdee,
        primaryLabel: 'Daily burn',
        steps: [
          'Gender: ${g == 1 ? "Male" : "Female"}',
          'Age: $age, Height: $h cm, Weight: $w kg',
          'Activity: ${_activityLabels['$a'] ?? "?"} (× $factor)',
          'BMR (Harris-Benedict) = ${bmr.toStringAsFixed(0)} kcal/day',
          'TDEE = BMR × Activity = ${tdee.toStringAsFixed(0)} kcal/day',
          'For reference only. Not medical advice.',
        ],
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const caloricBurnDefinition = CalculatorDefinition(
  id: 'caloric_burn',
  name: 'Caloric Burn',
  subtitle: 'BMR + TDEE from age, height, weight, activity',
  icon: IconData(0xe87d, fontFamily: 'MaterialIcons'),
  accent: Color(0xFFE53935),
  route: '/caloric-burn',
  category: CalculatorCategoryId.health,
  inputSchema: _caloricInputSchema,
  compute: _compute,
  stepRenderer: healthRenderer,
);
