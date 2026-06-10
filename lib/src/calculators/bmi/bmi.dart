import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

const _disclaimer = 'For reference only. Not medical advice.';

const _bmiInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'h', label: 'height (cm)', defaultValue: '175'),
    CalculatorInputField(key: 'w', label: 'weight (kg)', defaultValue: '70'),
  ],
);

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(() async {
    final h = parseField(values['h'] ?? '', key: 'height', allowZero: false);
    final w = parseField(values['w'] ?? '', key: 'weight');
    final m = h / 100;
    final bmi = w / (m * m);
    final category = _bmiCategory(bmi);
    return CalculatorResult(
      primary: bmi,
      primaryLabel: 'BMI',
      steps: [
        'Height: $h cm, Weight: $w kg',
        'BMI = Weight / Height² = ${bmi.toStringAsFixed(2)}',
        'Category: $category',
        _disclaimer,
      ],
    );
  }, (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()));
}

String _bmiCategory(double bmi) {
  if (bmi < 18.5) return 'Underweight';
  if (bmi < 25) return 'Normal weight';
  if (bmi < 30) return 'Overweight';
  return 'Obese';
}

/// healthRenderer.
Widget healthRenderer(BuildContext context, CalculatorResult result) {
  final theme = Theme.of(context);
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${result.primaryLabel} = ${result.primary.toStringAsFixed(2)}',
            style: theme.textTheme.headlineSmall,
          ),
          const Divider(),
          for (final step in result.steps)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(step),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _disclaimer,
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Registry entry for the bmi calculator.
const bmiDefinition = CalculatorDefinition(
  id: 'bmi',
  name: 'BMI',
  subtitle: 'Body Mass Index from height and weight',
  icon: IconData(0xe87d, fontFamily: 'MaterialIcons'), // favorite
  accent: Color(0xFFC62828),
  route: '/bmi',
  category: CalculatorCategoryId.health,
  inputSchema: _bmiInputSchema,
  compute: _compute,
  stepRenderer: healthRenderer,
);
