import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

const _kindKey = 'dir';
const _kindDec2Bin = 'Dec → Bin';
const _kindDec2Oct = 'Dec → Oct';
const _kindDec2Hex = 'Dec → Hex';
const _kindBin2Dec = 'Bin → Dec';
const _kindOct2Dec = 'Oct → Dec';
const _kindHex2Dec = 'Hex → Dec';

const _numericBaseInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'v', label: 'value', defaultValue: '255'),
  ],
  controls: [
    SegmentedToggleControl(
      key: _kindKey,
      options: [
        _kindDec2Bin,
        _kindDec2Oct,
        _kindDec2Hex,
        _kindBin2Dec,
        _kindOct2Dec,
        _kindHex2Dec,
      ],
    ),
  ],
);

class _BasePair {
  const _BasePair(this.from, this.to);
  final int from;
  final int to;
}

const _baseMap = <String, _BasePair>{
  _kindDec2Bin: _BasePair(10, 2),
  _kindDec2Oct: _BasePair(10, 8),
  _kindDec2Hex: _BasePair(10, 16),
  _kindBin2Dec: _BasePair(2, 10),
  _kindOct2Dec: _BasePair(8, 10),
  _kindHex2Dec: _BasePair(16, 10),
};

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(
    () async {
      final raw = (values['v'] ?? '').trim();
      if (raw.isEmpty) {
        throw const CalculatorFailure('value is required');
      }
      final kind = values[_kindKey] ?? _kindDec2Hex;
      final pair = _baseMap[kind] ?? _baseMap[_kindDec2Hex]!;
      final n = int.tryParse(raw, radix: pair.from);
      if (n == null) {
        throw CalculatorFailure(
          '"$raw" is not a valid base-${pair.from} number',
        );
      }
      final formatted = pair.to == 10
          ? n.toString()
          : n.toRadixString(pair.to).toUpperCase();
      return CalculatorResult(
        primary: n.toDouble(),
        primaryLabel: pair.to == 10 ? 'dec' : 'value',
        steps: [
          'Input: $raw ($kind)',
          'Parsed value: $n (base 10)',
          'Result: $formatted (base ${pair.to})',
        ],
      );
    },
    (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()),
  );
}

const numericBaseDefinition = CalculatorDefinition(
  id: 'numeric_base',
  name: 'Numeric Base',
  subtitle: 'Dec / Bin / Oct / Hex',
  icon: IconData(0xe85f, fontFamily: 'MaterialIcons'),
  accent: Color(0xFF455A64),
  route: '/numeric-base',
  category: CalculatorCategoryId.converter,
  inputSchema: _numericBaseInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
