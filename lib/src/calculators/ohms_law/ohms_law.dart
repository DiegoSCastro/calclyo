import 'package:calclyo/src/calculators/_widgets.dart';
import 'package:calclyo/src/calculators/rule_of_three/rule_of_three.dart'
    show parseField;
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

const _modeKey = 'mode';
const _modeVfromIR = 'V = I × R';
const _modeIfromVR = 'I = V / R';
const _modeRfromVI = 'R = V / I';
const _modePfromVI = 'P = V × I';

const _ohmsInputSchema = CalculatorInputSchema(
  fields: [
    CalculatorInputField(key: 'v', label: 'V (volts)', defaultValue: '12'),
    CalculatorInputField(key: 'i', label: 'I (amps)', defaultValue: '2'),
    CalculatorInputField(key: 'r', label: 'R (ohms)', defaultValue: '6'),
  ],
  controls: [
    SegmentedToggleControl(
      key: _modeKey,
      options: [_modeVfromIR, _modeIfromVR, _modeRfromVI, _modePfromVI],
    ),
  ],
);

TaskEither<CalculatorFailure, CalculatorResult> _compute(
  Map<String, String> values,
) {
  return TaskEither<CalculatorFailure, CalculatorResult>.tryCatch(() async {
    final mode = values[_modeKey] ?? _modeVfromIR;
    switch (mode) {
      case _modeVfromIR:
        final i = parseField(values['i'] ?? '', key: 'I');
        final r = parseField(values['r'] ?? '', key: 'R', allowZero: false);
        final result = i * r;
        return CalculatorResult(
          primary: result,
          primaryLabel: 'V',
          steps: [
            'V = I × R',
            'V = ${i.toStringAsFixed(4)} × ${r.toStringAsFixed(4)}',
            'V = ${result.toStringAsFixed(6)}',
            'P = V × I = ${(result * i).toStringAsFixed(6)} W',
          ],
        );
      case _modeIfromVR:
        final v = parseField(values['v'] ?? '', key: 'V');
        final r = parseField(values['r'] ?? '', key: 'R', allowZero: false);
        final result = v / r;
        return CalculatorResult(
          primary: result,
          primaryLabel: 'I',
          steps: [
            'I = V / R',
            'I = ${v.toStringAsFixed(4)} / ${r.toStringAsFixed(4)}',
            'I = ${result.toStringAsFixed(6)}',
            'P = V × I = ${(v * result).toStringAsFixed(6)} W',
          ],
        );
      case _modeRfromVI:
        final v = parseField(values['v'] ?? '', key: 'V');
        final i = parseField(values['i'] ?? '', key: 'I');
        if (i == 0) {
          throw const CalculatorFailure('I cannot be zero');
        }
        final result = v / i;
        return CalculatorResult(
          primary: result,
          primaryLabel: 'R',
          steps: [
            'R = V / I',
            'R = ${v.toStringAsFixed(4)} / ${i.toStringAsFixed(4)}',
            'R = ${result.toStringAsFixed(6)}',
            'P = V × I = ${(v * i).toStringAsFixed(6)} W',
          ],
        );
      case _modePfromVI:
        final v = parseField(values['v'] ?? '', key: 'V');
        final i = parseField(values['i'] ?? '', key: 'I');
        final p = v * i;
        return CalculatorResult(
          primary: p,
          primaryLabel: 'P',
          steps: [
            'P = V × I',
            'P = ${v.toStringAsFixed(4)} × ${i.toStringAsFixed(4)}',
            'P = ${p.toStringAsFixed(6)} W',
          ],
        );
      default:
        throw const CalculatorFailure('Unknown mode');
    }
  }, (e, _) => e is CalculatorFailure ? e : CalculatorFailure(e.toString()));
}

/// Registry entry for the ohmsLaw calculator.
const ohmsLawDefinition = CalculatorDefinition(
  id: 'ohms_law',
  name: "Ohm's Law",
  subtitle: 'V = I × R, P = V × I',
  icon: IconData(0xea4b, fontFamily: 'MaterialIcons'), // science
  accent: Color(0xFF6A1B9A),
  route: '/ohms-law',
  category: CalculatorCategoryId.science,
  inputSchema: _ohmsInputSchema,
  compute: _compute,
  stepRenderer: genericStepRenderer,
);
