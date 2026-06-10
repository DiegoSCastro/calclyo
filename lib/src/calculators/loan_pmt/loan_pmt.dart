import 'dart:math' as math;

import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

const _loanInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'p', label: 'principal', defaultValue: '200000'),
    CalculatorInputField(key: 'r', label: 'annual rate (%)', defaultValue: '5'),
    CalculatorInputField(key: 'n', label: 'term (months)', defaultValue: '360'),
  ],
);

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(() async {
    final p = parseField(values['p'] ?? '', key: 'principal');
    final rAnnual = parseField(values['r'] ?? '', key: 'rate');
    final nRaw = parseField(values['n'] ?? '', key: 'term');
    final n = nRaw.round();
    if (n != nRaw || n <= 0) {
      throw const CalculatorFailure('Term must be a positive integer');
    }
    final r = rAnnual / 100 / 12;
    double payment;
    if (r == 0) {
      payment = p / n;
    } else {
      final pow = math.pow(1 + r, n).toDouble();
      payment = p * (r * pow) / (pow - 1);
    }
    final totalPaid = payment * n;
    final totalInterest = totalPaid - p;
    return CalculatorResult(
      primary: payment,
      primaryLabel: 'Monthly',
      steps: [
        'Principal: $p',
        'Annual rate: $rAnnual%, monthly = ${(r * 100).toStringAsFixed(4)}%',
        'Term: $n months',
        'Payment = P × r / (1 − (1 + r)^-n) = ${payment.toStringAsFixed(6)}',
        'Total paid: ${totalPaid.toStringAsFixed(2)}',
        'Total interest: ${totalInterest.toStringAsFixed(2)}',
      ],
    );
  }, (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()));
}

/// Registry entry for the loanPmt calculator.
const loanPmtDefinition = CalculatorDefinition(
  id: 'loan_pmt',
  name: 'Loan Payment',
  subtitle: 'Monthly payment from principal, rate, and term',
  icon: IconData(0xe227, fontFamily: 'MaterialIcons'),
  accent: Color(0xFF689F38),
  route: '/loan-pmt',
  category: CalculatorCategoryId.finance,
  inputSchema: _loanInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
