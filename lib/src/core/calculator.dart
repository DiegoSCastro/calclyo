import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:calclyo/src/core/categories.dart';

/// Description of a single calculator input field.
class CalculatorInputField extends Equatable {
  const CalculatorInputField({
    required this.key,
    required this.label,
    this.helper,
    this.defaultValue,
    this.allowDecimal = true,
    this.allowSigned = true,
  });

  /// Stable identifier — used to read the value out of the form map.
  final String key;

  /// Human label shown above the field.
  final String label;

  /// Optional helper text shown beneath the field.
  final String? helper;

  /// Pre-filled value for the field. Shown when the user opens the form and
  /// submitted as-is if the user does not edit it.
  final String? defaultValue;

  final bool allowDecimal;
  final bool allowSigned;

  @override
  List<Object?> get props => [
        key,
        label,
        helper,
        defaultValue,
        allowDecimal,
        allowSigned,
      ];
}

/// Calculator-specific UI controls that aren't number fields. Each control
/// writes a numeric value into the values map (so the [CalculatorDefinition.compute]
/// function can still consume a uniform `Map<String, double>`).
sealed class CalculatorControl extends Equatable {
  const CalculatorControl({required this.key});
  final String key;

  /// Build the widget the form view will place in the layout.
  Widget build(BuildContext context, ValueChanged<double> onChanged);
}

/// A single-select toggle rendered as a [SegmentedButton]. Used for things
/// like direct/inverse mode switches — the selected option's index is
/// written to the values map as a double.
class SegmentedToggleControl extends CalculatorControl {
  const SegmentedToggleControl({
    required super.key,
    required this.options,
    this.initialIndex = 0,
  });

  final List<String> options;
  final int initialIndex;

  @override
  List<Object?> get props => [key, options, initialIndex];

  @override
  Widget build(BuildContext context, ValueChanged<double> onChanged) {
    return SegmentedButton<int>(
      segments: [
        for (var i = 0; i < options.length; i++)
          ButtonSegment<int>(value: i, label: Text(options[i])),
      ],
      selected: {initialIndex},
      onSelectionChanged: (set) => onChanged(set.first.toDouble()),
    );
  }
}

/// Schema describing what a calculator needs from the user.
///
/// Each calculator exposes a fixed [fields] list (number inputs) and
/// optional [controls] list (segmented buttons, sliders, etc.). The UI
/// layer builds a form from this schema; the compute function receives a
/// `Map<String, double>` keyed by [CalculatorInputField.key] /
/// [CalculatorControl.key].
class CalculatorInputSchema extends Equatable {
  const CalculatorInputSchema({this.fields = const [], this.controls = const []});

  final List<CalculatorInputField> fields;
  final List<CalculatorControl> controls;

  @override
  List<Object?> get props => [fields, controls];
}

/// Result of a calculator computation.
///
/// [primary] is the headline answer (rendered large), [steps] is the
/// human-readable explanation, and [primaryLabel] is shown next to the
/// value (e.g. "x =", "Area =").
class CalculatorResult extends Equatable {
  const CalculatorResult({
    required this.primary,
    required this.steps,
    this.primaryLabel = 'Result',
  });

  final double primary;
  final String primaryLabel;
  final List<String> steps;

  @override
  List<Object?> get props => [primary, primaryLabel, steps];
}

/// Failure emitted by a calculator's compute function. Messages should be
/// user-facing — the UI renders them verbatim.
class CalculatorFailure implements Exception {
  const CalculatorFailure(this.message);
  final String message;

  @override
  String toString() => 'CalculatorFailure: $message';
}

/// Shared contract every calculator implementation must satisfy.
///
/// Each calculator is a single const instance exported from its own file
/// under `lib/src/calculators/<id>/<id>.dart`. The [CategoryRegistry]
/// collects them and the router/render layer reads everything (id, name,
/// icon, accent, route, inputs, compute) from this object — no other code
/// path needs to know about a specific calculator.
class CalculatorDefinition extends Equatable {
  const CalculatorDefinition({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.route,
    required this.category,
    required this.inputSchema,
    required this.compute,
    required this.stepRenderer,
  });

  /// Unique id, e.g. `rule-of-three`. Used for routing and registry lookup.
  final String id;

  /// Display name shown in lists and app bars.
  final String name;

  /// Short one-liner shown under [name] in category lists.
  final String subtitle;

  /// Material icon for the calculator tile.
  final IconData icon;

  /// Accent color used to highlight the result.
  final Color accent;

  /// Route path the [AppRouter] registers.
  final String route;

  /// Which category this calculator belongs to.
  final CalculatorCategoryId category;

  /// Form schema the UI builds inputs from.
  final CalculatorInputSchema inputSchema;

  /// Pure async function turning parsed inputs into either a failure or a
  /// result. Returning a [TaskEither] keeps error handling uniform across
  /// calculators — no `try/catch` leaks into the UI layer.
  final TaskEither<CalculatorFailure, CalculatorResult> Function(
    Map<String, double> values,
  ) compute;

  /// Widget that renders the explanation. Receives the result and the theme.
  final Widget Function(BuildContext context, CalculatorResult result)
      stepRenderer;

  @override
  List<Object?> get props => [
        id,
        name,
        subtitle,
        icon.codePoint,
        accent,
        route,
        category,
        inputSchema,
      ];
}
