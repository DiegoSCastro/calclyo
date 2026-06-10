import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

const _romanInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(
      key: 'v',
      label: 'value (1-3999)',
      defaultValue: '1994',
      keyboardType: CalculatorKeyboardType.text,
    ),
  ],
  controls: [
    SegmentedToggleControl(
      key: 'dir',
      options: ['Number → Roman', 'Roman → Number'],
    ),
  ],
);

const _romanMap = <int, String>{
  1000: 'M',
  900: 'CM',
  500: 'D',
  400: 'CD',
  100: 'C',
  90: 'XC',
  50: 'L',
  40: 'XL',
  10: 'X',
  9: 'IX',
  5: 'V',
  4: 'IV',
  1: 'I',
};

String _intToRoman(int n) {
  if (n <= 0 || n >= 4000) {
    throw CalculatorFailure('Roman numerals cover 1 to 3999 (got $n)');
  }
  final out = StringBuffer();
  var rem = n;
  for (final entry in _romanMap.entries) {
    while (rem >= entry.key) {
      out.write(entry.value);
      rem -= entry.key;
    }
  }
  return out.toString();
}

int _romanToInt(String s) {
  if (s.isEmpty) {
    throw const CalculatorFailure('Roman numeral is empty');
  }
  final cleaned = s.toUpperCase();
  if (!RegExp(r'^[IVXLCDM]+$').hasMatch(cleaned)) {
    throw const CalculatorFailure('Invalid Roman numeral');
  }
  final values = <String, int>{
    'I': 1,
    'V': 5,
    'X': 10,
    'L': 50,
    'C': 100,
    'D': 500,
    'M': 1000,
  };
  var total = 0;
  var prev = 0;
  for (var i = cleaned.length - 1; i >= 0; i--) {
    final v = values[cleaned[i]]!;
    if (v < prev) {
      total -= v;
    } else {
      total += v;
      prev = v;
    }
  }
  if (total <= 0 || total >= 4000) {
    throw const CalculatorFailure('Roman numeral out of range (1-3999)');
  }
  return total;
}

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final raw = (values['v'] ?? '').trim();
      if (raw.isEmpty) {
        throw const CalculatorFailure('Value is required');
      }
      final dir = values['dir'] ?? 'Number → Roman';
      if (dir == 'Number → Roman') {
        final n = int.tryParse(raw);
        if (n == null) {
          throw const CalculatorFailure('Enter a whole number');
        }
        final roman = _intToRoman(n);
        return CalculatorResult(
          primary: n.toDouble(),
          primaryLabel: 'Roman',
          steps: [
            'Number: $n',
            'Roman: $roman',
          ],
        );
      } else {
        final n = _romanToInt(raw);
        return CalculatorResult(
          primary: n.toDouble(),
          primaryLabel: 'Number',
          steps: [
            'Roman: ${raw.toUpperCase()}',
            'Number: $n',
          ],
        );
      }
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const romanNumeralsDefinition = CalculatorDefinition(
  id: 'roman_numerals',
  name: 'Roman Numerals',
  subtitle: 'Convert between integers and Roman numerals',
  icon: IconData(0xe865, fontFamily: 'MaterialIcons'), // Icons.schedule
  accent: Color(0xFF6A1B9A),
  route: '/roman-numerals',
  category: CalculatorCategoryId.lifestyle,
  inputSchema: _romanInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
