import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

const _ageInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(
      key: 'dob',
      label: 'date of birth (YYYY-MM-DD)',
      defaultValue: '1990-01-15',
      keyboardType: CalculatorKeyboardType.text,
    ),
    CalculatorInputField(
      key: 'ref',
      label: 'reference date (YYYY-MM-DD)',
      defaultValue: '2026-06-10',
      keyboardType: CalculatorKeyboardType.text,
    ),
  ],
);

class _Age {
  const _Age(this.years, this.months, this.days);
  final int years;
  final int months;
  final int days;
}

_Age _ageBetween(DateTime dob, DateTime ref) {
  if (ref.isBefore(dob)) {
    throw const CalculatorFailure('Reference date is before date of birth');
  }
  var years = ref.year - dob.year;
  var months = ref.month - dob.month;
  var days = ref.day - dob.day;
  if (days < 0) {
    // borrow from previous month
    final prevMonth = DateTime(ref.year, ref.month - 1, dob.day);
    days = ref.difference(prevMonth).inDays;
    months -= 1;
  }
  if (months < 0) {
    months += 12;
    years -= 1;
  }
  return _Age(years, months, days);
}

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final dobRaw = (values['dob'] ?? '').trim();
      final refRaw = (values['ref'] ?? '').trim();
      if (dobRaw.isEmpty || refRaw.isEmpty) {
        throw const CalculatorFailure('Both dates are required');
      }
      final dob = DateTime.tryParse(dobRaw);
      final ref = DateTime.tryParse(refRaw);
      if (dob == null) {
        throw CalculatorFailure('Invalid DOB: "$dobRaw" (use YYYY-MM-DD)');
      }
      if (ref == null) {
        throw CalculatorFailure('Invalid reference date: "$refRaw"');
      }
      final age = _ageBetween(dob, ref);
      final totalDays = ref.difference(dob).inDays;
      return CalculatorResult(
        primary: age.years.toDouble(),
        primaryLabel: 'Age',
        steps: [
          'DOB: $dobRaw',
          'Reference: $refRaw',
          'Age: ${age.years} years, ${age.months} months, ${age.days} days',
          'Total days: $totalDays',
        ],
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const ageDefinition = CalculatorDefinition(
  id: 'age',
  name: 'Age',
  subtitle: 'Years, months, and days between two dates',
  icon: IconData(0xe425, fontFamily: 'MaterialIcons'), // calendar_today
  accent: Color(0xFFAD1457),
  route: '/age',
  category: CalculatorCategoryId.dateTime,
  inputSchema: _ageInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
